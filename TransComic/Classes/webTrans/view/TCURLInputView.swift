//
//  TCURLInputView.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

protocol TCURLInputViewDelegate: AnyObject {
    func urlInputView(_ view: TCURLInputView, didEnterURL url: String)
}

class TCURLInputView: UIView {
    
    // MARK: - Properties
    weak var delegate: TCURLInputViewDelegate?
    
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var urlTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入网址".localized()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = black
        textField.keyboardType = .URL
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .go
        textField.delegate = self
        return textField
    }()
    
    private lazy var goButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("前往".localized(), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = mainColor
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(goButtonTapped), for: .touchUpInside)
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
        containerView.addSubview(urlTextField)
        containerView.addSubview(goButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        goButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(36)
        }
        
        urlTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(goButton.snp.left).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    // MARK: - Actions
    @objc private func goButtonTapped() {
        guard let url = urlTextField.text, !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        delegate?.urlInputView(self, didEnterURL: url)
        urlTextField.text = ""
        urlTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension TCURLInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goButtonTapped()
        return true
    }
} 
