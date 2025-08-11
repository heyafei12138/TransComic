//
//  TCSettingHeaderView.swift
//  TransComic
//
//  Created by hebert on 2025/1/27.
//

import UIKit
import SnapKit

class TCSettingHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    
    // MARK: - Initialization
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = UIColor.hexString("#F8F9FA")
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.hexString("#666666")
        
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    func configure(title: String) {
        titleLabel.text = title.uppercased()
    }
}
