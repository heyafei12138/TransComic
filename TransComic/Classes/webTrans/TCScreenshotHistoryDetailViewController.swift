//
//  TCScreenshotHistoryDetailViewController.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class TCScreenshotHistoryDetailViewController: BaseViewController {
    
    // MARK: - Properties
    private let history: TCScreenshotHistoryModel
    private var images: [UIImage] = []
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TCScreenshotCell.self, forCellWithReuseIdentifier: "TCScreenshotCell")
        return collectionView
    }()
    
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 15
        label.layer.masksToBounds = true
        return label
    }()
    
    // MARK: - Initialization
    init(history: TCScreenshotHistoryModel) {
        self.history = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "截屏详情".localized()
        loadImages()
        setupNavigationBar()
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup
    func setupUI() {
        
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(collectionView)
        view.addSubview(pageLabel)
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(customNav.snp.bottom)
        }
        
        pageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(customNav.snp.bottom).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
    }
    
    private func setupNavigationBar() {
        customNav.setRightButton(title: "删除".localized(), titleColor: UIColor.red)
        customNav.rightButtonAction = { [weak self] in
            self?.showDeleteConfirmation()
        }
    }
    
    // MARK: - Data Loading
    private func loadImages() {
        images = history.getImages()
        updatePageLabel()
        collectionView.reloadData()
    }
    
    private func updatePageLabel() {
        pageLabel.text = "1 / \(images.count)"
    }
    
    // MARK: - Actions
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "删除记录".localized(), message: "确定要删除这条截屏记录吗？".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "删除".localized(), style: .destructive) { [weak self] _ in
            self?.deleteHistory()
        })
        present(alert, animated: true)
    }
    
    private func deleteHistory() {
        TCScreenshotHistoryManager.shared.removeScreenshotHistory(history)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TCScreenshotHistoryDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TCScreenshotCell", for: indexPath) as! TCScreenshotCell
        cell.configure(with: images[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TCScreenshotHistoryDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

// MARK: - UICollectionViewDelegate
extension TCScreenshotHistoryDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageLabel.text = "\(page + 1) / \(images.count)"
    }
}
