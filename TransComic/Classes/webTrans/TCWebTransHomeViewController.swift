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
        view.title = "常用网址".localized()
        view.delegate = self
        return view
    }()
    
    private lazy var favoriteWebsitesView: TCWebsitesSectionView = {
        let view = TCWebsitesSectionView()
        view.title = "收藏网址".localized()
        view.delegate = self
        return view
    }()
    
    private lazy var historyWebsitesView: TCWebsitesSectionView = {
        let view = TCWebsitesSectionView()
        view.title = "历史记录".localized()
        view.delegate = self
        return view
    }()
    
    private lazy var screenshotHistoryView: TCScreenshotHistorySectionView = {
        let view = TCScreenshotHistorySectionView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网页翻译".localized()
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
        contentView.addSubview(screenshotHistoryView)
        
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
        }
        
        screenshotHistoryView.snp.makeConstraints { make in
            make.top.equalTo(historyWebsitesView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupData() {
        // 初始化常用网址
        commonWebsites = [
            TCWebsiteModel(name: "네이버 웹툰", url: "https://comic.naver.com/index", icon: "naver"),
            TCWebsiteModel(name: "LINE WEBTOON", url: "https://www.webtoons.com/th/", icon: "webtoon"),
            TCWebsiteModel(name: "少年ジャンプ＋", url: "https://shonenjumpplus.com/", icon: "shonenjumpplus"),
            TCWebsiteModel(name: "pixiv", url: "https://www.pixiv.net/manga", icon: "pixiv"),
            TCWebsiteModel(name: "MANGA Plus", url: "https://mangaplus.shueisha.co.jp/", icon: "manga"),
            TCWebsiteModel(name: "카카오페이지", url: "https://page.kakao.com/", icon: "kakao"),
            TCWebsiteModel(name: "MangaDex", url: "https://mangadex.org/", icon: "mangadex"),
            TCWebsiteModel(name: "コミックウォーカー", url: "https://comic-walker.com/", icon: "shonenjumpplus-1"),
            TCWebsiteModel(name: "Tapas – Comics and Novels", url: "https://tapas.io/", icon: "topas"),
            TCWebsiteModel(name: "comico", url: "https://www.comico.in.th/", icon: "comico"),
          
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
        
        // 更新截屏历史记录
        screenshotHistoryView.updateData()
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

// MARK: - TCScreenshotHistorySectionViewDelegate
extension TCWebTransHomeViewController: TCScreenshotHistorySectionViewDelegate {
    func screenshotHistorySectionView(_ view: TCScreenshotHistorySectionView, didSelectHistory history: TCScreenshotHistoryModel) {
        let detailVC = TCScreenshotHistoryDetailViewController(history: history)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func screenshotHistorySectionViewDidTapMore(_ view: TCScreenshotHistorySectionView) {
        let listVC = TCScreenshotHistoryListViewController()
        navigationController?.pushViewController(listVC, animated: true)
    }
} 
