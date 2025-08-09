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
    
    /// 检查是否支持截屏功能
    static func isScreenshotSupported() -> Bool {
        return true
    }
    
    /// 获取截屏历史记录列表控制器
    static func getScreenshotHistoryListViewController() -> TCScreenshotHistoryListViewController {
        return TCScreenshotHistoryListViewController()
    }
    
    /// 获取截屏历史记录数量
    static func getScreenshotHistoryCount() -> Int {
        return TCScreenshotHistoryManager.shared.getScreenshotHistories().count
    }
    
    /// 获取截屏历史记录总图片数量
    static func getScreenshotHistoryImageCount() -> Int {
        return TCScreenshotHistoryManager.shared.getTotalImageCount()
    }
    
    /// 获取截屏历史记录存储大小
    static func getScreenshotHistoryStorageSize() -> String {
        let size = TCScreenshotHistoryManager.shared.getTotalStorageSize()
        return TCScreenshotHistoryManager.shared.formatStorageSize(size)
    }
} 