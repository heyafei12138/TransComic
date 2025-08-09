//
//  TCScreenshotHistoryModel.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import Foundation
import UIKit

struct TCScreenshotHistoryModel: Codable, Equatable {
    let id: String
    let title: String
    let category: String
    let imageCount: Int
    let createdAt: Date
    let websiteURL: String
    var thumbnailPath: String
    var imagePaths: [String]
    
    init(title: String, category: String, websiteURL: String, images: [UIImage]) {
        let id = UUID().uuidString
        let (thumbnailPath, imagePaths) = Self.saveImagesToLocal(id: id, images: images)
        
        self.id = id
        self.title = title
        self.category = category
        self.imageCount = images.count
        self.createdAt = Date()
        self.websiteURL = websiteURL
        self.thumbnailPath = thumbnailPath
        self.imagePaths = imagePaths
    }
    
    init(id: String, title: String, category: String, imageCount: Int, createdAt: Date, websiteURL: String, thumbnailPath: String, imagePaths: [String]) {
        self.id = id
        self.title = title
        self.category = category
        self.imageCount = imageCount
        self.createdAt = createdAt
        self.websiteURL = websiteURL
        self.thumbnailPath = thumbnailPath
        self.imagePaths = imagePaths
    }
    
    static func == (lhs: TCScreenshotHistoryModel, rhs: TCScreenshotHistoryModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Private Methods
    private static func saveImagesToLocal(id: String, images: [UIImage]) -> (thumbnailPath: String, imagePaths: [String]) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let screenshotsPath = documentsPath.appendingPathComponent("Screenshots")
        
        // 创建目录
        try? FileManager.default.createDirectory(at: screenshotsPath, withIntermediateDirectories: true)
        
        let historyPath = screenshotsPath.appendingPathComponent(id)
        try? FileManager.default.createDirectory(at: historyPath, withIntermediateDirectories: true)
        
        var savedPaths: [String] = []
        var thumbnailPath = ""
        
        for (index, image) in images.enumerated() {
            let imageName = "screenshot_\(index).jpg"
            let imagePath = historyPath.appendingPathComponent(imageName)
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                try? imageData.write(to: imagePath)
                savedPaths.append(imagePath.lastPathComponent)
            }
        }
        
        // 生成缩略图
        if let firstImage = images.first {
            let thumbnail = firstImage.resized(to: CGSize(width: 200, height: 200))
            let thumbnailFilePath = historyPath.appendingPathComponent("thumbnail.jpg")
            
            if let thumbnailData = thumbnail.jpegData(compressionQuality: 0.6) {
                try? thumbnailData.write(to: thumbnailFilePath)
                thumbnailPath = thumbnailFilePath.lastPathComponent
            }
        }
        
        return (thumbnailPath: thumbnailPath, imagePaths: savedPaths)
    }
    
    // MARK: - Public Methods
    func getThumbnailImage() -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let screenshotsPath = documentsPath.appendingPathComponent("Screenshots")
        let historyPath = screenshotsPath.appendingPathComponent(id)
        let thumbnailFilePath = historyPath.appendingPathComponent(thumbnailPath)
        
        return UIImage(contentsOfFile: thumbnailFilePath.path)
    }
    
    func getImages() -> [UIImage] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let screenshotsPath = documentsPath.appendingPathComponent("Screenshots")
        let historyPath = screenshotsPath.appendingPathComponent(id)
        
        var images: [UIImage] = []
        
        for imagePath in imagePaths {
            let fullPath = historyPath.appendingPathComponent(imagePath)
            if let image = UIImage(contentsOfFile: fullPath.path) {
                images.append(image)
            }
        }
        
        return images
    }
    
    func deleteLocalFiles() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let screenshotsPath = documentsPath.appendingPathComponent("Screenshots")
        let historyPath = screenshotsPath.appendingPathComponent(id)
        
        try? FileManager.default.removeItem(at: historyPath)
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
} 
