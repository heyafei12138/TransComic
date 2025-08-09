import Foundation
import UIKit

struct HomeHistoryModel: Codable, Equatable {
    let id: String
    let title: String
    let category: String
    let imagePath: String?
    let createdAt: Date
    let description: String
    
    init(title: String, category: String, image: UIImage? = nil, description: String) {
        self.id = UUID().uuidString
        self.title = title
        self.category = category
        self.description = description
        self.createdAt = Date()
        
        // 保存图片到本地
        if let image = image {
            self.imagePath = Self.saveImageToLocal(image, id: self.id)
        } else {
            self.imagePath = nil
        }
    }
    
    init(id: String, title: String, category: String, imagePath: String?, createdAt: Date, description: String) {
        self.id = id
        self.title = title
        self.category = category
        self.imagePath = imagePath
        self.createdAt = createdAt
        self.description = description
    }
    
    static func == (lhs: HomeHistoryModel, rhs: HomeHistoryModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Public Methods
    func getImage() -> UIImage? {
        guard let imagePath = imagePath else { return nil }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let historyPath = documentsPath.appendingPathComponent("HomeHistory")
        let fullPath = historyPath.appendingPathComponent(imagePath)
        
        return UIImage(contentsOfFile: fullPath.path)
    }
    
    func deleteLocalFiles() {
        guard let imagePath = imagePath else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let historyPath = documentsPath.appendingPathComponent("HomeHistory")
        let fullPath = historyPath.appendingPathComponent(imagePath)
        
        try? FileManager.default.removeItem(at: fullPath)
    }
    
    // MARK: - Private Methods
    private static func saveImageToLocal(_ image: UIImage, id: String) -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let historyPath = documentsPath.appendingPathComponent("HomeHistory")
        
        // 创建目录
        try? FileManager.default.createDirectory(at: historyPath, withIntermediateDirectories: true)
        
        let imageName = "history_\(id).jpg"
        let imagePath = historyPath.appendingPathComponent(imageName)
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: imagePath)
            return imageName
        }
        
        return ""
    }
} 