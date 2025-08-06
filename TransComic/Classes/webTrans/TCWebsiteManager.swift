//
//  TCWebsiteManager.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import Foundation

class TCWebsiteManager {
    static let shared = TCWebsiteManager()
    
    private let userDefaults = UserDefaults.standard
    private let favoriteWebsitesKey = "TCFavoriteWebsites"
    private let historyWebsitesKey = "TCHistoryWebsites"
    private let maxHistoryCount = 50
    
    private init() {}
    
    // MARK: - Favorite Websites
    func addFavoriteWebsite(_ website: TCWebsiteModel) {
        var favorites = getFavoriteWebsites()
        
        // 检查是否已存在
        if !favorites.contains(website) {
            favorites.append(website)
            saveFavoriteWebsites(favorites)
        }
    }
    
    func removeFavoriteWebsite(_ website: TCWebsiteModel) {
        var favorites = getFavoriteWebsites()
        favorites.removeAll { $0.id == website.id }
        saveFavoriteWebsites(favorites)
    }
    
    func getFavoriteWebsites() -> [TCWebsiteModel] {
        guard let data = userDefaults.data(forKey: favoriteWebsitesKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let websites = try? decoder.decode([TCWebsiteModel].self, from: data) else {
            return []
        }
        return websites.sorted { $0.createdAt > $1.createdAt }
    }
    
    func isFavoriteWebsite(_ website: TCWebsiteModel) -> Bool {
        let favorites = getFavoriteWebsites()
        return favorites.contains { $0.id == website.id }
    }
    
    func isFavoriteWebsiteByURL(_ url: String) -> Bool {
        let favorites = getFavoriteWebsites()
        return favorites.contains { $0.url == url }
    }
    
    private func saveFavoriteWebsites(_ websites: [TCWebsiteModel]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(websites) {
            userDefaults.set(data, forKey: favoriteWebsitesKey)
        }
    }
    
    // MARK: - History Websites
    func addHistoryWebsite(_ website: TCWebsiteModel) {
        var history = getHistoryWebsites()
        
        // 移除已存在的相同URL的历史记录（去重）
        history.removeAll { $0.url == website.url }
        
        // 添加到开头（最新的在最前面）
        history.insert(website, at: 0)
        
        // 限制历史记录数量
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        saveHistoryWebsites(history)
    }
    
    func addHistoryWebsiteWithUpdate(_ website: TCWebsiteModel) {
        var history = getHistoryWebsites()
        
        // 查找是否已存在相同URL的记录
        if let existingIndex = history.firstIndex(where: { $0.url == website.url }) {
            // 如果存在，更新现有记录的信息（保留原有ID，更新名称和时间）
            var updatedWebsite = website
            updatedWebsite = TCWebsiteModel(
                id: history[existingIndex].id,
                name: website.name,
                url: website.url,
                icon: website.icon,
                createdAt: Date()
            )
            
            // 移除旧记录
            history.remove(at: existingIndex)
            
            // 添加到开头
            history.insert(updatedWebsite, at: 0)
            
            print("📝 更新历史记录: \(website.name) (\(website.url))")
        } else {
            // 如果不存在，直接添加
            history.insert(website, at: 0)
            print("📝 添加新历史记录: \(website.name) (\(website.url))")
        }
        
        // 限制历史记录数量
        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }
        
        saveHistoryWebsites(history)
    }
    
    func removeHistoryWebsite(_ website: TCWebsiteModel) {
        var history = getHistoryWebsites()
        history.removeAll { $0.id == website.id }
        saveHistoryWebsites(history)
    }
    
    func clearHistoryWebsites() {
        saveHistoryWebsites([])
    }
    
    func cleanDuplicateHistoryWebsites() {
        var history = getHistoryWebsites()
        
        // 使用URL作为唯一标识符去重，保留最新的记录
        var uniqueWebsites: [TCWebsiteModel] = []
        var seenURLs: Set<String> = []
        
        for website in history {
            if !seenURLs.contains(website.url) {
                uniqueWebsites.append(website)
                seenURLs.insert(website.url)
            }
        }
        
        saveHistoryWebsites(uniqueWebsites)
    }
    
    func getHistoryWebsites() -> [TCWebsiteModel] {
        guard let data = userDefaults.data(forKey: historyWebsitesKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let websites = try? decoder.decode([TCWebsiteModel].self, from: data) else {
            return []
        }
        return websites
    }
    
    private func saveHistoryWebsites(_ websites: [TCWebsiteModel]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(websites) {
            userDefaults.set(data, forKey: historyWebsitesKey)
        }
    }
    
    // MARK: - URL Processing
    func processURL(_ urlString: String) -> String {
        var processedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 如果没有协议，添加https://
        if !processedURL.hasPrefix("http://") && !processedURL.hasPrefix("https://") {
            processedURL = "https://" + processedURL
        }
        
        return processedURL
    }
} 