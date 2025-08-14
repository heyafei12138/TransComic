//
//  view.swift
//  TransComic
//
//  Created by hebert on 2025/8/7.
//

import UIKit



class ScreenshotResultView: UIView {

    enum ActionType {
        case translateNow
        case viewImages
        case saveToPhotos
    }
    var languageIndex = 0

    // MARK: - 回调
    var onAction: ((ActionType) -> Void)?
    let languageLabel = UILabel()
    var parentVC: UIViewController!

    private let containerView = UIView()
    private let titleLabel = UILabel()
    
    private lazy var translateButton = createActionButton(title: "立即翻译".localized(), imageName: "globe")
    private lazy var viewButton = createActionButton(title: "查看图片".localized(), imageName: "photo.on.rectangle")
    private lazy var saveButton = createActionButton(title: "保存到相册".localized(), imageName: "square.and.arrow.down")

    // MARK: - 初始化
    init(imageCount: Int) {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupUI(imageCount: imageCount)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSelf)))
        reloadLanguage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 构建
    private func setupUI(imageCount: Int) {
        addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true

        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(280)
        }

        titleLabel.text = "截屏完成，共截取".localized() + "\(imageCount)" + "张图片".localized()
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(translateButton)
        containerView.addSubview(viewButton)
//        containerView.addSubview(saveButton)
        translateButton.backgroundColor = LmainColor
        translateButton.tintColor = .white
        translateButton.setTitleColor(.white, for: .normal)
        translateButton.setImage(UIImage(named: "trans_now"), for: .normal)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.left.right.equalToSuperview().inset(16)
        }

        let cornerView = UIView()
        cornerView.layer.cornerRadius = 8
        cornerView.layer.borderWidth = 0.5
        cornerView.layer.borderColor = LmainColor.withAlphaComponent(0.8).cgColor
        containerView.addSubview(cornerView)
        cornerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(26)
            make.height.equalTo(44)
        }
        
        let title2 = UILabel()
        title2.text = "目标语言:".localized()
        title2.font = sysfont(size: 14)
        title2.textColor = .hexString("#666666")
        cornerView.addSubview(title2)
        title2.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        languageLabel.text = "简体中文".localized()
        languageLabel.font = middleFont(fontSize: 16)
        languageLabel.textColor = mainColor
        cornerView.addSubview(languageLabel)
        languageLabel.textAlignment = .right
        languageLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(30)
            make.left.equalTo(title2.snp.right).offset(10)
        }
        let chooseimaV = UIImageView(image: UIImage(named: "arrow_down"))
        cornerView.addSubview(chooseimaV)
        chooseimaV.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(0)
            make.right.equalToSuperview().inset(14)
            make.width.height.equalTo(12)
        }
        cornerView.isUserInteractionEnabled = true
        cornerView.jk.addGestureTap { _ in
            self.chooseLanguage()
        }
        
        translateButton.snp.makeConstraints { make in
            make.top.equalTo(cornerView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
        }

        viewButton.snp.makeConstraints { make in
            make.top.equalTo(translateButton.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(30)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(30)

        }

//        saveButton.snp.makeConstraints { make in
//            make.top.equalTo(translateButton.snp.bottom).offset(13)
//            make.left.right.equalToSuperview().inset(30)
//            make.height.equalTo(44)
//            make.bottom.equalToSuperview().inset(30)
//        }
    }

    private func createActionButton(title: String, imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("  \(title)", for: .normal)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .hexString("#999999")
        button.setTitleColor(.hexString("#999999"), for: .normal)
        button.titleLabel?.font = middleFont(fontSize: 16)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 0.5
        button.layer.borderColor = LmainColor.cgColor
//        button.contentHorizontalAlignment = .left
//        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

        // 点击事件处理
        switch title {
        case "立即翻译".localized():
            button.addTarget(self, action: #selector(didTapTranslate), for: .touchUpInside)
        case "查看图片".localized():
            button.addTarget(self, action: #selector(didTapView), for: .touchUpInside)
        case "保存到相册".localized():
            button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        default:
            break
        }

        return button
    }

    // MARK: - 操作事件
    @objc private func didTapTranslate() {
        dismissSelf()
        onAction?(.translateNow)
    }

    @objc private func didTapView() {
        dismissSelf()
        onAction?(.viewImages)
    }

    @objc private func didTapSave() {
        dismissSelf()
        onAction?(.saveToPhotos)
    }

    @objc private func dismissSelf() {
        removeFromSuperview()
    }
    func reloadLanguage() {
        languageIndex = UserDefaults.standard.integer(forKey: "SelectedLanguageCode")
        languageLabel.text = targetlanguages[languageIndex].name
    }
    
    @objc func chooseLanguage() {
        let vc = TransChooseLanguageVC()
        vc.selectedLanguageBlock = { [weak self] in
            guard let self = self else { return }
            reloadLanguage()
        }
        let segue =  SwiftMessagesBottomSegue(identifier: nil, source: self.parentVC, destination: vc)

        segue.messageView.layer.shadowColor = UIColor.clear.cgColor
        segue.messageView.backgroundHeight = 435 + 16
        segue.perform()
    }
}
