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
        
        // 移除已存在的相同网站
        history.removeAll { $0.url == website.url }
        
        // 添加到开头
        history.insert(website, at: 0)
        
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