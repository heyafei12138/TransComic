//
//  TCWebsitesSectionView.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

protocol TCWebsitesSectionViewDelegate: AnyObject {
    func websitesSectionView(_ view: TCWebsitesSectionView, didSelectWebsite website: TCWebsiteModel)
    func websitesSectionView(_ view: TCWebsitesSectionView, didDeleteWebsite website: TCWebsiteModel)
}

class TCWebsitesSectionView: UIView {
    
    // MARK: - Properties
    weak var delegate: TCWebsitesSectionViewDelegate?
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var websites: [TCWebsiteModel] = [] {
        didSet {
            collectionView.reloadData()
            updateEmptyState()
        }
    }
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = black
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TCWebsiteCell.self, forCellWithReuseIdentifier: "TCWebsiteCell")
        return collectionView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无数据"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.isHidden = true
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
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(emptyLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.height.equalTo(24)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(80)
            make.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
        }
    }
    
    private func updateEmptyState() {
        emptyLabel.isHidden = !websites.isEmpty
    }
}

// MARK: - UICollectionViewDataSource
extension TCWebsitesSectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return websites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TCWebsiteCell", for: indexPath) as! TCWebsiteCell
        let website = websites[indexPath.item]
        cell.configure(with: website)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TCWebsitesSectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

// MARK: - UICollectionViewDelegate
extension TCWebsitesSectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let website = websites[indexPath.item]
        delegate?.websitesSectionView(self, didSelectWebsite: website)
    }
}

// MARK: - TCWebsiteCellDelegate
extension TCWebsitesSectionView: TCWebsiteCellDelegate {
    func websiteCell(_ cell: TCWebsiteCell, didDeleteWebsite website: TCWebsiteModel) {
        delegate?.websitesSectionView(self, didDeleteWebsite: website)
    }
} 