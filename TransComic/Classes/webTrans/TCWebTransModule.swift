//
//  TCWebTransModule.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class TCWebTransModule {
    
    /// 获取网页翻译首页控制器
    static func getHomeViewController() -> TCWebTransHomeViewController {
        return TCWebTransHomeViewController()
    }
    
    /// 获取网页详情控制器
    /// - Parameter url: 要加载的网址
    /// - Returns: 网页详情控制器
    static func getDetailViewController(url: String) -> TCWebDetailViewController {
        let controller = TCWebDetailViewController()
        controller.websiteURL = url
        return controller
    }
    
    /// 清除所有历史记录
    static func clearAllHistory() {
        TCWebsiteManager.shared.clearHistoryWebsites()
    }
    
    /// 清理重复的历史记录
    static func cleanDuplicateHistory() {
        TCWebsiteManager.shared.cleanDuplicateHistoryWebsites()
    }
    
    /// 获取收藏网址数量
    static func getFavoriteCount() -> Int {
        return TCWebsiteManager.shared.getFavoriteWebsites().count
    }
    
    /// 获取历史记录数量
    static func getHistoryCount() -> Int {
        return TCWebsiteManager.shared.getHistoryWebsites().count
    }
} 