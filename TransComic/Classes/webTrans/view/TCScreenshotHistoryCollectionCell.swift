//
//  TCScreenshotHistoryCollectionCell.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class TCScreenshotHistoryCollectionCell: UICollectionViewCell {
    
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
    
    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = mainColor
        label.backgroundColor = mainColor.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var imageCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.gray
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.gray
        return label
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
        backgroundColor = UIColor.clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(imageCountLabel)
        containerView.addSubview(dateLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().inset(8)
            make.width.equalTo(50)
            make.height.equalTo(16)
        }
        
        imageCountLabel.snp.makeConstraints { make in
            make.left.equalTo(categoryLabel.snp.right).offset(4)
            make.centerY.equalTo(categoryLabel)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(categoryLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    // MARK: - Configuration
    func configure(with history: TCScreenshotHistoryModel) {
        titleLabel.text = history.title
        categoryLabel.text = history.category
        imageCountLabel.text = "\(history.imageCount)张"
        
        // 格式化日期
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: history.createdAt)
        
        // 加载缩略图
        if let thumbnail = history.getThumbnailImage() {
            thumbnailImageView.image = thumbnail
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
            thumbnailImageView.tintColor = UIColor.gray
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        categoryLabel.text = ""
        imageCountLabel.text = ""
        dateLabel.text = ""
        thumbnailImageView.image = nil
    }
} 