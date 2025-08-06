//
//  TCWebTransHomeViewController.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit
import WebKit

class TCWebTransHomeViewController: BaseViewController {
    
    // MARK: - Properties
    private var commonWebsites: [TCWebsiteModel] = []
    private var favoriteWebsites: [TCWebsiteModel] = []
    private var historyWebsites: [TCWebsiteModel] = []
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var urlInputView: TCURLInputView = {
        let view = TCURLInputView()
        view.delegate = self
        return view
    }()
    
    private lazy var commonWebsitesView: TCWebsitesSectionView = {
        let view = TCWebsitesSectionView()
        view.title = "常用网址"
        view.delegate = self
        return view
    }()
    
    private lazy var favoriteWebsitesView: TCWebsitesSectionView = {
        let view = TCWebsitesSectionView()
        view.title = "收藏网址"
        view.delegate = self
        return view
    }()
    
    private lazy var historyWebsitesView: TCWebsitesSectionView = {
        let view = TCWebsitesSectionView()
        view.title = "历史记录"
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网页翻译"
        setupUI()
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
     func setupUI() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(urlInputView)
        contentView.addSubview(commonWebsitesView)
        contentView.addSubview(favoriteWebsitesView)
        contentView.addSubview(historyWebsitesView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(customNav.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        urlInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        commonWebsitesView.snp.makeConstraints { make in
            make.top.equalTo(urlInputView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(16)
        }
        
        favoriteWebsitesView.snp.makeConstraints { make in
            make.top.equalTo(commonWebsitesView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(16)
        }
        
        historyWebsitesView.snp.makeConstraints { make in
            make.top.equalTo(favoriteWebsitesView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupData() {
        // 初始化常用网址
        commonWebsites = [
            TCWebsiteModel(name: "百度", url: "https://www.baidu.com", icon: "🌐"),
            TCWebsiteModel(name: "谷歌", url: "https://www.google.com", icon: "🌐"),
            TCWebsiteModel(name: "必应", url: "https://www.bing.com", icon: "🌐"),
            TCWebsiteModel(name: "GitHub", url: "https://github.com", icon: "💻"),
            TCWebsiteModel(name: "Stack Overflow", url: "https://stackoverflow.com", icon: "💻"),
            TCWebsiteModel(name: "YouTube", url: "https://www.youtube.com", icon: "📺")
        ]
        
        loadData()
    }
    
    private func loadData() {
        // 清理重复的历史记录
        TCWebsiteManager.shared.cleanDuplicateHistoryWebsites()
        
        // 加载收藏网址
        favoriteWebsites = TCWebsiteManager.shared.getFavoriteWebsites()
        
        // 加载历史记录
        historyWebsites = TCWebsiteManager.shared.getHistoryWebsites()
        
        // 更新UI
        updateUI()
    }
    
    private func updateUI() {
        commonWebsitesView.websites = commonWebsites
        favoriteWebsitesView.websites = favoriteWebsites
        historyWebsitesView.websites = historyWebsites
    }
    
    // MARK: - Navigation
    private func navigateToWebDetail(url: String) {
        let webDetailVC = TCWebDetailViewController()
        webDetailVC.websiteURL = url
        navigationController?.pushViewController(webDetailVC, animated: true)
    }
}

// MARK: - TCURLInputViewDelegate
extension TCWebTransHomeViewController: TCURLInputViewDelegate {
    func urlInputView(_ view: TCURLInputView, didEnterURL url: String) {
        let processedURL = TCWebsiteManager.shared.processURL(url)
        navigateToWebDetail(url: processedURL)
    }
}

// MARK: - TCWebsitesSectionViewDelegate
extension TCWebTransHomeViewController: TCWebsitesSectionViewDelegate {
    func websitesSectionView(_ view: TCWebsitesSectionView, didSelectWebsite website: TCWebsiteModel) {
        navigateToWebDetail(url: website.url)
    }
    
    func websitesSectionView(_ view: TCWebsitesSectionView, didDeleteWebsite website: TCWebsiteModel) {
        if view == favoriteWebsitesView {
            TCWebsiteManager.shared.removeFavoriteWebsite(website)
        } else if view == historyWebsitesView {
            TCWebsiteManager.shared.removeHistoryWebsite(website)
        }
        loadData()
    }
} 
