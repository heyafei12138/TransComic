//
//  TCWebViewController.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import UIKit
import SnapKit
import WebKit

class TCWebViewController: BaseViewController {
    
    // MARK: - Properties
    private let webView = WKWebView()
    private let progressView = UIProgressView()
    private let titleLabel: String
    private let urlString: String
    
    // MARK: - Initialization
    init(title: String, urlString: String) {
        self.titleLabel = title
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebContent()
    }
    
    // MARK: - Setup
    func setupUI() {
        
        
        title = titleLabel
        view.backgroundColor = .white
        
        setupWebView()
        setupProgressView()
        setupConstraints()
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        // 添加进度观察
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        view.addSubview(webView)
    }
    
    private func setupProgressView() {
        progressView.progressTintColor = LmainColor
        progressView.trackTintColor = UIColor.hexString("#F0F0F0")
        progressView.progress = 0.0
        view.addSubview(progressView)
    }
    
    private func setupConstraints() {
        progressView.snp.makeConstraints { make in
            make.top.equalTo(customNav.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Web Content Loading
    private func loadWebContent() {
        guard let url = URL(string: urlString) else {
            showError("无效的URL地址")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "加载失败", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "重试", style: .default) { _ in
            self.loadWebContent()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.setProgress(progress, animated: true)
            
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut) {
                    self.progressView.alpha = 0.0
                }
            }
        }
    }
    
    // MARK: - Deinit
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}

// MARK: - WKNavigationDelegate
extension TCWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.alpha = 1.0
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(1.0, animated: true)
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut) {
            self.progressView.alpha = 0.0
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.alpha = 0.0
        showError("页面加载失败：\(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.alpha = 0.0
        showError("页面加载失败：\(error.localizedDescription)")
    }
}
