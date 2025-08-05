//
//  HomeViewController.swift
//  TranslationAnime
//
//  Created by hebert on 2025/7/28.
//

import UIKit
import SnapKit

class HomeViewController: BaseViewController {
    // 顶部纵向卡片区
    private let card1 = HomeCardView()
    private let card2 = HomeCardView()
    // 右上角按钮
    private let settingButton = UIButton(type: .custom)
    private let vipButton = UIButton(type: .custom)
    // 底部历史记录区
    private let historyBgView = UIView()
    private let moreButton = UIButton(type: .system)
    private let historyTable = UITableView()
    let ImageView = UIImageView()

    private var historyData: [(icon: UIImage?, title: String, time: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexString("#F1F0FF")
        setupNav()
        setupCards()
        setupHistory()
        loadHistory()
    }
    
    private func setupNav() {
        // 右上角设置按钮
        settingButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingButton.tintColor = .black
        settingButton.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
        view.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(32)
        }
        // VIP按钮
        vipButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        vipButton.tintColor = UIColor.hexString("#FFD700")
        vipButton.addTarget(self, action: #selector(vipTapped), for: .touchUpInside)
        view.addSubview(vipButton)
        vipButton.snp.makeConstraints { make in
            make.centerY.equalTo(settingButton)
            make.trailing.equalTo(settingButton.snp.leading).offset(-16)
            make.width.height.equalTo(32)
        }
        
        
        ImageView.image = UIImage(named: "katong_top")
        view.addSubview(ImageView)
        ImageView.snp.makeConstraints { make in
            make.top.equalTo(vipButton.snp.bottom).offset(-20)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(kScreenW - 100)
            make.height.equalTo((kScreenW - 100)/1.8)
            
        }
    }
    
    private func setupCards() {
        // 第一个卡片
        card1.configure(bgImage: UIImage(named: "Subtract_bg1"), title: "快捷翻译漫画".localized(), desc: "一键翻译动漫台词，支持多语言。".localized(), demoImage: UIImage(named: "wanou01"),btnColor:.hexString("#FF9500"),lottiStr: "xuanfu"  )
        card1.startButton.addTarget(self, action: #selector(card1StartTapped), for: .touchUpInside)
        card1.backgroundColor = .hexString("#FFB86C")
        view.addSubview(card1)
        card1.onTap = { [weak self] in
            guard let self = self else { return }
            QuickTranTapped()
        }
        card1.snp.makeConstraints { make in
            make.top.equalTo(ImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }
        
        // 第二个卡片
        card2.configure(bgImage: UIImage(named: "Subtract_1"), title: "网页生番翻译".localized(), desc: "网页直达，轻松愉悦。".localized(), demoImage: UIImage(named: "wanou02"),btnColor: LmainColor)
        card2.backgroundColor = .hexString("#6E5FBF")
        card2.startButton.addTarget(self, action: #selector(card2StartTapped), for: .touchUpInside)
        view.addSubview(card2)
        card2.snp.makeConstraints { make in
            make.top.equalTo(card1.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setGradientBackground(view: self.view, mainColor: mainColor)
    }

    @objc private func QuickTranTapped() {
        pushViewCon(TransSettingVC())
       
    }
    @objc private func WebTranTapped() {
       
    }
    private func setupHistory() {
        // 半圆角背景
        historyBgView.backgroundColor = .white
        historyBgView.layer.cornerRadius = 24
        historyBgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        historyBgView.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        historyBgView.layer.shadowOpacity = 1
        historyBgView.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.addSubview(historyBgView)
        historyBgView.snp.makeConstraints { make in
            make.top.equalTo(card2.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
        // 查看更多按钮
        moreButton.setTitle("查看更多", for: .normal)
        moreButton.setTitleColor(UIColor.hexString("#007AFF"), for: .normal)
        moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        historyBgView.addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        // 历史记录列表
        historyTable.backgroundColor = .clear
        historyTable.separatorStyle = .none
        historyTable.showsVerticalScrollIndicator = false
        historyTable.register(HomeHistoryCell.self, forCellReuseIdentifier: "HomeHistoryCell")
        historyTable.dataSource = self
        historyTable.delegate = self
        historyBgView.addSubview(historyTable)
        historyTable.snp.makeConstraints { make in
            make.top.equalTo(moreButton.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(10)
        }
    }
    func setGradientBackground(view: UIView, mainColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds

        // 设置渐变颜色：从 mainColor 到透明
        gradientLayer.colors = [
            mainColor.cgColor,
            UIColor.white.cgColor
        ]

        // 设置渐变起点和终点（单位为百分比，(0,0)表示左上角，(1,1)表示右下角）
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // 左上角
        gradientLayer.endPoint = CGPoint(x: 0.3, y: 1.0) // 中间右侧位置

        // 移除已有渐变层（防止多次添加）
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        // 添加渐变层
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    private func loadHistory() {
        // 模拟历史数据
        historyData = [
            (UIImage(named: "demo1"), "翻译了台词：你好世界", "2025-07-28 10:00"),
            (UIImage(named: "demo2"), "识别图片并翻译", "2025-07-27 18:30"),
            (UIImage(named: "demo1"), "翻译了台词：早上好", "2025-07-27 09:12")
        ]
        historyTable.reloadData()
    }
    
    // MARK: - 交互逻辑
    @objc private func settingTapped() {
        // 跳转设置页
        print("设置按钮点击")
    }
    @objc private func vipTapped() {
        // 跳转VIP页
        print("VIP按钮点击")
    }
    @objc private func card1StartTapped() {
        // 动漫翻译入口
        print("动漫翻译立即开始")
    }
    @objc private func card2StartTapped() {
        // 图片识别入口
        print("图片识别立即开始")
    }
    @objc private func moreTapped() {
        // 查看更多历史
        print("查看更多历史")
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeHistoryCell", for: indexPath) as! HomeHistoryCell
        let item = historyData[indexPath.row]
        cell.configure(icon: item.icon, title: item.title, time: item.time)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("点击历史记录第\(indexPath.row)项")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 可根据需要处理滑动逻辑
    }
}
