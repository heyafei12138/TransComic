//
//  WebViewExtension.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/25.
//

import Foundation
import WebKit
extension WKWebView {
    func captureVisibleSnapshot(completion: @escaping (UIImage?) -> Void) {
        let config = WKSnapshotConfiguration()
        config.afterScreenUpdates = true  // 让截图更精准

        self.takeSnapshot(with: config) { image, error in
            if let error = error {
                print("截图失败: \(error)")
                completion(nil)
            } else {
                completion(image)
                print("截图成功\(image!.size.width),\(image!.size.height)")
            }
        }
    }
}
