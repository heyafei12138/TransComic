//
//  AppReviewHelper.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/9/26.
//

import Foundation
import StoreKit

final class AppReviewHelper {
    static let shared = AppReviewHelper()
    
    private init() {}
    
    private let triggerCountKey = "AppReviewTriggerCount"
    private let triggerLimit = 2   // 点击 2 次后触发
    
    /// 按钮点击调用此方法
    func recordButtonClick() {
        let count = UserDefaults.standard.integer(forKey: triggerCountKey) + 1
        UserDefaults.standard.set(count, forKey: triggerCountKey)
        
        if count >= triggerLimit {
            requestReview()
            resetCount()
        }
    }
    
    /// 请求系统评分弹窗
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    /// 重置计数
    private func resetCount() {
        UserDefaults.standard.set(0, forKey: triggerCountKey)
    }
}
