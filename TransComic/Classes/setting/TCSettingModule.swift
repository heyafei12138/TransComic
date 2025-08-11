//
//  TCSettingModule.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import UIKit

class TCSettingModule {
    
    static let shared = TCSettingModule()
    
    private init() {}
    
    // MARK: - Main Setting View Controller
    func getMainSettingViewController() -> TCSettingViewController {
        return TCSettingViewController()
    }
    
    // MARK: - About View Controller
    func getAboutViewController() -> TCAboutViewController {
        return TCAboutViewController()
    }
    
    // MARK: - Web View Controller
    func getWebViewController(title: String, urlString: String) -> TCWebViewController {
        return TCWebViewController(title: title, urlString: urlString)
    }
    
    // MARK: - Language Management
    func getCurrentLanguage() -> String {
        return TCLanguageManager.shared.currentLanguage
    }
    
    func changeLanguage(to languageCode: String, completion: @escaping (Bool) -> Void) {
        TCLanguageManager.shared.changeLanguage(to: languageCode, completion: completion)
    }
    
    func getAvailableLanguages() -> [(name: String, code: String, flag: String)] {
        return TCLanguageManager.shared.availableLanguages
    }
    
    // MARK: - Cache Management
    func getCacheSize() -> String {
        return TCCacheManager.shared.getCacheSize()
    }
    
    func clearAllCache(completion: @escaping (Bool, String) -> Void) {
        TCCacheManager.shared.clearAllCache(completion: completion)
    }
    
    // MARK: - App Information
    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    func getAppName() -> String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "TransComic"
    }
    
    func getAppBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier ?? "com.transcomic.app"
    }
    
    // MARK: - Quick Actions
    func openAppStoreRating() {
        let appStoreURL = "https://apps.apple.com/app/transcomic/id123456789"
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func shareApp() -> UIActivityViewController {
        let appName = getAppName()
        let appDescription = "一款强大的翻译工具，支持动漫翻译、网页翻译、图片识别等多种功能"
        let appStoreURL = "https://apps.apple.com/app/transcomic/id123456789"
        
        let shareText = "\(appName)\n\(appDescription)\n下载地址：\(appStoreURL)"
        
        return UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
    }
    
    // MARK: - Settings Validation
    func validateSettings() -> [String: Any] {
        var validation = [String: Any]()
        
        // 语言设置验证
        validation["language"] = [
            "current": getCurrentLanguage(),
            "available": getAvailableLanguages().map { $0.code },
            "isValid": getAvailableLanguages().contains { $0.code == getCurrentLanguage() }
        ]
        
        // 缓存设置验证
        validation["cache"] = [
            "size": getCacheSize(),
            "canClear": true
        ]
        
        // 应用信息验证
        validation["app"] = [
            "name": getAppName(),
            "version": getAppVersion(),
            "bundleId": getAppBundleIdentifier()
        ]
        
        return validation
    }
    
    // MARK: - Reset Settings
    func resetAllSettings() {
        // 重置语言设置
        TCLanguageManager.shared.resetToSystemLanguage()
        
        // 清除缓存
        TCCacheManager.shared.clearAllCache { success, message in
            print("Cache cleared: \(success), \(message)")
        }
        
        // 重置其他设置
        UserDefaults.standard.removeObject(forKey: "AppLanguage")
        UserDefaults.standard.synchronize()
        
        // 发送重置通知
        NotificationCenter.default.post(name: .settingsDidReset, object: nil)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let settingsDidReset = Notification.Name("SettingsDidReset")
}
