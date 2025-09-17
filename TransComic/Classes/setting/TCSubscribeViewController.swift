//
//  TCSubscribeViewController.swift
//  TransComic
//
//  Created by Assistant on 2025/08/20.
//

import UIKit
import SnapKit
import StoreKit

final class TCSubscribeViewController: BaseViewController {
    
    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let contentContainer = UIView()
    
    private let weeklyOption = SubscriptionOptionView()
    private let monthlyOption = SubscriptionOptionView()
    private let yearlyOption = SubscriptionOptionView()
    
    private let payButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("立即支付".localized(), for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = UIColor.black
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        return btn
    }()
    
    private let linksContainer = UIView()
    private let privacyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("隐私政策".localized(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        return btn
    }()
    private let termsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("用户协议".localized(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        return btn
    }()
    private let restoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("恢复购买".localized(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        return btn
    }()
    
    private var selectedProductId: String = SubscriptionProduct.weekly.rawValue
    private var productMap: [String: SKProduct] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订阅会员".localized()
        setupNav()
        setupUI()
        setupActions()
        loadProducts()
    }
    
    private func setupNav() {
        customNav.setLeftButton(title: "返回".localized(), titleColor: .black)
        customNav.leftButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        customNav.setBottomLineHidden(true)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(backgroundImageView)
        view.addSubview(contentContainer)
        view.addSubview(payButton)
        view.addSubview(linksContainer)
        
        backgroundImageView.image = UIImage(named: "phone_bgImage")
        
        contentContainer.addSubview(weeklyOption)
        contentContainer.addSubview(monthlyOption)
        contentContainer.addSubview(yearlyOption)
        
        linksContainer.addSubview(privacyButton)
        linksContainer.addSubview(termsButton)
        linksContainer.addSubview(restoreButton)
        
        weeklyOption.configure(title: SubscriptionProduct.weekly.displayName, subtitle: "限时优惠".localized(), priceText: "$5.99", isSelected: true)
        monthlyOption.configure(title: SubscriptionProduct.monthly.displayName, subtitle: nil, priceText: "$19.99", isSelected: false)
        yearlyOption.configure(title: SubscriptionProduct.yearly.displayName, subtitle: nil, priceText: "$199.99", isSelected: false)
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
        }
        
        contentContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(customNav.snp.bottom).offset(40)
        }
        
        weeklyOption.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(84)
        }
        monthlyOption.snp.makeConstraints { make in
            make.top.equalTo(weeklyOption.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(84)
        }
        yearlyOption.snp.makeConstraints { make in
            make.top.equalTo(monthlyOption.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(84)
            make.bottom.equalToSuperview()
        }
        
        payButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(linksContainer.snp.top).offset(-16)
            make.height.equalTo(52)
        }
        
        linksContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-kBottomSafeHeight - 12)
            make.height.equalTo(20)
        }
        
        privacyButton.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        termsButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        restoreButton.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
        }
    }
    
    private func setupActions() {
        weeklyOption.onTap = { [weak self] in self?.select(product: .weekly) }
        monthlyOption.onTap = { [weak self] in self?.select(product: .monthly) }
        yearlyOption.onTap = { [weak self] in self?.select(product: .yearly) }
        
        weeklyOption.addTarget(self, action: #selector(weeklyTapped), for: .touchUpInside)
        monthlyOption.addTarget(self, action: #selector(monthlyTapped), for: .touchUpInside)
        yearlyOption.addTarget(self, action: #selector(yearlyTapped), for: .touchUpInside)

        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(openPrivacy), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
    }
    
    private func loadProducts() {
        IAPManager.shared.fetchProductsInfo(SubscriptionProduct.allCases) { [weak self] map in
            DispatchQueue.main.async {
                self?.productMap = map
                self?.updatePriceTexts()
            }
        }
    }
    
    private func updatePriceTexts() {
        if let p = productMap[SubscriptionProduct.weekly.rawValue] {
            weeklyOption.updatePrice(p.localizedPriceString)
        }
        if let p = productMap[SubscriptionProduct.monthly.rawValue] {
            monthlyOption.updatePrice(p.localizedPriceString)
        }
        if let p = productMap[SubscriptionProduct.yearly.rawValue] {
            yearlyOption.updatePrice(p.localizedPriceString)
        }
    }
    
    private func select(product: SubscriptionProduct) {
        selectedProductId = product.rawValue
        weeklyOption.setSelected(product == .weekly)
        monthlyOption.setSelected(product == .monthly)
        yearlyOption.setSelected(product == .yearly)
    }
    
    @objc private func weeklyTapped() { select(product: .weekly) }
    @objc private func monthlyTapped() { select(product: .monthly) }
    @objc private func yearlyTapped() { select(product: .yearly) }
    
    @objc private func payTapped() {
//        IAPManager.shared.purchase(productId: selectedProductId) { [weak self] success, message in
//            DispatchQueue.main.async {
//                if success {
//                    ProgressHUD.showSuccess("购买成功".localized())
//                    self?.navigationController?.popViewController(animated: true)
//                } else {
//                    ProgressHUD.showError(message ?? "购买失败".localized())
//                }
//            }
//        }
    }
    
    @objc private func restorePurchases() {
//        IAPManager.shared.restorePurchases { success, message in
//            DispatchQueue.main.async {
//                if success {
//                    ProgressHUD.showSuccess("恢复成功".localized())
//                } else {
//                    ProgressHUD.showError(message ?? "恢复失败".localized())
//                }
//            }
//        }
    }
    
    @objc private func openPrivacy() {
        let vc = TCWebViewController(title: "隐私政策".localized(), urlString: "https://sleep.leaphealth.fitness/privacypolicy.html")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func openTerms() {
        let vc = TCWebViewController(title: "用户协议".localized(), urlString: "https://docs.qq.com/doc/DVEZZb0dKRkRqa09x")
        navigationController?.pushViewController(vc, animated: true)
    }
}

private final class SubscriptionOptionView: UIControl {
    
    var onTap: (() -> Void)?
    
    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.clear.cgColor
        v.clipsToBounds = true
        return v
    }()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 16)
        l.textColor = .black
        return l
    }()
    private let subLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .systemRed
        return l
    }()
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 18)
        l.textColor = .black
        l.textAlignment = .right
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(subLabel)
        container.addSubview(priceLabel)
        // 关闭内部容器交互，保证事件传递到 UIControl
        container.isUserInteractionEnabled = false
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.right.lessThanOrEqualTo(priceLabel.snp.left).offset(-8)
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(titleLabel)
            make.right.lessThanOrEqualTo(priceLabel.snp.left).offset(-8)
            make.bottom.lessThanOrEqualToSuperview().offset(-14)
        }
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-14)
        }
        
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        // 增大可点区域，避免细小控件难点到
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        addGestureRecognizer(tap)
    }
    
    func configure(title: String, subtitle: String?, priceText: String, isSelected: Bool) {
        titleLabel.text = title
        subLabel.text = subtitle
        subLabel.isHidden = (subtitle == nil)
        priceLabel.text = priceText
        setSelected(isSelected)
    }
    
    func updatePrice(_ text: String) {
        priceLabel.text = text
    }
    
    func setSelected(_ selected: Bool) {
        container.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        container.backgroundColor = selected ? UIColor.white : UIColor.white.withAlphaComponent(0.9)
    }
    
    @objc private func tapped() {
        onTap?()
    }
    @objc private func tapGesture() {
        onTap?()
        sendActions(for: .touchUpInside)
    }
}


