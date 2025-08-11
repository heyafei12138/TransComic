//
//  HomeHistoryDetailViewController.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class HomeHistoryDetailViewController: BaseViewController {
    
    // MARK: - Properties
    private let history: HomeHistoryModel
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = mainColor
        label.backgroundColor = mainColor.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("保存到相册", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = mainColor
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(history: HomeHistoryModel) {
        self.history = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "历史详情"
        setupNavigationBar()
        loadData()
        setupUI()
    }
    
    // MARK: - Setup
     func setupUI() {
        
        view.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(infoView)
        contentView.addSubview(actionButton)
        
        infoView.addSubview(titleLabel)
        infoView.addSubview(categoryLabel)
        infoView.addSubview(descriptionLabel)
//        infoView.addSubview(dateLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
     
        
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(customNav.snp.bottom)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        
        infoView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().inset(16)
            make.width.equalTo(80)
            make.height.equalTo(24)
        }
        
//        dateLabel.snp.makeConstraints { make in
//            make.left.equalTo(categoryLabel.snp.right).offset(12)
//            make.centerY.equalTo(categoryLabel)
//        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-kBottomSafeHeight - 20)
        }
    }
    
    private func setupNavigationBar() {
        customNav.setRightButton(title: "删除", titleColor: UIColor.red)
        customNav.rightButtonAction = { [weak self] in
            self?.showDeleteConfirmation()
        }
    }
    
    // MARK: - Data Loading
    private func loadData() {
        titleLabel.text = history.title
        categoryLabel.text = history.category
        descriptionLabel.text = history.description
        
        // 格式化时间
//        let formatter = DateFormatter()
//        formatter.dateStyle = .full
//        formatter.timeStyle = .short
//        dateLabel.text = formatter.string(from: history.createdAt)
        
        // 加载图片
        if let image = history.getImage() {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = UIColor.gray
        }
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        if let image = history.getImage() {
            // 保存图片到相册
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            let alert = UIAlertController(title: "保存成功", message: "图片已保存到相册", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func showDeleteConfirmation() {
        let alert = UIAlertController(title: "删除记录", message: "确定要删除这条历史记录吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.deleteHistory()
        })
        present(alert, animated: true)
    }
    
    private func deleteHistory() {
        HomeHistoryManager.shared.removeHistory(history)
        navigationController?.popViewController(animated: true)
    }
}
