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
            make.height.equalTo(60 + kBottomSafeHeight)
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }
    
    private func setupNavigationBar() {
        customNav.setRightButton(title: "收藏", titleColor: mainColor)
        customNav.rightButtonAction = { [weak self] in
            self?.toggleFavorite()
        }
        
        // 添加进度观察
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
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
            currentWebsite = TCWebsiteModel(name: url.host ?? "未知网站", url: websiteURL, icon: "🌐")
            
            // 添加到历史记录
            if let website = currentWebsite {
                TCWebsiteManager.shared.addHistoryWebsite(website)
            }
        }
    }
    
    private func checkFavoriteStatus() {
        guard let website = currentWebsite else { return }
        isFavorite = TCWebsiteManager.shared.isFavoriteWebsite(website)
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let title = isFavorite ? "已收藏" : "收藏"
        let color = isFavorite ? UIColor.gray : mainColor
        customNav.setRightButton(title: title, titleColor: color)
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
            currentWebsite = TCWebsiteModel(name: webView.title ?? webView.url?.host ?? "未知网站", url: url, icon: "🌐")
        }
        
        // 更新工具栏状态
        toolbarView.updateNavigationState(canGoBack: webView.canGoBack, canGoForward: webView.canGoForward)
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
