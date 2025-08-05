//
//  TAImageExtension.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/27.
//

import Foundation
import Photos


extension UIImage {
    func saveToAlbumWithAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        func save() {
            UIImageWriteToSavedPhotosAlbum(self, SaveHelper.shared, #selector(SaveHelper.shared.image(_:didFinishSavingWithError:contextInfo:)), nil)
            SaveHelper.shared.completion = completion
        }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)  // 只申请添加权限
        switch status {
        case .authorized, .limited:
            save()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        save()
                    } else {
                        completion(false, NSError(domain: "SaveImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "没有相册权限"]))
                    }
                }
            }
        default:
            completion(false, NSError(domain: "SaveImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "没有相册权限"]))
        }
    }
}

private class SaveHelper {
    static let shared = SaveHelper()
    
    var completion: ((Bool, Error?) -> Void)?
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            completion?(false, error)
        } else {
            completion?(true, nil)
        }
    }
}

