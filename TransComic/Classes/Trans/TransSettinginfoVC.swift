//
//  TransSettinginfoVC.swift
//  TranslationAnime
//
//  Created by hebert on 2025/8/2.
//

import UIKit

class TransSettinginfoVC: BaseViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupGuideTextView()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupGuideTextView() {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .link
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // 创建富文本内容
        let attributedString = NSMutableAttributedString()
        
        // 标题样式
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        
        // 副标题样式
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: mainColor
        ]
        
        // 步骤样式
        let stepAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        // 强调样式
        let highlightAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.systemOrange
        ]
        
        // 构建内容
        attributedString.append(NSAttributedString(
            string: "快捷翻译使用指南".localized() + "\n",
            attributes: titleAttributes))
        
        // 方式一
        attributedString.append(NSAttributedString(
            string: "方式一：双击背面触发（推荐）".localized(),
            attributes: subtitleAttributes))
        
        let method1Steps = [
            "1. 打开 系统设置 → 辅助功能 → 触控 → 轻点背面".localized(),
            "2. 选择 轻点两下".localized(),
            "3. 下拉到底部 快捷指令 区域".localized(),
            "4. 勾选 translationComic".localized(),
            "5. 使用：双击手机背面两下启动屏翻".localized()
        ]
        
        method1Steps.forEach {
            attributedString.append(NSAttributedString(
                string: "\n• \($0)",
                attributes: stepAttributes))
            
            
        }
        
        // 方式二
        attributedString.append(NSAttributedString(
            string: "\n" + "方式二：辅助触控按钮触发".localized(),
            attributes: subtitleAttributes))
        
        let method2Steps = [
            "1. 打开 系统设置 → 辅助功能 → 触控 → 辅助触控".localized(),
            "2. 开启 辅助触控 开关".localized(),
            "3. 选择 轻点一下".localized(),
            "4. 下拉到底部 快捷指令 区域".localized(),
            "5. 勾选 translationComic".localized(),
            "6. 使用：单击屏幕悬浮按钮启动屏翻".localized()
        ]
        
        method2Steps.forEach {
            attributedString.append(NSAttributedString(
                string: "\n• \($0)",
                attributes: stepAttributes))
            
            
        }
        
        // 关键提示
        attributedString.append(NSAttributedString(
            string: "\n" + "重要提示：".localized() + "\n",
            attributes: subtitleAttributes))
        
        attributedString.append(NSAttributedString(
            string: "• 确保快捷指令名称为 ".localized(),
            attributes: stepAttributes))
        
        let nameHighlight = NSAttributedString(
            string: "translationComic".localized(),
            attributes: highlightAttributes)
        attributedString.append(nameHighlight)
        
        // 设置段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.paragraphSpacing = 12
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length))
        
        textView.attributedText = attributedString
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 30, right: 16)
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: customNav.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
