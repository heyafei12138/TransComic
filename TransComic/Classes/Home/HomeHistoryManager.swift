//
//  HomeHistoryManager.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import Foundation

class HomeHistoryManager {
    static let shared = HomeHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let homeHistoryKey = "TCHomeHistory"
    private let maxHistoryCount = 50
    
    private init() {}
    
    // MARK: - Public Methods
    func addHistory(_ history: HomeHistoryModel) {
        var histories = getHistories()
        
        // 添加到开头
        histories.insert(history, at: 0)
        
        // 限制历史记录数量
        if histories.count > maxHistoryCount {
            let removedHistories = Array(histories.suffix(histories.count - maxHistoryCount))
            histories = Array(histories.prefix(maxHistoryCount))
            
            // 删除被移除的历史记录的文件
            for removedHistory in removedHistories {
                removedHistory.deleteLocalFiles()
            }
        }
        
        saveHistories(histories)
    }
    
    func getHistories() -> [HomeHistoryModel] {
        guard let data = userDefaults.data(forKey: homeHistoryKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let histories = try? decoder.decode([HomeHistoryModel].self, from: data) else {
            return []
        }
        return histories
    }
    
    func getRecentHistories(limit: Int = 10) -> [HomeHistoryModel] {
        let allHistories = getHistories()
        return Array(allHistories.prefix(limit))
    }
    
    func removeHistory(_ history: HomeHistoryModel) {
        var histories = getHistories()
        histories.removeAll { $0.id == history.id }
        
        // 删除本地文件
        history.deleteLocalFiles()
        
        saveHistories(histories)
    }
    
    func clearAllHistories() {
        let histories = getHistories()
        
        // 删除所有本地文件
        for history in histories {
            history.deleteLocalFiles()
        }
        
        saveHistories([])
    }
    
    func getHistoriesByCategory(_ category: String) -> [HomeHistoryModel] {
        let allHistories = getHistories()
        return allHistories.filter { $0.category == category }
    }
    
    func getCategories() -> [String] {
        let allHistories = getHistories()
        let categories = Set(allHistories.map { $0.category })
        return Array(categories).sorted()
    }
    
    func getTotalCount() -> Int {
        return getHistories().count
    }
    
    // MARK: - Private Methods
    private func saveHistories(_ histories: [HomeHistoryModel]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(histories) {
            userDefaults.set(data, forKey: homeHistoryKey)
        }
    }
} 