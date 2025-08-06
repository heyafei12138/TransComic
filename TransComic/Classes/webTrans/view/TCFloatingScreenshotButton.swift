//
//  TCFloatingScreenshotButton.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

protocol TCFloatingScreenshotButtonDelegate: AnyObject {
    func floatingScreenshotButtonDidTap(_ button: TCFloatingScreenshotButton)
}

class TCFloatingScreenshotButton: UIView {
    
    // MARK: - Properties
    weak var delegate: TCFloatingScreenshotButtonDelegate?
    private var isVisible = true
    private var hideTimer: Timer?
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = mainColor
        view.layer.cornerRadius = 28
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 8
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.tintColor = UIColor.white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var tapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        addSubview(tapButton)
        
        setupConstraints()
        setupGesture()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        tapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupGesture() {
        // 添加长按手势，显示提示
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
    }
    
    // MARK: - Public Methods
    func show() {
        guard !isVisible else { return }
        isVisible = true
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
    
    func hide() {
        guard isVisible else { return }
        isVisible = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseIn) {
            self.transform = CGAffineTransform(translationX: 0, y: 100)
            self.alpha = 0.0
        }
    }
    
    func startHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.hide()
        }
    }
    
    func cancelHideTimer() {
        hideTimer?.invalidate()
        hideTimer = nil
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        
        delegate?.floatingScreenshotButtonDidTap(self)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            // 显示提示信息
            showTooltip()
        }
    }
    
    private func showTooltip() {
        let tooltip = UILabel()
        tooltip.text = "分页截屏"
        tooltip.font = UIFont.systemFont(ofSize: 12)
        tooltip.textColor = UIColor.white
        tooltip.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        tooltip.textAlignment = .center
        tooltip.layer.cornerRadius = 8
        tooltip.layer.masksToBounds = true
        tooltip.alpha = 0
        
        addSubview(tooltip)
        
        tooltip.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(containerView.snp.top).offset(-8)
            make.width.equalTo(60)
            make.height.equalTo(24)
        }
        
        UIView.animate(withDuration: 0.2) {
            tooltip.alpha = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.2) {
                tooltip.alpha = 0
            } completion: { _ in
                tooltip.removeFromSuperview()
            }
        }
    }
} 