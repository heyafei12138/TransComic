//
//  TCWebsiteModel.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import Foundation

struct TCWebsiteModel: Codable, Equatable {
    let id: String
    let name: String
    let url: String
    let icon: String
    let createdAt: Date
    
    init(name: String, url: String, icon: String) {
        self.id = UUID().uuidString
        self.name = name
        self.url = url
        self.icon = icon
        self.createdAt = Date()
    }
    
    init(id: String, name: String, url: String, icon: String, createdAt: Date) {
        self.id = id
        self.name = name
        self.url = url
        self.icon = icon
        self.createdAt = createdAt
    }
    
    static func == (lhs: TCWebsiteModel, rhs: TCWebsiteModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, name, url, icon, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        icon = try container.decode(String.self, forKey: .icon)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(icon, forKey: .icon)
        try container.encode(createdAt, forKey: .createdAt)
    }
} 