//
//  TCSettingCell.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import UIKit
import SnapKit

class TCSettingCell: UITableViewCell {
    
    // MARK: - UI Components
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let separatorLine = UIView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none
        
        // 图标
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = LmainColor
        contentView.addSubview(iconImageView)
        
        // 标题
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.hexString("#333333")
        contentView.addSubview(titleLabel)
        
        // 副标题
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = UIColor.hexString("#999999")
        contentView.addSubview(subtitleLabel)
        
        // 箭头
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = UIColor.hexString("#CCCCCC")
        arrowImageView.contentMode = .scaleAspectFit
        contentView.addSubview(arrowImageView)
        
        // 分割线
        separatorLine.backgroundColor = UIColor.hexString("#F0F0F0")
        contentView.addSubview(separatorLine)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(16)
            make.top.equalToSuperview().offset(12)
            make.right.equalTo(arrowImageView.snp.left).offset(-16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    // MARK: - Configuration
    func configure(with item: TCSettingItem) {
        iconImageView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        // 根据类型设置特殊样式
        switch item.type {
        case .clearCache:
            iconImageView.tintColor = UIColor.hexString("#FF6B6B")
        case .share:
            iconImageView.tintColor = UIColor.hexString("#4ECDC4")
        case .rate:
            iconImageView.tintColor = UIColor.hexString("#FFD93D")
        case .feedback:
            iconImageView.tintColor = UIColor.hexString("#6C5CE7")
        case .privacy:
            iconImageView.tintColor = UIColor.hexString("#A8E6CF")
        case .terms:
            iconImageView.tintColor = UIColor.hexString("#FF8B94")
        case .about:
            iconImageView.tintColor = UIColor.hexString("#B8E6B8")
        default:
            iconImageView.tintColor = LmainColor
        }
        
        // 设置是否显示箭头
        arrowImageView.isHidden = !item.showArrow
        
        // 设置是否可用
        isUserInteractionEnabled = item.isEnabled
        alpha = item.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Override
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            backgroundColor = UIColor.hexString("#F5F5F5")
        } else {
            backgroundColor = .white
        }
    }
}
