//
//  TCScreenshotManager.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit
import WebKit
import Photos

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
    var parentView: UIView!

    // MARK: - Initialization
    init(webView: WKWebView, parentView: UIView) {
        self.webView = webView
        self.parentView = parentView
        super.init()
    }
    
    // MARK: - Public Methods
    func startPageScreenshot() {
        guard !isCapturing else { return }
        isCapturing = true
        screenshots.removeAll()
        currentPage = 0
        
        showLoadingIndicator()
        
        getWebPageHeight { [weak self] totalHeight in
            guard let self = self else { return }
            
            let screenHeight = UIScreen.main.bounds.height - self.getWebViewVisibleHeight()
            self.totalPages = Int(ceil(Double(totalHeight) / Double(screenHeight)))
            
            print("📸 开始分页截屏: 总高度 \(totalHeight), 屏幕高度 \(screenHeight), 总页数 \(self.totalPages)")
            
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
        let navHeight = kNavHeight
        let toolbarHeight = 50 + kBottomSafeHeight
        return UIScreen.main.bounds.height - navHeight - toolbarHeight
    }
    
    private func captureNextPage() {
        guard isCapturing else { return }

        guard currentPage < totalPages else {
            completeScreenshot()
            return
        }
        
        let screenHeight = getWebViewVisibleHeight()
        let scrollY = CGFloat(currentPage) * screenHeight
        
        scrollToPosition(scrollY) { [weak self] in
            guard let self = self else { return }
            
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
        guard isCapturing else { return }

        let config = WKSnapshotConfiguration()
        config.rect = webView.bounds
        
        webView.takeSnapshot(with: config) { [weak self] image, error in
            guard let self = self else { return }
            guard self.isCapturing else { return }

            if let error = error {
                print("❌ 截屏失败: \(error)")
                self.delegate?.screenshotManager(self, didFailWithError: error)
                return
            }
            
            if let image = image {
                self.screenshots.append(image)
                print("📸 截屏成功: 第 \(self.currentPage + 1) 页")
                
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
        
        scrollToPosition(0) { [weak self] in
            guard let self = self else { return }
            self.delegate?.screenshotManager(self, didCompleteScreenshots: self.screenshots)
        }
    }

    // MARK: - Loading View
    private func showLoadingIndicator() {
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        loadingView.tag = 999
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLoadingViewTap))
        loadingView.addGestureRecognizer(tapGesture)
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor.white
        indicator.startAnimating()
        
        let label = UILabel()
        label.text = "正在截屏中…（点击取消）".localized()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 2

        loadingView.addSubview(indicator)
        loadingView.addSubview(label)
        parentView.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        indicator.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(40)
            make.bottom.equalToSuperview().offset(-10)
        }

        label.snp.makeConstraints { make in
            make.centerY.equalTo(indicator)
            make.left.equalTo(indicator.snp.right).offset(20)
            make.right.equalToSuperview().inset(40)
        }
    }

    private func hideLoadingIndicator() {
        parentView.viewWithTag(999)?.removeFromSuperview()
    }

    // MARK: - 用户点击取消截屏
    @objc private func handleLoadingViewTap() {
        guard isCapturing else { return }
        
        isCapturing = false
        hideLoadingIndicator()

        if screenshots.isEmpty {
            print("⚠️ 用户取消截屏（无截图）")
            let error = NSError(domain: "TCScreenshotManager",
                                code: -3,
                                userInfo: [NSLocalizedDescriptionKey: "用户取消了截屏"])
            delegate?.screenshotManager(self, didFailWithError: error)
        } else {
            print("⚠️ 用户取消截屏（已有 \(screenshots.count) 张）")
            scrollToPosition(0) { [weak self] in
                guard let self = self else { return }
                self.delegate?.screenshotManager(self, didCompleteScreenshots: self.screenshots)
            }
        }
    }
}

// MARK: - 保存相册
extension TCScreenshotManager {
    
    func saveScreenshotsToPhotos(_ images: [UIImage], completion: @escaping (Bool, Error?) -> Void) {
        guard !images.isEmpty else {
            completion(false, NSError(domain: "TCScreenshotManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "没有图片可保存"]))
            return
        }

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
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func performSaveToPhotos(_ images: [UIImage], completion: @escaping (Bool, Error?) -> Void) {
        var successCount = 0
        let group = DispatchGroup()

        for image in images {
            group.enter()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            successCount += 1
            group.leave()
        }

        group.notify(queue: .main) {
            completion(successCount == images.count, nil)
        }
    }
}

