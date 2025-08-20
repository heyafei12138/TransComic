//
//  TCSettingItem.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import Foundation

enum TCSettingType {
    case language
    case clearCache
    case share
    case rate
    case feedback
    case privacy
    case terms
    case about
    case vip
}

struct TCSettingItem {
    let title: String
    let subtitle: String
    let icon: String
    let type: TCSettingType
    var isEnabled: Bool = true
    var showArrow: Bool = true
}
