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
    
    //是否是会员
    @Storage(key: "isvipUser", defaultValue: true)
    var isvipUser:Bool
}
