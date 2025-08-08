//
//  TCWebDetailViewController.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit
import WebKit

class TCWebDetailViewController: BaseViewController {
    
    // MARK: - Properties
    var websiteURL: String = ""
    private var currentWebsite: TCWebsiteModel?
    private var isFavorite: Bool = false
    
    // MARK: - UI Components
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = false
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = mainColor
        progressView.trackTintColor = UIColor.clear
        progressView.isHidden = true
        return progressView
    }()
    
    private lazy var toolbarView: TCWebToolbarView = {
        let view = TCWebToolbarView()
        view.delegate = self
        return view
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = mainColor
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var floatingScreenshotButton: TCFloatingScreenshotButton = {
        let button = TCFloatingScreenshotButton()
        button.delegate = self
        return button
    }()
    
    private lazy var screenshotManager: TCScreenshotManager = {
        let manager = TCScreenshotManager(webView: webView,parentView: customNav)
        manager.delegate = self
        return manager
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadWebsite()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkFavoriteStatus()
    }
    
    // MARK: - Setup
     func setupUI() {
        
        view.addSubview(webView)
        view.addSubview(progressView)
        view.addSubview(toolbarView)
        view.addSubview(loadingView)
        view.addSubview(floatingScreenshotButton)
        
        setupConstraints()
        setupNavigationBar()
    }
    
    private func setupConstraints() {
        webView.snp.makeConstraints { make in
            make.top.equalTo(customNav.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(toolbarView.snp.top)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(customNav.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        
        toolbarView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50 + kBottomSafeHeight)
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        floatingScreenshotButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(toolbarView.snp.top).offset(-40)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
    
    private func setupNavigationBar() {
        customNav.setRightButton(title: "收藏", titleColor: mainColor)
        customNav.rightButtonAction = { [weak self] in
            self?.toggleFavorite()
        }
        
        // 添加进度观察
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        // 添加滚动监听
        webView.scrollView.delegate = self
    }
    
    private func setupWebView() {
        // 设置用户代理
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
            if let userAgent = result as? String {
                let newUserAgent = userAgent + " TransComic/1.0"
                self?.webView.customUserAgent = newUserAgent
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadWebsite() {
        guard !websiteURL.isEmpty else { return }
        
        loadingView.startAnimating()
        progressView.isHidden = false
        
        if let url = URL(string: websiteURL) {
            let request = URLRequest(url: url)
            webView.load(request)
            
            // 创建网站模型
            currentWebsite = TCWebsiteModel(name: url.host ?? "未知网站", url: websiteURL, icon: "web_icon01")
            
            // 检查收藏状态
            checkFavoriteStatus()
            
            // 添加到历史记录（使用改进的去重方法）
            if let website = currentWebsite {
                TCWebsiteManager.shared.addHistoryWebsiteWithUpdate(website)
            }
        }
    }
    
    private func checkFavoriteStatus() {
        guard let website = currentWebsite else { return }
        isFavorite = TCWebsiteManager.shared.isFavoriteWebsite(website)
        updateFavoriteButton()
    }
    
    private func checkFavoriteStatusByURL() {
        // 通过URL检查收藏状态，用于网页加载完成后更新
        isFavorite = TCWebsiteManager.shared.isFavoriteWebsiteByURL(websiteURL)
        updateFavoriteButton()
        
        // 调试信息
        print("🔍 检查收藏状态: \(websiteURL) - \(isFavorite ? "已收藏" : "未收藏")")
    }
    
    private func updateFavoriteButton() {
        let title = isFavorite ? "已收藏" : "收藏"
        let color = isFavorite ? UIColor.gray : mainColor
        customNav.setRightButton(title: title, titleColor: color)
        
        // 调试信息
        print("🔄 更新收藏按钮: \(title)")
    }
    
    // MARK: - Actions
    private func toggleFavorite() {
        guard let website = currentWebsite else { return }
        
        if isFavorite {
            TCWebsiteManager.shared.removeFavoriteWebsite(website)
            isFavorite = false
        } else {
            TCWebsiteManager.shared.addFavoriteWebsite(website)
            isFavorite = true
        }
        
        updateFavoriteButton()
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.setProgress(progress, animated: true)
            
            if progress >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.progressView.isHidden = true
                    self?.progressView.setProgress(0, animated: false)
                }
            }
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    // MARK: - Scroll Handling
    private func handleScroll() {
        // 隐藏悬浮按钮
        floatingScreenshotButton.hide()
    }
    
    private func handleScrollEnd() {
        // 显示悬浮按钮
        floatingScreenshotButton.show()
        
        // 启动隐藏定时器
    }
}

// MARK: - WKNavigationDelegate
extension TCWebDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.startAnimating()
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.stopAnimating()
        
        // 更新标题
        if let title = webView.title, !title.isEmpty {
            self.title = title
        }
        
        // 更新当前网站信息
        if let url = webView.url?.absoluteString {
            let updatedWebsite = TCWebsiteModel(name: webView.title ?? webView.url?.host ?? "未知网站", url: url, icon: "web_icon01")
            currentWebsite = updatedWebsite
            
            // 更新历史记录（使用正确的网站标题）
            TCWebsiteManager.shared.addHistoryWebsiteWithUpdate(updatedWebsite)
        }
        
        // 重新检查收藏状态（网页加载完成后）
        checkFavoriteStatusByURL()
        
        // 更新工具栏状态
        toolbarView.updateNavigationState(canGoBack: webView.canGoBack, canGoForward: webView.canGoForward)
        floatingScreenshotButton.show()

    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingView.stopAnimating()
        progressView.isHidden = true
        
        // 显示错误信息
        let alert = UIAlertController(title: "加载失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingView.stopAnimating()
        progressView.isHidden = true
        
        // 显示错误信息
        let alert = UIAlertController(title: "加载失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TCWebToolbarViewDelegate
extension TCWebDetailViewController: TCWebToolbarViewDelegate {
    func toolbarView(_ view: TCWebToolbarView, didTapBackButton button: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func toolbarView(_ view: TCWebToolbarView, didTapForwardButton button: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    func toolbarView(_ view: TCWebToolbarView, didTapMultiWindowButton button: UIButton) {
        // 创建新窗口
        let newWebDetailVC = TCWebDetailViewController()
        newWebDetailVC.websiteURL = websiteURL
        navigationController?.pushViewController(newWebDetailVC, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension TCWebDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollEnd()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollEnd()
    }
}

// MARK: - TCFloatingScreenshotButtonDelegate
extension TCWebDetailViewController: TCFloatingScreenshotButtonDelegate {
    func floatingScreenshotButtonDidTap(_ button: TCFloatingScreenshotButton) {
        // 开始分页截屏
        screenshotManager.startPageScreenshot()
    }
}

// MARK: - TCScreenshotManagerDelegate
extension TCWebDetailViewController: TCScreenshotManagerDelegate {
    func screenshotManager(_ manager: TCScreenshotManager, didCompleteScreenshots images: [UIImage]) {
        // 截屏完成，显示结果
        showScreenshotResult(images)
    }
    
    func screenshotManager(_ manager: TCScreenshotManager, didFailWithError error: Error) {
        // 截屏失败，显示错误
        showScreenshotError(error)
    }
    
    func screenshotManager(_ manager: TCScreenshotManager, didUpdateProgress progress: Float) {
        // 更新截屏进度
        updateScreenshotProgress(progress)
    }
    
    // MARK: - Screenshot Result Handling
    private func showScreenshotResult(_ images: [UIImage]) {
        let resultView = ScreenshotResultView(imageCount: images.count)
        
        resultView.onAction = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .translateNow:
                // 执行翻译逻辑
                self.startTranslation(images)
            case .viewImages:
                self.showScreenshotGallery(images)
            case .saveToPhotos:
                self.saveScreenshotsToPhotos(images)
            }
        }
        
        UIApplication.shared.keyWindow?.addSubview(resultView)
    }
    
    private func showScreenshotError(_ error: Error) {
        let alert = UIAlertController(title: "截屏失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func updateScreenshotProgress(_ progress: Float) {
        // 可以在这里更新进度条或显示进度信息
        print("📸 截屏进度: \(Int(progress * 100))%")
    }
    
    private func saveScreenshotsToPhotos(_ images: [UIImage]) {
        screenshotManager.saveScreenshotsToPhotos(images) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController(title: "保存成功", message: "截屏已保存到相册", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self?.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "保存失败", message: error?.localizedDescription ?? "未知错误", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func showScreenshotGallery(_ images: [UIImage]) {
        // 创建图片浏览控制器
        let galleryVC = TCScreenshotGalleryViewController(images: images)
//        galleryVC)
        present(galleryVC, animated: true)
    }
    //
    private func startTranslation(_ images: [UIImage]) {
        
    }
}
