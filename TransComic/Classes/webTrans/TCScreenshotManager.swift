//
//  TCScreenshotManager.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit
import WebKit

protocol TCScreenshotManagerDelegate: AnyObject {
    func screenshotManager(_ manager: TCScreenshotManager, didCompleteScreenshots images: [UIImage])
    func screenshotManager(_ manager: TCScreenshotManager, didFailWithError error: Error)
    func screenshotManager(_ manager: TCScreenshotManager, didUpdateProgress progress: Float)
}

class TCScreenshotManager: NSObject {
    
    // MARK: - Properties
    weak var delegate: TCScreenshotManagerDelegate?
    private var webView: WKWebView
    private var screenshots: [UIImage] = []
    private var currentPage = 0
    private var totalPages = 0
    private var isCapturing = false
    
    // MARK: - Initialization
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
    
    // MARK: - Public Methods
    func startPageScreenshot() {
        guard !isCapturing else { return }
        isCapturing = true
        screenshots.removeAll()
        currentPage = 0
        
        // 显示加载提示
        showLoadingIndicator()
        
        // 获取网页总高度
        getWebPageHeight { [weak self] totalHeight in
            guard let self = self else { return }
            
            let screenHeight = UIScreen.main.bounds.height - self.getWebViewVisibleHeight()
            self.totalPages = Int(ceil(Double(totalHeight) / Double(screenHeight)))
            
            print("📸 开始分页截屏: 总高度 \(totalHeight), 屏幕高度 \(screenHeight), 总页数 \(self.totalPages)")
            
            // 开始截屏
            self.captureNextPage()
        }
    }
    
    // MARK: - Private Methods
    private func getWebPageHeight(completion: @escaping (CGFloat) -> Void) {
        let script = """
        Math.max(
            document.body.scrollHeight,
            document.body.offsetHeight,
            document.documentElement.clientHeight,
            document.documentElement.scrollHeight,
            document.documentElement.offsetHeight
        );
        """
        
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("❌ 获取网页高度失败: \(error)")
                completion(0)
                return
            }
            
            if let height = result as? CGFloat {
                completion(height)
            } else {
                completion(0)
            }
        }
    }
    
    private func getWebViewVisibleHeight() -> CGFloat {
        // 计算WebView的可见高度（减去导航栏和工具栏）
        let navHeight = kNavHeight
        let toolbarHeight = 50 + kBottomSafeHeight
        return UIScreen.main.bounds.height - navHeight - toolbarHeight
    }
    
    private func captureNextPage() {
        guard currentPage < totalPages else {
            // 截屏完成
            completeScreenshot()
            return
        }
        
        let screenHeight = getWebViewVisibleHeight()
        let scrollY = CGFloat(currentPage) * screenHeight
        
        // 滚动到指定位置
        scrollToPosition(scrollY) { [weak self] in
            guard let self = self else { return }
            
            // 等待页面稳定后截屏
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.captureCurrentPage()
            }
        }
    }
    
    private func scrollToPosition(_ y: CGFloat, completion: @escaping () -> Void) {
        let script = "window.scrollTo(0, \(y));"
        webView.evaluateJavaScript(script) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                completion()
            }
        }
    }
    
    private func captureCurrentPage() {
        // 使用WKWebView的截图方法
        let config = WKSnapshotConfiguration()
        config.rect = webView.bounds
        
        webView.takeSnapshot(with: config) { [weak self] image, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ 截屏失败: \(error)")
                self.delegate?.screenshotManager(self, didFailWithError: error)
                return
            }
            
            if let image = image {
                self.screenshots.append(image)
                print("📸 截屏成功: 第 \(self.currentPage + 1) 页")
                
                // 更新进度
                let progress = Float(self.currentPage + 1) / Float(self.totalPages)
                self.delegate?.screenshotManager(self, didUpdateProgress: progress)
                
                self.currentPage += 1
                self.captureNextPage()
            }
        }
    }
    
    private func completeScreenshot() {
        isCapturing = false
        hideLoadingIndicator()
        
        print("✅ 分页截屏完成: 共 \(screenshots.count) 张图片")
        
        // 滚动回顶部
        scrollToPosition(0) { [weak self] in
            guard let self = self else { return }
            self.delegate?.screenshotManager(self, didCompleteScreenshots: self.screenshots)
        }
    }
    
    private func showLoadingIndicator() {
        // 在WebView上显示加载指示器
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        loadingView.tag = 999
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor.white
        indicator.startAnimating()
        
        let label = UILabel()
        label.text = "正在截屏..."
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        
        loadingView.addSubview(indicator)
        loadingView.addSubview(label)
        
        webView.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(indicator.snp.bottom).offset(10)
        }
    }
    
    private func hideLoadingIndicator() {
        webView.viewWithTag(999)?.removeFromSuperview()
    }
}

// MARK: - 扩展：保存截屏图片
extension TCScreenshotManager {
    
    func saveScreenshotsToPhotos(_ images: [UIImage], completion: @escaping (Bool, Error?) -> Void) {
        guard !images.isEmpty else {
            completion(false, NSError(domain: "TCScreenshotManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "没有图片可保存"]))
            return
        }
        
        // 检查相册权限
        checkPhotoLibraryPermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                self.performSaveToPhotos(images, completion: completion)
            } else {
                completion(false, NSError(domain: "TCScreenshotManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "没有相册访问权限"]))
            }
        }
    }
    
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        // 这里需要根据实际项目添加相册权限检查
        // 暂时返回true，实际使用时需要实现权限检查
        completion(true)
    }
    
    private func performSaveToPhotos(_ images: [UIImage], completion: @escaping (Bool, Error?) -> Void) {
        // 这里需要根据实际项目实现保存到相册的功能
        // 暂时模拟保存成功
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("💾 保存截屏到相册: \(images.count) 张图片")
            completion(true, nil)
        }
    }
} 