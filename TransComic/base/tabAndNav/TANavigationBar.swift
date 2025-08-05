//
//  NavigationBar.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/12.
//


import Foundation
import UIKit

// 常量定义
fileprivate let defaultTitleSize: CGFloat = 16
fileprivate let defaultTitleColor = UIColor.black
fileprivate let defaultBackgroundColor = UIColor.clear  // 更改为更通用的背景颜色
fileprivate let screenWidth = UIScreen.main.bounds.size.width

// 判断是否为刘海屏
public var isNotchScreen: Bool {
    return kStatusBarHeight > 20
}

// 判断是否为iPad
public let isIPadDevice = UIDevice.current.userInterfaceIdiom == .pad

////////////////////////////////////////////////////////////////////////////////////////////////////////////
open class NavigationBar: UIView {
    
    public var leftButtonAction: (() -> ())?
    public var rightButtonAction: (() -> ())?
    
    public var navigationBarTitle: String? {
        willSet {
            titleLabel.isHidden = false
            titleLabel.text = newValue
        }
    }
    
    public var attributedNavigationBarTitle: NSAttributedString? {
        willSet {
            titleLabel.isHidden = false
            titleLabel.attributedText = newValue
        }
    }
    
    public var titleLabelTextColor: UIColor? {
        willSet {
            titleLabel.textColor = newValue
        }
    }
    
    public var titleLabelFont: UIFont? {
        willSet {
            titleLabel.font = newValue
        }
    }
    
    public var navigationBarBackgroundColor: UIColor? {
        willSet {
            backgroundImageView.isHidden = true
            backgroundView.isHidden = false
            backgroundView.backgroundColor = newValue
        }
    }
    
    public var navigationBarBackgroundImage: UIImage? {
        willSet {
            backgroundView.isHidden = true
            backgroundImageView.isHidden = false
            backgroundImageView.image = newValue
        }
    }
    
    // UI Components
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = defaultTitleColor
        label.font = middleFont(fontSize: defaultTitleSize)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.isHidden = true
        return label
    }()
    
    open lazy var leftNavButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .center
        button.isHidden = true
        button.addTarget(self, action: #selector(leftButtonClicked), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    open lazy var rightNavButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .center
        button.isHidden = true
        button.addTarget(self, action: #selector(rightButtonClicked), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    fileprivate lazy var bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.isHidden = true
        return view
    }()
    
    fileprivate lazy var backgroundView: UIView = {
        let view = UIView()
        return view
    }()
    
    fileprivate lazy var backgroundImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.isHidden = true
        return imgView
    }()
    
    fileprivate static var isIphoneXSeries: Bool {
        get {
            return isNotchScreen && !isIPadDevice
        }
    }
    
    fileprivate static var navBarHeight: Int {
        get {
            return isIphoneXSeries ? 88 : 64
        }
    }
    
    // Initializer
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: CGFloat(kNavHeight)))
        setupUI()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // Set up the layout
    func setupUI() {
        addSubview(backgroundView)
        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(leftNavButton)
        addSubview(rightNavButton)
        addSubview(bottomSeparator)
        updateLayout()
        backgroundColor = UIColor.clear
        backgroundView.backgroundColor = defaultBackgroundColor
    }
    
    // Update layout of components
    func updateLayout() {
        let topMargin: CGFloat = kStatusBarHeight
        let buttonHeight: CGFloat = 44
        let buttonWidth: CGFloat = 40
        let titleHeight: CGFloat = 44
        let titleWidth: CGFloat = screenWidth - 130 - 48
        
        backgroundView.frame = self.bounds
        backgroundImageView.frame = self.bounds
        leftNavButton.frame = CGRect(x: 16, y: topMargin, width: buttonWidth, height: buttonHeight)
        rightNavButton.frame = CGRect(x: screenWidth - buttonWidth - 16, y: topMargin, width: buttonWidth, height: buttonHeight)
        titleLabel.frame = CGRect(x: 42, y: topMargin, width: titleWidth, height: titleHeight)
        bottomSeparator.frame = CGRect(x: 0, y: CGFloat(kNavHeight) - 0.5, width: screenWidth, height: 0.5)
        
        leftNavButton.contentHorizontalAlignment = .left
        leftNavButton.titleEdgeInsets = UIEdgeInsets.zero
        leftNavButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        
        rightNavButton.contentHorizontalAlignment = .right
        rightNavButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        rightNavButton.titleLabel?.minimumScaleFactor = 0.5
        rightNavButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(titleWidth)
            make.height.equalTo(titleHeight)
//            make.left.equalToSuperview().offset(48)
            make.centerX.equalToSuperview()
            
        }
        leftNavButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalTo(titleLabel)
            make.height.equalTo(buttonHeight)
        }
        rightNavButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.size.bottom.equalTo(leftNavButton)
        }
    }
}

