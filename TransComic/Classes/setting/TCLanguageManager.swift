//
//  TCLanguageManager.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import Foundation
import UIKit

class TCLanguageManager {
    
    static let shared = TCLanguageManager()
    
    private let languageKey = "AppLanguage"
    private let bundleKey = "AppleLanguages"
    
    private init() {}
    
    // MARK: - Current Language
    var currentLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: languageKey) ?? getSystemLanguage()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: languageKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private func getSystemLanguage() -> String {
        let language = Locale.current.languageCode ?? "en"
        return language
    }
    
    // MARK: - Available Languages
    var availableLanguages: [(name: String, code: String, flag: String)] {
        return [
            ("简体中文", "zh-Hans", "🇨🇳"),
            ("繁體中文", "zh-HK", "🇨🇳"),
            ("English", "en", "🇺🇸"),
            ("日本語", "ja", "🇯🇵"),
            ("한국어", "ko", "🇰🇷"),
            ("Français", "fr", "🇫🇷"),
            ("Deutsch", "de", "🇩🇪"),
            ("Español", "es", "🇪🇸"),
            ("Italiano", "it", "🇮🇹")
        ]
    }
    
    // MARK: - Language Display
    func getLanguageDisplayName(for code: String) -> String {
        if let language = availableLanguages.first(where: { $0.code == code }) {
            return language.name
        }
        return code.uppercased()
    }
    
    func getLanguageFlag(for code: String) -> String {
        if let language = availableLanguages.first(where: { $0.code == code }) {
            return language.flag
        }
        return "🌐"
    }
    
    // MARK: - Language Change
    func changeLanguage(to languageCode: String, completion: @escaping (Bool) -> Void) {
        guard availableLanguages.contains(where: { $0.code == languageCode }) else {
            completion(false)
            return
        }
        Localize.setCurrentLanguage(languageCode)
        // 保存新语言设置
        currentLanguage = languageCode
        
        // 更新系统语言设置
        UserDefaults.standard.set([languageCode], forKey: bundleKey)
        UserDefaults.standard.synchronize()
        
        // 通知语言变化
        NotificationCenter.default.post(name: .languageDidChange, object: languageCode)
        
        completion(true)
    }
    
    // MARK: - Localized String
    func localizedString(for key: String, comment: String = "") -> String {
        let language = currentLanguage
        let bundle = getBundle(for: language)
        
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }
    
    private func getBundle(for language: String) -> Bundle {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
    
    // MARK: - Reset to System Language
    func resetToSystemLanguage() {
        let systemLanguage = getSystemLanguage()
        changeLanguage(to: systemLanguage) { _ in
            print("Language reset to system language: \(systemLanguage)")
        }
    }
    
    // MARK: - Language Info
    func getLanguageInfo() -> [String: Any] {
        return [
            "current": currentLanguage,
            "system": getSystemLanguage(),
            "available": availableLanguages.map { $0.code },
            "lastChanged": UserDefaults.standard.object(forKey: "LanguageLastChanged") ?? Date()
        ]
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChange")
}

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return TCLanguageManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        let localizedString = TCLanguageManager.shared.localizedString(for: self)
        return String(format: localizedString, arguments: arguments)
    }
}
