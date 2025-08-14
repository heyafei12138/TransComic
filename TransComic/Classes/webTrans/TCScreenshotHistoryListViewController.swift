//
//  TCScreenshotHistoryListViewController.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class TCScreenshotHistoryListViewController: BaseViewController {
    
    // MARK: - Properties
    private var histories: [TCScreenshotHistoryModel] = []
    private var filteredHistories: [TCScreenshotHistoryModel] = []
    private var selectedCategory: String?
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TCScreenshotHistoryCell.self, forCellReuseIdentifier: "TCScreenshotHistoryCell")
        tableView.rowHeight = 100
        return tableView
    }()
    
    private lazy var categorySegmentControl: UISegmentedControl = {
        let categories = ["全部".localized()] + TCScreenshotHistoryManager.shared.getCategories()
        let segmentControl = UISegmentedControl(items: categories)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = UIColor.white
        segmentControl.selectedSegmentTintColor = mainColor
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        return segmentControl
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "暂无截屏历史记录".localized()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(16)
        }
        
        return view
    }()
    
    private lazy var statsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        
        let totalLabel = UILabel()
        totalLabel.text = "总计".localized()
        totalLabel.font = UIFont.systemFont(ofSize: 14)
        totalLabel.textColor = UIColor.gray
        
        let totalCountLabel = UILabel()
        totalCountLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totalCountLabel.textColor = mainColor
        
        let storageLabel = UILabel()
        storageLabel.text = "存储".localized()
        storageLabel.font = UIFont.systemFont(ofSize: 14)
        storageLabel.textColor = UIColor.gray
        
        let storageSizeLabel = UILabel()
        storageSizeLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        storageSizeLabel.textColor = mainColor
        
        view.addSubview(totalLabel)
        view.addSubview(totalCountLabel)
        view.addSubview(storageLabel)
        view.addSubview(storageSizeLabel)
        
        totalLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        
        totalCountLabel.snp.makeConstraints { make in
            make.left.equalTo(totalLabel)
            make.top.equalTo(totalLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        storageLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
        
        storageSizeLabel.snp.makeConstraints { make in
            make.right.equalTo(storageLabel)
            make.top.equalTo(storageLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        // 更新统计数据
        updateStats(totalCountLabel: totalCountLabel, storageSizeLabel: storageSizeLabel)
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "截屏历史".localized()
        setupNavigationBar()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
     func setupUI() {
        
        
        view.addSubview(statsView)
        view.addSubview(categorySegmentControl)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        statsView.snp.makeConstraints { make in
            make.top.equalTo(customNav.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        categorySegmentControl.snp.makeConstraints { make in
            make.top.equalTo(statsView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(categorySegmentControl.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(tableView)
        }
    }
    
    private func setupNavigationBar() {
        customNav.setRightButton(title: "清空".localized(), titleColor: mainColor)
        customNav.rightButtonAction = { [weak self] in
            self?.showClearConfirmation()
        }
    }
    
    // MARK: - Data Loading
    private func loadData() {
        histories = TCScreenshotHistoryManager.shared.getScreenshotHistories()
        filterHistories()
        updateEmptyView()
        tableView.reloadData()
    }
    
    private func filterHistories() {
        if let category = selectedCategory {
            filteredHistories = histories.filter { $0.category == category }
        } else {
            filteredHistories = histories
        }
    }
    
    private func updateEmptyView() {
        emptyView.isHidden = !filteredHistories.isEmpty
    }
    
    private func updateStats(totalCountLabel: UILabel, storageSizeLabel: UILabel) {
        let totalCount = TCScreenshotHistoryManager.shared.getTotalImageCount()
        let storageSize = TCScreenshotHistoryManager.shared.getTotalStorageSize()
        
        totalCountLabel.text = "\(totalCount)"
        storageSizeLabel.text = TCScreenshotHistoryManager.shared.formatStorageSize(storageSize)
    }
    
    // MARK: - Actions
    @objc private func categoryChanged() {
        if categorySegmentControl.selectedSegmentIndex == 0 {
            selectedCategory = nil
        } else {
            let categories = TCScreenshotHistoryManager.shared.getCategories()
            selectedCategory = categories[categorySegmentControl.selectedSegmentIndex - 1]
        }
        
        filterHistories()
        updateEmptyView()
        tableView.reloadData()
    }
    
    private func showClearConfirmation() {
        let alert = UIAlertController(title: "清空历史记录".localized(), message: "确定要清空所有截屏历史记录吗？此操作不可恢复。".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "清空".localized(), style: .destructive) { [weak self] _ in
            self?.clearAllHistories()
        })
        
        present(alert, animated: true)
    }
    
    private func clearAllHistories() {
        TCScreenshotHistoryManager.shared.clearAllScreenshotHistories()
        loadData()
    }
}

// MARK: - UITableViewDataSource
extension TCScreenshotHistoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TCScreenshotHistoryCell", for: indexPath) as! TCScreenshotHistoryCell
        let history = filteredHistories[indexPath.row]
        cell.configure(with: history)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TCScreenshotHistoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = filteredHistories[indexPath.row]
        let detailVC = TCScreenshotHistoryDetailViewController(history: history)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let history = filteredHistories[indexPath.row]
            
            let alert = UIAlertController(title: "删除记录", message: "确定要删除这条截屏记录吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
                TCScreenshotHistoryManager.shared.removeScreenshotHistory(history)
                self?.loadData()
            })
            
            present(alert, animated: true)
        }
    }
} 
