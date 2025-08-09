//
//  TCScreenshotHistoryManager.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import Foundation

class TCScreenshotHistoryManager {
    static let shared = TCScreenshotHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let screenshotHistoryKey = "TCScreenshotHistory"
    private let maxHistoryCount = 100
    
    private init() {}
    
    // MARK: - Public Methods
    func addScreenshotHistory(_ history: TCScreenshotHistoryModel) {
        var histories = getScreenshotHistories()
        
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
        
        saveScreenshotHistories(histories)
    }
    
    func getScreenshotHistories() -> [TCScreenshotHistoryModel] {
        guard let data = userDefaults.data(forKey: screenshotHistoryKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let histories = try? decoder.decode([TCScreenshotHistoryModel].self, from: data) else {
            return []
        }
        return histories
    }
    
    func getRecentScreenshotHistories(limit: Int = 5) -> [TCScreenshotHistoryModel] {
        let allHistories = getScreenshotHistories()
        return Array(allHistories.prefix(limit))
    }
    
    func removeScreenshotHistory(_ history: TCScreenshotHistoryModel) {
        var histories = getScreenshotHistories()
        histories.removeAll { $0.id == history.id }
        
        // 删除本地文件
        history.deleteLocalFiles()
        
        saveScreenshotHistories(histories)
    }
    
    func clearAllScreenshotHistories() {
        let histories = getScreenshotHistories()
        
        // 删除所有本地文件
        for history in histories {
            history.deleteLocalFiles()
        }
        
        saveScreenshotHistories([])
    }
    
    func getScreenshotHistoriesByCategory(_ category: String) -> [TCScreenshotHistoryModel] {
        let allHistories = getScreenshotHistories()
        return allHistories.filter { $0.category == category }
    }
    
    func getCategories() -> [String] {
        let allHistories = getScreenshotHistories()
        let categories = Set(allHistories.map { $0.category })
        return Array(categories).sorted()
    }
    
    func getTotalImageCount() -> Int {
        let histories = getScreenshotHistories()
        return histories.reduce(0) { $0 + $1.imageCount }
    }
    
    func getTotalStorageSize() -> Int64 {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let screenshotsPath = documentsPath.appendingPathComponent("Screenshots")
        
        guard let enumerator = FileManager.default.enumerator(at: screenshotsPath, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
    
    // MARK: - Private Methods
    private func saveScreenshotHistories(_ histories: [TCScreenshotHistoryModel]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(histories) {
            userDefaults.set(data, forKey: screenshotHistoryKey)
        }
    }
}

// MARK: - 格式化存储大小
extension TCScreenshotHistoryManager {
    func formatStorageSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
} 