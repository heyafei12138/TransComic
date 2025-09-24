//
//  TCStorageManager.swift
//  TransComic
//
//  Created by hebert on 2025/8/11.
//

import Foundation
class StorageManager: NSObject {
    
    public static let shared = StorageManager()
    
    //是否首次启动
    @Storage(key: "isFirstBoot", defaultValue: true)
    var isFirstBoot:Bool
    
  
    //购买过期时间戳(秒)
    @Storage(key: "vipExpirationTimestamp", defaultValue: 0)
    var vipExpirationTimestamp:Int
    
    
    //是否享受vip
    var isVipValid:Bool {
        //获取当前时间戳
        let timeInterval = Date().timeIntervalSince1970
        let currTime = Int(timeInterval)
        let userDefaults = UserDefaults(suiteName: TCGroupID) ?? .standard

        let vip = (vipExpirationTimestamp > currTime)
        userDefaults.set(vip, forKey: "isVipValid")
        userDefaults.synchronize()
//        return true
        return vip
    }
}
