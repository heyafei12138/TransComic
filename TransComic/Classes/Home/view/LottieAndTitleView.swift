//
//  LottieAndTitleView.swift
//  TranslationAnime
//
//  Created by hebert on 2025/8/1.
//

import UIKit
import Lottie
import SnapKit


class LottieAndTitleView: UIView {

    // MARK: - 公共属性
    var title: String = "" {
        didSet {
            titleLabel.text = title
//            updateLayout()
        }
    }

    var onTap: (() -> Void)?

    /// 设置 Lottie 动效文件名（无需后缀），设置后自动播放
    var animationName: String = "web" {
        didSet {
            loadAnimation(named: animationName)
        }
    }

    // MARK: - 私有视图
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        return view
    }()

    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTap()
        loadAnimation(named: animationName)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupTap()
        loadAnimation(named: animationName)
    }

    // MARK: - UI 设置
    private func setupUI() {
        layer.cornerRadius = 8
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        clipsToBounds = true

        addSubview(titleLabel)
        addSubview(animationView)

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(12)
            make.right.equalToSuperview().inset(48)

        }

        animationView.snp.makeConstraints { make in
//            make.left.equalTo(titleLabel.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(24)
        }
    }

    // MARK: - 点击事件
    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - 设置动效
    private func loadAnimation(named name: String) {
        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
            animationView.play()
            animationView.animationSpeed = 0.8
        } else {
            print("⚠️ 动效文件 '\(name)' 未找到")
        }
    }

    // MARK: - 动态调整
//    private func updateLayout() {
//        setNeedsLayout()
//        layoutIfNeeded()
//    }
}
