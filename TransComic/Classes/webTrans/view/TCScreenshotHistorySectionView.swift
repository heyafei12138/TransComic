//
//  TCScreenshotHistorySectionView.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

protocol TCScreenshotHistorySectionViewDelegate: AnyObject {
    func screenshotHistorySectionView(_ view: TCScreenshotHistorySectionView, didSelectHistory history: TCScreenshotHistoryModel)
    func screenshotHistorySectionViewDidTapMore(_ view: TCScreenshotHistorySectionView)
}

class TCScreenshotHistorySectionView: UIView {
    
    // MARK: - Properties
    weak var delegate: TCScreenshotHistorySectionViewDelegate?
    private var histories: [TCScreenshotHistoryModel] = []
    
    // MARK: - UI Components
    private lazy var headerView: UIView = {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "截屏历史"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = black
        
        let moreButton = UIButton(type: .system)
        moreButton.setTitle("查看更多 >".localized(), for: .normal)
        moreButton.setTitleColor(mainColor, for: .normal)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        view.addSubview(moreButton)
        
        titleLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
        }
        
        return view
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
        collectionView.register(TCScreenshotHistoryCollectionCell.self, forCellWithReuseIdentifier: "TCScreenshotHistoryCollectionCell")
        return collectionView
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "暂无截屏历史"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(8)
        }
        
        return view
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
        addSubview(headerView)
        addSubview(collectionView)
        addSubview(emptyView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(24)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
            make.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
    }
    
    // MARK: - Public Methods
    func updateData() {
        histories = TCScreenshotHistoryManager.shared.getRecentScreenshotHistories(limit: 5)
        updateEmptyView()
        collectionView.reloadData()
    }
    
    private func updateEmptyView() {
        emptyView.isHidden = !histories.isEmpty
    }
    
    // MARK: - Actions
    @objc private func moreButtonTapped() {
        delegate?.screenshotHistorySectionViewDidTapMore(self)
    }
}

// MARK: - UICollectionViewDataSource
extension TCScreenshotHistorySectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return histories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TCScreenshotHistoryCollectionCell", for: indexPath) as! TCScreenshotHistoryCollectionCell
        let history = histories[indexPath.item]
        cell.configure(with: history)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TCScreenshotHistorySectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 120)
    }
}

// MARK: - UICollectionViewDelegate
extension TCScreenshotHistorySectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let history = histories[indexPath.item]
        delegate?.screenshotHistorySectionView(self, didSelectHistory: history)
    }
} 
