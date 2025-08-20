//
//  Const.swift
//  TranslationAnime
//
//  Created by 贺亚飞 on 2025/7/25.
//

import Foundation
import UIKit

@_exported import JKSwiftExtension
@_exported import SnapKit
@_exported import Localize_Swift

let kScreenW = UIScreen.main.bounds.width
let kScreenH = UIScreen.main.bounds.height


let kStatusBarHeight = jk_kStatusBarFrameH
let kNavHeight = 44 + kStatusBarHeight
// MARK: - 底部安全区域高度和tabbar的高度
public var kBottomSafeHeight : CGFloat {
    if #available(iOS 11.0, *) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first {
            let insets = keyWindow.safeAreaInsets
            return insets.bottom > 0 ? insets.bottom : 0
        }
    }
    return 0
}
let kTabbarHeightWithSafe = jk_kTabbarFrameH
// MARK: - 除去导航条和tabbar的高度
let kNormalViewHieght = kScreenH - kNavHeight - kTabbarHeightWithSafe
let kNormalViewNoTabHeight = kScreenH - kNavHeight - kBottomSafeHeight
let kisIphoneX = kScreenH > 667

let kWindow = UIApplication.jk.keyWindow
let kTopVC = UIViewController.jk.topViewController()

let mainColor = UIColor.hexString("#9C86FD")
let LmainColor = UIColor.hexString("#BFAEFF")
let black  = UIColor.hexString("#333333")