extension NavigationBar {
    // 设置底部分隔线是否隐藏
    public func setBottomLineHidden(_ hidden: Bool) {
        bottomSeparator.isHidden = hidden
    }
    
    // 设置透明度
    public func setBackgroundAlpha(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
        backgroundImageView.alpha = alpha
        bottomSeparator.alpha = alpha
    }
    
    // 设置导航栏按钮的颜色
    public func setTintColor(_ color: UIColor) {
        leftNavButton.setTitleColor(color, for: .normal)
        rightNavButton.setTitleColor(color, for: .normal)
        titleLabel.textColor = color
    }
    
    // 设置左按钮
    public func setLeftButton(normalImage: UIImage, highlightedImage: UIImage? = nil) {
        setLeftButton(normalImage: normalImage, highlightedImage: (highlightedImage != nil) ? highlightedImage : normalImage, title: nil, titleColor: nil)
    }
    
    // 设置右按钮
    public func setRightButton(normalImage: UIImage, highlightedImage: UIImage) {
        setRightButton(normalImage: normalImage, highlightedImage: highlightedImage, title: nil, titleColor: nil)
    }
    
    // 设置左按钮标题和颜色
    public func setLeftButton(title: String, titleColor: UIColor) {
        setLeftButton(normalImage: nil, highlightedImage: nil, title: title, titleColor: titleColor)
    }
    
    // 设置右按钮标题和颜色
    public func setRightButton(title: String, titleColor: UIColor) {
        setRightButton(normalImage: nil, highlightedImage: nil, title: title, titleColor: titleColor)
    }
    
    // 内部方法设置左按钮
    private func setLeftButton(normalImage: UIImage?, highlightedImage: UIImage?, title: String?, titleColor: UIColor?) {
        leftNavButton.isHidden = false
        leftNavButton.setImage(normalImage, for: .normal)
        leftNavButton.setImage(highlightedImage, for: .highlighted)
        leftNavButton.setTitle(title, for: .normal)
        leftNavButton.setTitleColor(titleColor, for: .normal)
    }
    
    // 内部方法设置右按钮
    private func setRightButton(normalImage: UIImage?, highlightedImage: UIImage?, title: String?, titleColor: UIColor?) {
        rightNavButton.isHidden = false
        rightNavButton.setImage(normalImage, for: .normal)
        rightNavButton.setImage(highlightedImage, for: .highlighted)
        rightNavButton.setTitle(title, for: .normal)
        rightNavButton.setTitleColor(titleColor, for: .normal)
    }
}

// MARK: - 按钮点击事件
extension NavigationBar {
    @objc func leftButtonClicked() {
        if let action = leftButtonAction {
            action()
        } else {
            guard let vc = UIViewController.jk.topViewController() else {
                return
            }
            vc.popViewCon()
        }
    }
    
    @objc func rightButtonClicked() {
        if let action = rightButtonAction {
            action()
        }
    }
}
