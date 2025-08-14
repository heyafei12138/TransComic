//
//  TCAboutViewController.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import UIKit
import SnapKit

class TCAboutViewController: BaseViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let appIconImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let versionLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let developerSection = UIView()
    private let developerTitleLabel = UILabel()
    private let developerInfoLabel = UILabel()
    
    private let contactSection = UIView()
    private let contactTitleLabel = UILabel()
    private let emailLabel = UILabel()
    private let websiteLabel = UILabel()
    
    private let copyrightLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAppInfo()
    }
    
    // MARK: - Setup
    func setupUI() {
        
        title = "关于我们".localized()
        view.backgroundColor = UIColor.hexString("#F8F9FA")
        
        setupScrollView()
        setupAppInfoSection()
        setupDeveloperSection()
        setupContactSection()
        setupCopyright()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(customNav.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupAppInfoSection() {
        // 应用图标
        appIconImageView.image = UIImage(named: "AppIcon01")
        appIconImageView.contentMode = .scaleAspectFit
        appIconImageView.layer.cornerRadius = 20
        appIconImageView.clipsToBounds = true
        contentView.addSubview(appIconImageView)
        
        // 应用名称
        appNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        appNameLabel.textColor = UIColor.hexString("#333333")
        appNameLabel.textAlignment = .center
        contentView.addSubview(appNameLabel)
        
        // 版本号
        versionLabel.font = UIFont.systemFont(ofSize: 16)
        versionLabel.textColor = UIColor.hexString("#666666")
        versionLabel.textAlignment = .center
        contentView.addSubview(versionLabel)
        
        // 应用描述
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = UIColor.hexString("#666666")
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        appIconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(appIconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(versionLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
        }
    }
    
    private func setupDeveloperSection() {
        developerSection.backgroundColor = .white
        developerSection.layer.cornerRadius = 12
        contentView.addSubview(developerSection)
        
        developerTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        developerTitleLabel.textColor = UIColor.hexString("#333333")
        developerTitleLabel.text = "开发者信息".localized()
        developerSection.addSubview(developerTitleLabel)
        
        developerInfoLabel.font = UIFont.systemFont(ofSize: 16)
        developerInfoLabel.textColor = UIColor.hexString("#666666")
        developerInfoLabel.numberOfLines = 0
        developerInfoLabel.text = "TransComic 团队\n致力于为用户提供优质的翻译体验".localized()
        developerSection.addSubview(developerInfoLabel)
        
        developerSection.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
        }
        
        developerTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        developerInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(developerTitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupContactSection() {
        contactSection.backgroundColor = .white
        contactSection.layer.cornerRadius = 12
        contentView.addSubview(contactSection)
        
        contactTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        contactTitleLabel.textColor = UIColor.hexString("#333333")
        contactTitleLabel.text = "联系我们".localized()
        contactSection.addSubview(contactTitleLabel)
        
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textColor = UIColor.hexString("#666666")
        emailLabel.text = "邮箱：".localized() + "kele221070@163.com"
        contactSection.addSubview(emailLabel)
        
        websiteLabel.font = UIFont.systemFont(ofSize: 16)
        websiteLabel.textColor = UIColor.hexString("#666666")
        contactSection.addSubview(websiteLabel)
        
        contactSection.snp.makeConstraints { make in
            make.top.equalTo(developerSection.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        contactTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(contactTitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        websiteLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupCopyright() {
        copyrightLabel.font = UIFont.systemFont(ofSize: 14)
        copyrightLabel.textColor = UIColor.hexString("#999999")
        copyrightLabel.textAlignment = .center
        copyrightLabel.numberOfLines = 0
        copyrightLabel.text = "© 2025 TransComic. All rights reserved.\n感谢您的使用！".localized()
        contentView.addSubview(copyrightLabel)
        
        copyrightLabel.snp.makeConstraints { make in
            make.top.equalTo(contactSection.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    // MARK: - Data Loading
    private func loadAppInfo() {
        appNameLabel.text = "TransComic"
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        versionLabel.text = "v \(version) (\(build))"
        
        descriptionLabel.text = "一款强大的翻译工具，支持动漫翻译、网页翻译、图片识别等多种功能，为用户提供便捷的翻译体验。".localized()
    }
}
