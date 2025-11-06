//
//  IAPManager.swift
//  TransComic
//
//  Created by Assistant on 2025/08/20.
//

import Foundation
import StoreKit
import SwiftyStoreKit

public enum SubscriptionProduct: String, CaseIterable {
    case weekly = "weekTransComicNew"
    case monthly = "monthTransComicNew"
    case yearly = "yearTransComicNew"
    
    var displayName: String {
        switch self {
        case .weekly: return "周订阅".localized()
        case .monthly: return "月订阅".localized()
        case .yearly: return "年订阅".localized()
        }
    }
}

public final class IAPManager {
    public static let shared = IAPManager()
    private init() {}

    public func start() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                default:
                    break
                }
            }
        }
    }

    public func fetchProductsInfo(_ ids: [SubscriptionProduct], completion: @escaping ([String: SKProduct]) -> Void) {
        let setIds = Set(ids.map { $0.rawValue })
        SwiftyStoreKit.retrieveProductsInfo(setIds) { result in
            var map: [String: SKProduct] = [:]
            for product in result.retrievedProducts {
                map[product.productIdentifier] = product
            }
            completion(map)
        }
    }
    public func fetchProductsInfo(completion: @escaping ([String: String]) -> Void) {
        let ids = SubscriptionProduct.allCases
        let setIds = Set(ids.map { $0.rawValue })
        SwiftyStoreKit.retrieveProductsInfo(setIds) { result in
            var priceMap: [String: String] = [:]
            
            for product in result.retrievedProducts {
                // 使用SwiftyStoreKit提供的localizedPrice获取格式化价格
                if let localizedPrice = product.localizedPrice {
                    priceMap[product.productIdentifier] = localizedPrice
                }
            }
            
            // 确保所有请求的产品都有价格信息（如果没有则用占位符）
            for id in setIds {
                if priceMap[id] == nil {
                    priceMap[id] = "价格无法获取" // 或设置为nil根据需求调整
                }
            }
            
            completion(priceMap)
        }
    }
    func getGoodsInfo() {
        if !SwiftyStoreKit.canMakePayments {
            print("Your device is not able or allowed to make payments!")
            return
        }
        let StoreAllProductIds = ["weekTransComic","monthTransComic", "yearTransComic"]

        SwiftyStoreKit.retrieveProductsInfo(.init(StoreAllProductIds)) { result in
            let products = result.retrievedProducts
            let invalidProductIds = result.invalidProductIDs
            print("Products: \(products)")
            print("Invalid product identifiers: \(invalidProductIds)")
        }
    }

   
}

public extension SKProduct {
    var localizedPriceString: String {
        if let price = self.localizedPrice {
            return price
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? ""
    }
}


