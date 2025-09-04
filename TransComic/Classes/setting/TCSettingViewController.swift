//
//  TCSettingViewController.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import UIKit
import SnapKit
import StoreKit
import MessageUI

class TCSettingViewController: BaseViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var settingData: [[TCSettingItem]] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSettingData()
    }
    
    // MARK: - Setup
    func setupUI() {
        
        
        title = "设置".localized()
        view.backgroundColor = UIColor.hexString("#F8F9FA")
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TCSettingCell.self, forCellReuseIdentifier: "TCSettingCell")
        tableView.register(TCSettingHeaderView.self, forHeaderFooterViewReuseIdentifier: "TCSettingHeaderView")
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(customNav.snp.bottom)
        }
    }
    
    private func loadSettingData() {
        settingData = [
            // 通用设置
            [
                TCSettingItem(title: "应用语言".localized(), subtitle: getCurrentLanguageText(), icon: "globe", type: .language),
                
            ],
            // 应用相关
            [
                TCSettingItem(title: "分享给好友".localized(), subtitle: "推荐给朋友使用".localized(), icon: "square.and.arrow.up", type: .share),
                TCSettingItem(title: "给个好评".localized(), subtitle: "在App Store评分".localized(), icon: "star.fill", type: .rate),
                TCSettingItem(title: "意见反馈".localized(), subtitle: "帮助我们改进".localized(), icon: "envelope", type: .feedback)
            ],
            // 关于
            [
                TCSettingItem(title: "隐私政策".localized(), subtitle: "了解隐私保护".localized(), icon: "hand.raised.fill", type: .privacy),
                TCSettingItem(title: "用户协议".localized(), subtitle: "使用条款说明".localized(), icon: "doc.text", type: .terms),
                TCSettingItem(title: "关于我们".localized(), subtitle: "v \(getAppVersion())", icon: "info.circle", type: .about)
            ]
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Helper Methods
    private func getCurrentLanguageText() -> String {
        return TCLanguageManager.shared.getLanguageDisplayName(for: TCLanguageManager.shared.currentLanguage)
    }
    
    private func getCacheSizeText() -> String {
        return TCCacheManager.shared.getCacheSize()
    }
    
    private func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    // MARK: - Actions
    private func handleSettingItem(_ item: TCSettingItem) {
        switch item.type {
        case .language:
            showLanguageSelection()
        case .clearCache:
            showClearCacheAlert()
        case .share:
            shareApp()
        case .rate:
            rateApp()
        case .feedback:
            sendFeedback()
        case .privacy:
            showPrivacyPolicy()
        case .terms:
            showTermsOfService()
        case .about:
            showAboutUs()
        case .vip:
            let vc = TCSubscribeViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showLanguageSelection() {
        let alert = UIAlertController(title: "选择语言".localized(), message: nil, preferredStyle: .actionSheet)
        
        let languages = TCLanguageManager.shared.availableLanguages
        
        for language in languages {
            let action = UIAlertAction(title: "\(language.flag) \(language.name)", style: .default) { _ in
                self.changeLanguage(to: language.code)
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func changeLanguage(to languageCode: String) {
        TCLanguageManager.shared.changeLanguage(to: languageCode) {success in
            kWindow?.rootViewController = UINavigationController(rootViewController: HomeViewController())
        }
    }
    
    private func showClearCacheAlert() {
        let alert = UIAlertController(title: "清除缓存".localized(), message: "确定要清除所有缓存数据吗？".localized(), preferredStyle: .alert)
        
        let clearAction = UIAlertAction(title: "清除".localized(), style: .destructive) { _ in
            self.clearCache()
        }
        alert.addAction(clearAction)
        
        let cancelAction = UIAlertAction(title: "取消".localized(), style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func clearCache() {
        // 显示加载指示器
        let loadingAlert = UIAlertController(title: "正在清除缓存".localized(), message: "请稍候...".localized(), preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        TCCacheManager.shared.clearAllCache { [weak self] success, message in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    let resultAlert = UIAlertController(
                        title: success ? "清除完成".localized() : "清除失败".localized(),
                        message: message,
                        preferredStyle: .alert
                    )
                    let okAction = UIAlertAction(title: "确定".localized(), style: .default) { _ in
                        if success {
                            self?.loadSettingData() // 刷新显示
                        }
                    }
                    resultAlert.addAction(okAction)
                    self?.present(resultAlert, animated: true)
                }
            }
        }
    }
    
    private func shareApp() {
        let appName = "TransComic"
        let appDescription = "一款强大的翻译工具，支持动漫翻译、网页翻译等功能".localized()
        let appStoreURL = "https://apps.apple.com/app/transcomic/id\(TCAppID)"
        
        let shareText = "\(appName)\n\(appDescription)\n\(appStoreURL)"
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // 在iPad上需要设置popoverPresentationController
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    private func rateApp() {
        if #available(iOS 14.0, *) {
            if let scene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }
    }
    
    private func sendFeedback() {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["kele221070@163.com"])
            mailVC.setSubject("TransComic")
            mailVC.setMessageBody("请描述您遇到的问题或建议：\n\n".localized(), isHTML: false)
            
            present(mailVC, animated: true)
        } else {
            let alert = UIAlertController(title: "无法发送邮件".localized(), message: "请检查邮件设置或直接联系我们".localized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定".localized(), style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
    
    private func showPrivacyPolicy() {
        let privacyVC = TCWebViewController(title: "隐私政策".localized(), urlString: "https://sleep.leaphealth.fitness/privacypolicy.html")
        navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    private func showTermsOfService() {
        let termsVC = TCWebViewController(title: "技术支持".localized(), urlString: "https://docs.qq.com/doc/DVEZZb0dKRkRqa09x")
        navigationController?.pushViewController(termsVC, animated: true)
    }
    
    private func showAboutUs() {
        let aboutVC = TCAboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TCSettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TCSettingCell", for: indexPath) as! TCSettingCell
        let item = settingData[indexPath.section][indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = settingData[indexPath.section][indexPath.row]
        handleSettingItem(item)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TCSettingHeaderView") as! TCSettingHeaderView
        
        let titles = ["通用设置".localized(), "应用相关".localized(), "关于".localized()]
        headerView.configure(title: titles[section])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension TCSettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if result == .sent {
                let alert = UIAlertController(title: "Success", message: "Thank you for your feedback", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Done", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }
}
