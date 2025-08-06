//
//  TCWebToolbarView.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

protocol TCWebToolbarViewDelegate: AnyObject {
    func toolbarView(_ view: TCWebToolbarView, didTapBackButton button: UIButton)
    func toolbarView(_ view: TCWebToolbarView, didTapForwardButton button: UIButton)
    func toolbarView(_ view: TCWebToolbarView, didTapMultiWindowButton button: UIButton)
}

class TCWebToolbarView: UIView {
    
    // MARK: - Properties
    weak var delegate: TCWebToolbarViewDelegate?
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setImage(UIImage(systemName: "chevron.left"), for: .disabled)
        button.tintColor = mainColor
        button.isEnabled = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.setImage(UIImage(systemName: "chevron.right"), for: .disabled)
        button.tintColor = mainColor
        button.isEnabled = false
        button.addTarget(self, action: #selector(forwardButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var multiWindowButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus.square.on.square"), for: .normal)
        button.tintColor = mainColor
        button.addTarget(self, action: #selector(multiWindowButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backButton, forwardButton, multiWindowButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 40
        return stackView
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
        containerView.addSubview(buttonStackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        forwardButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        multiWindowButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    // MARK: - Public Methods
    func updateNavigationState(canGoBack: Bool, canGoForward: Bool) {
        backButton.isEnabled = canGoBack
        forwardButton.isEnabled = canGoForward
        
        backButton.tintColor = canGoBack ? mainColor : UIColor.gray
        forwardButton.tintColor = canGoForward ? mainColor : UIColor.gray
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        delegate?.toolbarView(self, didTapBackButton: backButton)
    }
    
    @objc private func forwardButtonTapped() {
        delegate?.toolbarView(self, didTapForwardButton: forwardButton)
    }
    
    @objc private func multiWindowButtonTapped() {
        delegate?.toolbarView(self, didTapMultiWindowButton: multiWindowButton)
    }
} 