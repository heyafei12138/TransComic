//
//  TCCacheManager.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import Foundation
import UIKit

class TCCacheManager {
    
    static let shared = TCCacheManager()
    
    private init() {}
    
    // MARK: - Cache Size Calculation
    func getCacheSize() -> String {
        let totalSize = getImageCacheSize() + getWebCacheSize() + getTempFileSize()
        return formatFileSize(totalSize)
    }
    
    private func getImageCacheSize() -> Int64 {
        let imageCachePath = getImageCacheDirectory()
        return getDirectorySize(imageCachePath)
    }
    
    private func getWebCacheSize() -> Int64 {
        let webCachePath = getWebCacheDirectory()
        return getDirectorySize(webCachePath)
    }
    
    private func getTempFileSize() -> Int64 {
        let tempPath = NSTemporaryDirectory()
        return getDirectorySize(tempPath)
    }
    
    private func getDirectorySize(_ path: String) -> Int64 {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(atPath: path) else {
            return 0
        }
        
        for case let fileName as String in enumerator {
            let filePath = (path as NSString).appendingPathComponent(fileName)
            
            do {
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                if let fileSize = attributes[.size] as? Int64 {
                    totalSize += fileSize
                }
            } catch {
                print("Error getting file size for \(filePath): \(error)")
            }
        }
        
        return totalSize
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    // MARK: - Cache Directories
    private func getImageCacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDirectory = paths[0]
        return (cacheDirectory as NSString).appendingPathComponent("ImageCache")
    }
    
    private func getWebCacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDirectory = paths[0]
        return (cacheDirectory as NSString).appendingPathComponent("WebCache")
    }
    
    // MARK: - Clear Cache
    func clearAllCache(completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var success = true
            var errorMessage = ""
            
            // 清除图片缓存
            if !self.clearImageCache() {
                success = false
                errorMessage += "图片缓存清除失败; "
            }
            
            // 清除网页缓存
            if !self.clearWebCache() {
                success = false
                errorMessage += "网页缓存清除失败; "
            }
            
            // 清除临时文件
            if !self.clearTempFiles() {
                success = false
                errorMessage += "临时文件清除失败; "
            }
            
            // 清除系统缓存
            self.clearSystemCache()
            
            DispatchQueue.main.async {
                if success {
                    completion(true, "缓存清除成功")
                } else {
                    completion(false, errorMessage)
                }
            }
        }
    }
    
    private func clearImageCache() -> Bool {
        let imageCachePath = getImageCacheDirectory()
        return clearDirectory(imageCachePath)
    }
    
    private func clearWebCache() -> Bool {
        let webCachePath = getWebCacheDirectory()
        return clearDirectory(webCachePath)
    }
    
    private func clearTempFiles() -> Bool {
        let tempPath = NSTemporaryDirectory()
        return clearDirectory(tempPath)
    }
    
    private func clearDirectory(_ path: String) -> Bool {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for fileName in contents {
                let filePath = (path as NSString).appendingPathComponent(fileName)
                try fileManager.removeItem(atPath: filePath)
            }
            return true
        } catch {
            print("Error clearing directory \(path): \(error)")
            return false
        }
    }
    
    private func clearSystemCache() {
        // 清除URLCache
        URLCache.shared.removeAllCachedResponses()
        
        // 清除WKWebView缓存（如果可能）
//        if #available(iOS 9.0, *) {
//            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
//            WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date(timeIntervalSince1970: 0)) {
//                print("WKWebView cache cleared")
//            }
//        }
    }
    
    // MARK: - Create Cache Directories
    func createCacheDirectoriesIfNeeded() {
        let imageCachePath = getImageCacheDirectory()
        let webCachePath = getWebCacheDirectory()
        
        createDirectoryIfNeeded(imageCachePath)
        createDirectoryIfNeeded(webCachePath)
    }
    
    private func createDirectoryIfNeeded(_ path: String) {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory \(path): \(error)")
            }
        }
    }
}
