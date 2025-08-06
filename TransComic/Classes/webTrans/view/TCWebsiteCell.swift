//
//  TCWebsiteCell.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

protocol TCWebsiteCellDelegate: AnyObject {
    func websiteCell(_ cell: TCWebsiteCell, didDeleteWebsite website: TCWebsiteModel)
}

class TCWebsiteCell: UICollectionViewCell {
    
    // MARK: - Properties
    weak var delegate: TCWebsiteCellDelegate?
    private var website: TCWebsiteModel?
    
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
    
    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = black
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor.red
        button.alpha = 0.8
        button.isHidden = true
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLongPressGesture()
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(deleteButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(4)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
    }
    
    // MARK: - Configuration
    func configure(with website: TCWebsiteModel) {
        self.website = website
        iconLabel.text = website.icon
        nameLabel.text = website.name
    }
    
    // MARK: - Actions
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            deleteButton.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.deleteButton.alpha = 1.0
            }
        }
    }
    
    @objc private func deleteButtonTapped() {
        guard let website = website else { return }
        delegate?.websiteCell(self, didDeleteWebsite: website)
        
        deleteButton.isHidden = true
        deleteButton.alpha = 0.8
    }
    
    // MARK: - Override
    override func prepareForReuse() {
        super.prepareForReuse()
        website = nil
        iconLabel.text = ""
        nameLabel.text = ""
        deleteButton.isHidden = true
        deleteButton.alpha = 0.8
    }
} 