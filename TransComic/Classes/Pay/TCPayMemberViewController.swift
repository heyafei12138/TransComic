//
//  TCPayMemberViewController.swift
//  TransComic
//
//  Created by 贺亚飞 on 2025/9/10.
//

import UIKit
import AVFoundation
import SnapKit

import UIKit
import SnapKit
import ImageIO

class TCPayMemberViewController: BaseViewController {
    
    private let backgroundImageView = UIImageView()
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)   // 你可以改成 .light / .extraLight / .systemUltraThinMaterial
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0.5   // 毛玻璃透明度（调节模糊程度）
        return view
    }()
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        return button
    }()
    
    private let payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("立即支付", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = mainColor
        button.layer.cornerRadius = 24
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    let priceView = TCPriceChooseView()

    var selectedIndex: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGifBackground()
        setupUI()
        setupActions()
        
        // 3 秒后显示关闭按钮
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.closeButton.isHidden = false
        }
        IAPManager.shared.fetchProductsInfo {[weak self] maps in
            guard let self = self else { return }
            for (_, map) in maps.enumerated() {
                if map.key == SubscriptionProduct.weekly.rawValue{
                    priceView.updateDescription(at: 0, text: map.value)

                }
                if map.key == SubscriptionProduct.monthly.rawValue{
                    priceView.updateDescription(at: 1, text: map.value)

                }
                if map.key == SubscriptionProduct.yearly.rawValue{
                    priceView.updateDescription(at: 2, text: map.value)

                }
            }
            
        }
    }
    
    private func setupGifBackground() {
        guard let path = Bundle.main.path(forResource: "payInfo", ofType: "gif"),
              let data = NSData(contentsOfFile: path) else {
            print("⚠️ 没找到 background.gif")
            return
        }
        
        // 把 GIF 拆帧
        guard let source = CGImageSourceCreateWithData(data, nil) else { return }
        var images: [UIImage] = []
        var duration: Double = 0
        
        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                // 获取每帧时间
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as Dictionary?
                if let gifDict = properties?[kCGImagePropertyGIFDictionary] as? NSDictionary,
                   let delay = gifDict[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber {
                    duration += delay.doubleValue
                }
            }
        }
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.animationImages = images
        backgroundImageView.animationDuration = duration
        backgroundImageView.startAnimating()
        
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
       
    }
    
    private func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(payButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
        
        payButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(56)
        }
        priceView.backgroundColor = .clear
        view.addSubview(priceView)
        priceView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.width.equalTo(kScreenW - 32)
            make.height.equalTo(158)
            make.bottom.equalTo(payButton.snp.top).offset(-40)
        }
        priceView.onSelectionChanged = { [weak self] index1 in
            guard let self = self else { return }
            self.selectedIndex = index1
            
        }
        
        let desLabel = UILabel()
        view.addSubview(desLabel)
        desLabel.text = "畅享VIP功能".localized()
        desLabel.textColor = .white
        desLabel.font = middleFont(fontSize: 14)
        desLabel.font = UIFont.boldSystemFont(ofSize: 16)
        desLabel.snp.makeConstraints { make in
            make.bottom.equalTo(priceView.snp.top).offset(-40)
            make.centerX.equalToSuperview().offset(10)
            make.width.lessThanOrEqualTo(kScreenW - 80)

        }
        
        let iconView = UIImageView()
        view.addSubview(iconView)
        iconView.image = UIImage(named: "recommit_white")
        iconView.snp.makeConstraints { make in
            make.centerY.equalTo(desLabel)
            make.right.equalTo(desLabel.snp.left).offset(-2)
            make.width.height.equalTo(24)
        }
        
        let desLabel2 = UILabel()
        view.addSubview(desLabel2)
        desLabel2.text = "没有广告，清爽体验".localized()
        desLabel2.textColor = .white
        desLabel2.font = middleFont(fontSize: 14)
        desLabel2.font = UIFont.boldSystemFont(ofSize: 16)
        desLabel2.snp.makeConstraints { make in
            make.bottom.equalTo(desLabel.snp.top).offset(-20)
            make.left.right.equalTo(desLabel)
        }
        
        let iconView2 = UIImageView()
        view.addSubview(iconView2)
        iconView2.image = UIImage(named: "recommit_white")
        iconView2.snp.makeConstraints { make in
            make.centerY.equalTo(desLabel2)
            make.right.equalTo(desLabel2.snp.left).offset(-2)
            make.width.height.equalTo(24)
        }
        
 
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func payTapped() {
        print("💰 点击支付按钮")
        // TODO: 支付逻辑
    }
}
