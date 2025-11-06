//
//  PayManager.swift
//  TransComic
//
//  Created by hebert on 2025/9/17.
//

import Foundation


import SwiftyStoreKit
import SwiftyUserDefaults
// 声明为 var，并在运行时初始化


public var StoreAllProductIds: [String] = ["weekTransComicNew", "monthTransComicNew", "yearTransComicNew"]
public var StoreAllSubscribeProductIds: [String] = ["weekTransComicNew", "monthTransComicNew", "yearTransComicNew"]
public var StoreAllPaymentProductIds: [String] = []



extension DefaultsKeys {
    var priceArr: DefaultsKey<[String]> { .init("priceArr", defaultValue: []) }
}
import StoreKit

class KLPayManager: NSObject {
    public static let shared = KLPayManager()
    func getGoodsInfo() {
        if !SwiftyStoreKit.canMakePayments {
            print("Your device is not able or allowed to make payments!")
            return
        }
        // 获取商品信息
        SwiftyStoreKit.retrieveProductsInfo(.init(StoreAllProductIds)) { result in
            let products = result.retrievedProducts
            if !products.isEmpty {
                let arrPrices = products.compactMap { $0.localizedPrice }
                Defaults[\.priceArr] = self.sortPrices(arrPrices)
            }

            if let product = result.retrievedProducts.first {
                // 返回的retrievedProducts数组Set<SKProduct>
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.getGoodsInfo()
                }
            }
        }
    }
    func sortPrices(_ prices: [String]) -> [String] {
        // 将价格字符串转换为元组 (原始字符串, 数值)
        let pricesWithValues = prices.compactMap { price -> (String, Double)? in
            // 提取数值部分
            let priceValueString = price.filter { "0123456789.".contains($0) }
            
            // 尝试将数值部分转换为 Double
            guard let priceValue = Double(priceValueString) else {
                return nil
            }
            
            return (price, priceValue)
        }
        
        // 按照数值部分进行排序
        let sortedPricesWithValues = pricesWithValues.sorted { (tuple1, tuple2) -> Bool in
            return tuple1.1 < tuple2.1
        }
        
        // 提取排序后的原始字符串
        let sortedPrices = sortedPricesWithValues.map { $0.0 }
        
        return sortedPrices
    }


    func purchaseProduct(_ id: String, onSuccess: @escaping () -> Void) {
        Loading()
        SwiftyStoreKit.purchaseProduct(id, quantity: 1, atomically: false) { result in
            switch result {
            case .success(let purchase):
                let vipExpirationTimestamp: Int
                if let subscriptionPeriod = purchase.product.subscriptionPeriod {
                    let currentTime = Int(Date.init().timeIntervalSince1970)
                    let baseTime = 24 * 60 * 60
                    switch subscriptionPeriod.unit {
                    case .week:
                        vipExpirationTimestamp = baseTime*subscriptionPeriod.numberOfUnits*7+currentTime
                    case .month:
                        vipExpirationTimestamp = baseTime*subscriptionPeriod.numberOfUnits*30+currentTime
                    case .year:
                        vipExpirationTimestamp = baseTime*subscriptionPeriod.numberOfUnits*365+currentTime
                    default:
                        vipExpirationTimestamp = baseTime*subscriptionPeriod.numberOfUnits+currentTime
                    }
                } else {
                    vipExpirationTimestamp = Int.max
                }
                StorageManager.shared.vipExpirationTimestamp = vipExpirationTimestamp
                print("Purchase Success: \(purchase.productId)")
                self.verifyReceipt { error in
                    HideLoading()
                    if error == nil  {
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                        if StorageManager.shared.isVipValid {
                            onSuccess()
                            Toast("Success")
                            
                        }
                    } else {
                        Toast("failure")

                        
                    }
                }
            case .error(let error):
                HideLoading()
                print(error.localizedDescription)
                Toast("Cancel Payment")

                

            }
        }
    }
    func restore(loading: Bool = true, onSuccess: (() -> Void)? = nil) {
        if loading {
            Loading()
        }
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            self.verifyReceipt { error in
                if loading {
                    HideLoading()
                }
                if error == nil {
                    results.restoredPurchases.forEach { purchase in
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                    }
                    if loading {
                        if StorageManager.shared.isVipValid {
                            
                            Toast("Restore successful")
                        } else {
                            Toast("Subscription expired")
                            
                        }
                    }
                    if StorageManager.shared.isVipValid {
                        onSuccess?()
                    }
                } else {
                    if loading {
                        HideLoading()

                        Toast("Restore failed")
                        
                    }
                }
            }
        }
    }

    func verifyReceipt(completionHandle: ((_ error: String?) -> Void)?) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: StoreShareKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                var vipExpirationTimestamp: Int?
                // 永久会员
                for productId in StoreAllPaymentProductIds {
                    let result = SwiftyStoreKit.verifyPurchase(productId: productId, inReceipt: receipt)
                    switch result {
                    case .purchased:
                        vipExpirationTimestamp = Int.max
                        break
                    case .notPurchased:
                        break
                    }
                }
                // 订阅会员
                if vipExpirationTimestamp == nil {
                    for productId in StoreAllSubscribeProductIds {
                        let result = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productId, inReceipt: receipt)
                        switch result {
                        case .purchased(let expiryDate, _):
                            vipExpirationTimestamp = Int(expiryDate.timeIntervalSince1970)
                        case .expired:
                            break
                        case .notPurchased:
                            break
                        }
                    }
                }
                if let vipExpirationTimestamp {
                    // 默认增加30分钟等候期
                    StorageManager.shared.vipExpirationTimestamp = vipExpirationTimestamp+1800
                } else {
                    StorageManager.shared.vipExpirationTimestamp = 0
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadshowVip"), object: nil)

                completionHandle?(nil)
            case .error(let error):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadshowVip"), object: nil)

                completionHandle?(error.localizedDescription)
            }
        }
    }

}
