//
//  TCScreenshotHistoryCell.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class TCScreenshotHistoryCell: UITableViewCell {
    
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
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = black
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = mainColor
        label.backgroundColor = mainColor.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var imageCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(imageCountLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(arrowImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(thumbnailImageView.snp.right).offset(12)
            make.top.equalToSuperview().offset(12)
            make.right.equalTo(arrowImageView.snp.left).offset(-12)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }
        
        imageCountLabel.snp.makeConstraints { make in
            make.left.equalTo(categoryLabel.snp.right).offset(8)
            make.centerY.equalTo(categoryLabel)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
    
    // MARK: - Configuration
    func configure(with history: TCScreenshotHistoryModel) {
        titleLabel.text = history.title
        categoryLabel.text = history.category
        imageCountLabel.text = "\(history.imageCount) 张图片"
        
        // 格式化日期
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
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