//
//  UIVCExtension.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/12.
//

import Foundation
extension UIViewController {
    
    // Present a view controller from a specified storyboard
    func presentViewCon(storyboard name: String) {
        // Instantiate the initial view controller from the given storyboard
        let sb = UIStoryboard(name: name, bundle: nil)
        presentViewCon(sb.instantiateInitialViewController()!)
    }
    
    // Present a given view controller
    func presentViewCon(_ viewCon: UIViewController) {
        // For iOS 13 and later, set the modal presentation style to full screen
        if #available(iOS 13, *) {
            viewCon.modalPresentationStyle = .fullScreen
        }
        // Present the view controller with animation
        present(viewCon, animated: true)
    }
    
    // Push a view controller from a specified storyboard onto the navigation stack
    func pushViewCon(storyboard name: String) {
        // Instantiate the initial view controller from the given storyboard
        let sb = UIStoryboard(name: name, bundle: nil)
        pushViewCon(sb.instantiateInitialViewController()!)
    }
    
    // Push a given view controller onto the navigation stack
    func pushViewCon(_ viewCon: UIViewController) {
        // Check if the current view controller is a UINavigationController
        if let nav = self as? UINavigationController {
            // If yes, push the view controller directly onto the navigation stack
            nav.pushViewController(viewCon, animated: true)
            return
        }
        viewCon.hidesBottomBarWhenPushed = true
        // If not, use the navigation controller of the current view controller to push
        navigationController?.pushViewController(viewCon, animated: true)
    }
    
    func pushViewCon(_ viewCon: UIViewController,animat: Bool = true) {
        // Check if the current view controller is a UINavigationController
        if let nav = self as? UINavigationController {
            // If yes, push the view controller directly onto the navigation stack
            nav.pushViewController(viewCon, animated: animat)
            return
        }
        viewCon.hidesBottomBarWhenPushed = true
        // If not, use the navigation controller of the current view controller to push
        navigationController?.pushViewController(viewCon, animated: animat)
    }
    
    // Pop the top view controller from the navigation stack
    func popViewCon(_ animated: Bool = true) {
        // Check if the current view controller is a UINavigationController
        if let nav = self as? UINavigationController {
            // If yes, pop the top view controller from the navigation stack
            nav.popViewController(animated: animated)
        } else {
            // If not, use the navigation controller of the current view controller to pop
            navigationController?.popViewController(animated: animated)
        }
    }
    
    // Pop all view controllers and return to the root view controller
    func popToRootViewCon() {
        // Check if the current view controller is a UINavigationController
        if let nav = self as? UINavigationController {
            // If yes, pop to the root view controller of the navigation stack
            nav.popToRootViewController(animated: true)
        } else {
            // If not, use the navigation controller of the current view controller to pop to the root
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // Pop to a specific view controller in the navigation stack
    func popToViewCon(_ viewCon: UIViewController) {
        DispatchQueue.main.async(execute: {
            // Check if the current view controller is a UINavigationController
            if let nav = self as? UINavigationController {
                // If yes, pop to the specified view controller
                nav.popToViewController(viewCon, animated: true)
            } else {
                // If not, use the navigation controller of the current view controller to pop to the specified view controller
                self.navigationController?.popToViewController(viewCon, animated: true)
            }
        })
    }
    /// 递归查找当前视图层级中的第一响应者
    func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        for subview in view.subviews {
            if let responder = findFirstResponder(in: subview) {
                return responder
            }
        }
        return nil
    }
    @objc func shareAny(_ object: Any) {
        
        
        // 创建分享内容
        let items: [Any] = [object]
        
        // 初始化 UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // 设置分享的排除项（可选）
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .print]
        
        // 在 iPad 上指定展示位置（避免崩溃）
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                print("分享成功")
            }
        }
        // 显示分享视图控制器
        present(activityViewController, animated: true) {
        }
    }
}
