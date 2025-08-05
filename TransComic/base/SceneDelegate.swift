//
//  SceneDelegate.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/8/5.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let win = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: win)
        window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
        window?.makeKeyAndVisible()
    }
    
    
    
    
    
    
    
    
    

    func sceneDidDisconnect(_ scene: UIScene) {
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {
   
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
       
    }


}

