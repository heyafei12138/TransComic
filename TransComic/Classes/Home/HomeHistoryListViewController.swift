//
//  HomeHistoryListViewController.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/1/27.
//

import UIKit

class HomeHistoryListViewController: BaseViewController {
    
    // MARK: - Properties
    private var histories: [HomeHistoryModel] = []
    private var filteredHistories: [HomeHistoryModel] = []
    private var selectedCategory: String?
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HomeHistoryCell.self, forCellReuseIdentifier: "HomeHistoryCell")
        tableView.rowHeight = 80
        return tableView
    }()
    
    private lazy var categorySegmentControl: UISegmentedControl = {
        let categories = ["全部"] + HomeHistoryManager.shared.getCategories()
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
        imageView.image = UIImage(named: "empty_icon")
        imageView.tintColor = UIColor.gray
        imageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "暂无历史记录"
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
        totalLabel.text = "总计"
        totalLabel.font = UIFont.systemFont(ofSize: 14)
        totalLabel.textColor = UIColor.gray
        
        let totalCountLabel = UILabel()
        totalCountLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totalCountLabel.textColor = mainColor
        
        let categoryLabel = UILabel()
        categoryLabel.text = "分类"
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = UIColor.gray
        
        let categoryCountLabel = UILabel()
        categoryCountLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        categoryCountLabel.textColor = mainColor
        
        view.addSubview(totalLabel)
        view.addSubview(totalCountLabel)
        view.addSubview(categoryLabel)
        view.addSubview(categoryCountLabel)
        
        totalLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        
        totalCountLabel.snp.makeConstraints { make in
            make.left.equalTo(totalLabel)
            make.top.equalTo(totalLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
        }
        
        categoryCountLabel.snp.makeConstraints { make in
            make.right.equalTo(categoryLabel)
            make.top.equalTo(categoryLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        // 更新统计数据
        updateStats(totalCountLabel: totalCountLabel, categoryCountLabel: categoryCountLabel)
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "历史记录"
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
        histories = HomeHistoryManager.shared.getHistories()
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
    
    private func updateStats(totalCountLabel: UILabel, categoryCountLabel: UILabel) {
        let totalCount = HomeHistoryManager.shared.getTotalCount()
        let categoryCount = HomeHistoryManager.shared.getCategories().count
        
        totalCountLabel.text = "\(totalCount) 条"
        categoryCountLabel.text = "\(categoryCount) 个"
    }
    
    // MARK: - Actions
    @objc private func categoryChanged() {
        if categorySegmentControl.selectedSegmentIndex == 0 {
            selectedCategory = nil
        } else {
            let categories = HomeHistoryManager.shared.getCategories()
            selectedCategory = categories[categorySegmentControl.selectedSegmentIndex - 1]
        }
        
        filterHistories()
        updateEmptyView()
        tableView.reloadData()
    }
    
    private func showClearConfirmation() {
        let alert = UIAlertController(title: "清空历史记录".localized(), message: "确定要清空所有历史记录吗？此操作不可恢复。".localized(), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "取消".localized(), style: .cancel))
        alert.addAction(UIAlertAction(title: "清空".localized(), style: .destructive) { [weak self] _ in
            self?.clearAllHistories()
        })
        
        present(alert, animated: true)
    }
    
    private func clearAllHistories() {
        HomeHistoryManager.shared.clearAllHistories()
        loadData()
    }
}

// MARK: - UITableViewDataSource
extension HomeHistoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHistoryCell", for: indexPath) as! HomeHistoryCell
        let history = filteredHistories[indexPath.row]
        cell.configure(with: history)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeHistoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let history = filteredHistories[indexPath.row]
        let detailVC = HomeHistoryDetailViewController(history: history)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let history = filteredHistories[indexPath.row]
            
            let alert = UIAlertController(title: "删除记录", message: "确定要删除这条历史记录吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
                HomeHistoryManager.shared.removeHistory(history)
                self?.loadData()
            })
            
            present(alert, animated: true)
        }
    }
}
