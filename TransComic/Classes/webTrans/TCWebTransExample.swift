//
//  TCWebTransExample.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

/// 网页翻译模块使用示例
class TCWebTransExample {
    
    /// 示例：在TabBar中添加网页翻译功能
    static func addWebTransToTabBar(tabBarController: UITabBarController) {
        let webTransVC = TCWebTransModule.getHomeViewController()
        webTransVC.tabBarItem = UITabBarItem(
            title: "网页翻译",
            image: UIImage(systemName: "globe"),
            selectedImage: UIImage(systemName: "globe.fill")
        )
        
        let navigationController = UINavigationController(rootViewController: webTransVC)
        tabBarController.addChild(navigationController)
    }
    
    /// 示例：在设置页面中添加网页翻译入口
    static func addWebTransToSettings(settingsViewController: UIViewController) {
        let webTransButton = UIButton(type: .system)
        webTransButton.setTitle("网页翻译", for: .normal)
        webTransButton.addTarget(self, action: #selector(openWebTrans), for: .touchUpInside)
        
        // 添加到设置页面
        // settingsViewController.view.addSubview(webTransButton)
    }
    
    /// 示例：打开网页翻译
    @objc static func openWebTrans() {
        guard let topVC = UIViewController.jk.topViewController() else { return }
        
        let webTransVC = TCWebTransModule.getHomeViewController()
        let navigationController = UINavigationController(rootViewController: webTransVC)
        topVC.present(navigationController, animated: true)
    }
    
    /// 示例：直接打开特定网址
    static func openSpecificWebsite(url: String, from viewController: UIViewController) {
        let detailVC = TCWebTransModule.getDetailViewController(url: url)
        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    /// 示例：获取统计数据
    static func getWebTransStats() -> [String: Any] {
        return [
            "favoriteCount": TCWebTransModule.getFavoriteCount(),
            "historyCount": TCWebTransModule.getHistoryCount()
        ]
    }
    
    /// 示例：检查网址是否已收藏
    static func isWebsiteFavorited(url: String) -> Bool {
        return TCWebsiteManager.shared.isFavoriteWebsiteByURL(url)
    }
    
    /// 示例：清理数据
    static func cleanData() {
        TCWebTransModule.cleanDuplicateHistory()
    }
}

/// 扩展：为现有控制器添加网页翻译功能
extension UIViewController {
    
    /// 打开网页翻译首页
    func openWebTransHome() {
        let webTransVC = TCWebTransModule.getHomeViewController()
        navigationController?.pushViewController(webTransVC, animated: true)
    }
    
    /// 打开特定网址
    func openWebsite(url: String) {
        let detailVC = TCWebTransModule.getDetailViewController(url: url)
        navigationController?.pushViewController(detailVC, animated: true)
    }
} 
