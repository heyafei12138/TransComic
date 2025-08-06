//
//  TransChooseLanguageVC.swift
//  TranslationAnime
//
//  Created by hebert on 2025/8/3.
//

import UIKit

class TransChooseLanguageVC: BaseViewController {
    
    private let tableView = UITableView()
    private let reuseId = "TransLanguageCell"
    private var selectedCode: Int?
    private let selectedKey = "SelectedLanguageCode"
    var selectedLanguageBlock: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSelection()
    }
    
    private func setupUI() {

        view.addSubview(tableView)
        
        let view = UIView()
        view.backgroundColor = .hexString("#dddddd")
        view.frame = CGRect(x: kScreenW/2 - 32, y: 10, width: 44, height: 6)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        self.view.addSubview(view)
        
        let desLabel = UILabel()
        desLabel.text = "选择目标语言".localized()
        desLabel.font = BoldFont(fontSize: 20)
        desLabel.textColor = black
        self.view.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(desLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(kBottomSafeHeight )
        }
        
        tableView.register(TransLanguageCell.self, forCellReuseIdentifier: reuseId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 8
        tableView.layer.masksToBounds = true
        
    }
    
    private func loadSelection() {
        selectedCode = UserDefaults.standard.integer(forKey: selectedKey)
        tableView.reloadData()
    }
    
    private func saveSelection(code: Int) {
        selectedCode = code
        UserDefaults.standard.set(code, forKey: selectedKey)
        tableView.reloadData()
        
        let userDefaults = UserDefaults(suiteName: TCGroupID) ?? .standard
        userDefaults.setValue(targetlanguages[code].code, forKey: "TCTargetCode")
    }
}

extension TransChooseLanguageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targetlanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! TransLanguageCell
        let language = targetlanguages[indexPath.row]
        let isSelected = indexPath.row == selectedCode
        cell.configure(with: language, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveSelection(code: indexPath.row)
        selectedLanguageBlock?()
        dismiss(animated: true)
    }
}
import UIKit

class TransLanguageCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let checkmarkImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with language: LanguageItem, isSelected: Bool) {
        titleLabel.text = language.name
        checkmarkImageView.isHidden = !isSelected
        titleLabel.textColor = isSelected ? mainColor : LmainColor.withAlphaComponent(0.8)
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)

        titleLabel.font = .systemFont(ofSize: 16)
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = mainColor
        checkmarkImageView.isHidden = true

        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        checkmarkImageView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
}

struct LanguageItem {
    let name: String
    let code: String
}
 let targetlanguages: [LanguageItem] = [
    .init(name: "简体中文", code: "zh-CHS"),
    .init(name: "中文繁体", code: "zh-CHT"),
    .init(name: "英语", code: "en"),
    .init(name: "日语", code: "ja"),
    .init(name: "韩语", code: "ko"),
    .init(name: "阿拉伯语", code: "ar"),
    .init(name: "德语", code: "de"),
    .init(name: "西班牙语", code: "es"),
    .init(name: "法语", code: "fr"),
    .init(name: "印地语", code: "hi"),
    .init(name: "印度尼西亚语", code: "id"),
    .init(name: "意大利语", code: "it"),
    .init(name: "荷兰语", code: "nl"),
    .init(name: "葡萄牙语", code: "pt"),
    .init(name: "俄语", code: "ru"),
    .init(name: "泰语", code: "th"),
    .init(name: "越南语", code: "vi"),

]
