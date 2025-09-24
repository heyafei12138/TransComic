//
//  SceneDelegate.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/8/5.
//

import UIKit
//import AppTrackingTransparency

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       
        guard let win = (scene as? UIWindowScene) else { return }
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            let onboardingVC = GuiderVC()
            self.window?.rootViewController = onboardingVC
            self.window?.makeKeyAndVisible()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            KLPayManager.shared.getGoodsInfo()

        } else {
            window = UIWindow(windowScene: win)
            window?.rootViewController = UINavigationController(rootViewController: HomeViewController())
            window?.makeKeyAndVisible()
            baseSetup()
            KLPayManager.shared.restore(loading: false)

        }
       
    }
    
    func baseSetup() {
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { center, observer, name, object, userInfo in
                guard let observer = observer else { return }
                let manager = Unmanaged<SceneDelegate>.fromOpaque(observer).takeUnretainedValue()
                manager.saveHistoryData()
            },
            "ReloadUserNumber" as CFString,
            nil,
            .deliverImmediately
        )
        saveHistoryData()
    }
    
    
    
    func saveHistoryData() {
        let userDefaults = UserDefaults(suiteName: TCGroupID) ?? .standard
        let saveKey = "translatedImageHistory"
        
        if let history = userDefaults.array(forKey: saveKey) as? [[String: Any]] {
            for entry in history {
                if let base64String = entry["imageData"] as? String,
                   let timestamp = entry["timestamp"] as? String,
                   let imageData = Data(base64Encoded: base64String)
                   {
                   
                    let history =  HomeHistoryModel(title: "快捷指令翻译", category: "指令翻译", image: UIImage(data: imageData), description: timestamp)
                        HomeHistoryManager.shared.addHistory(history)
                    
                }
            }
            userDefaults.removeObject(forKey: saveKey)
            userDefaults.synchronize()
            
        }
        
    }
    
    
    

    func sceneDidDisconnect(_ scene: UIScene) {
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            if #available(iOS 14.0, *) {
//                ATTrackingManager.requestTrackingAuthorization { status in
//                    if status == .authorized {
//                        
//                    } else {
//                        
//                    }
//                }
//            }else {
//                
//            }
//        }
    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {
   
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
       
    }


}

