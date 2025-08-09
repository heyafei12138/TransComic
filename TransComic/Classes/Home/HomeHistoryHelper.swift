//
//  HomeHistoryHelper.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class HomeHistoryHelper {
    
    // MARK: - Public Methods
    
    /// 添加动漫翻译历史记录
    static func addAnimeTranslationHistory(title: String, image: UIImage? = nil, description: String) {
        let history = HomeHistoryModel(
            title: title,
            category: "动漫翻译",
            image: image,
            description: description
        )
        HomeHistoryManager.shared.addHistory(history)
    }
    
    /// 添加图片识别历史记录
    static func addImageRecognitionHistory(title: String, image: UIImage? = nil, description: String) {
        let history = HomeHistoryModel(
            title: title,
            category: "图片识别",
            image: image,
            description: description
        )
        HomeHistoryManager.shared.addHistory(history)
    }
    
    /// 添加网页翻译历史记录
    static func addWebTranslationHistory(title: String, image: UIImage? = nil, description: String) {
        let history = HomeHistoryModel(
            title: title,
            category: "网页翻译",
            image: image,
            description: description
        )
        HomeHistoryManager.shared.addHistory(history)
    }
    
    /// 添加截屏历史记录
    static func addScreenshotHistory(title: String, image: UIImage? = nil, description: String) {
        let history = HomeHistoryModel(
            title: title,
            category: "网页截屏",
            image: image,
            description: description
        )
        HomeHistoryManager.shared.addHistory(history)
    }
    
    /// 添加自定义类别历史记录
    static func addCustomHistory(title: String, category: String, image: UIImage? = nil, description: String) {
        let history = HomeHistoryModel(
            title: title,
            category: category,
            image: image,
            description: description
        )
        HomeHistoryManager.shared.addHistory(history)
    }
    
    /// 获取历史记录统计信息
    static func getHistoryStats() -> (total: Int, categories: Int) {
        let total = HomeHistoryManager.shared.getTotalCount()
        let categories = HomeHistoryManager.shared.getCategories().count
        return (total, categories)
    }
    
    /// 获取指定类别的历史记录数量
    static func getHistoryCount(for category: String) -> Int {
        return HomeHistoryManager.shared.getHistoriesByCategory(category).count
    }
    
    /// 清空所有历史记录
    static func clearAllHistories() {
        HomeHistoryManager.shared.clearAllHistories()
    }
    
    /// 删除指定历史记录
    static func removeHistory(_ history: HomeHistoryModel) {
        HomeHistoryManager.shared.removeHistory(history)
    }
} 