//
//  GuiderVC.swift
//  TransComic
//
//  Created by hebert on 2025/9/17.
//

import UIKit
import SafariServices
import SwiftyUserDefaults
class GuiderVC: UIViewController,UIScrollViewDelegate {
    
    private var scrollView: UIScrollView!
    private var pageControl: UIPageControl!
    let backBtn = UIButton(type: .custom)
    let titles = ["Accurate & Fluent Translation".localized(),
                  "Instant Scan & Translate".localized(),
                  "User-Friendly Interface".localized(),"TransComic-Instant & Easy".localized()]
    let subTitles = ["Preserve the original meaning while making the dialogue natural and enjoyable.".localized(),
                     "Translate text directly from manga pages in seconds.".localized(),
                     "Read comics in English, Japanese, Korean, Chinese, and more.".localized(),"Enjoy all features free for 3 days, cancel anytime before renewal at $1.99 per week.".localized()]
    let images = ["guider02", "guider04", "guider05","guider01"]
    var titleItems : [UILabel] = []
    var destitleItems : [UILabel] = []

    var priceLabel : UILabel!
    private let numberOfPages = 4
    private let buttonHeight: CGFloat = 48
    let terms_button = {
        let  button = UIButton(type: .custom)
        let underlineAttributes: [NSAttributedString.Key: Any] = [
                   .underlineStyle: NSUnderlineStyle.single.rawValue,
                   .foregroundColor: UIColor(red: 0.749, green: 0.753, blue: 0.765, alpha: 1),
                   .font: sysfont(size: 13)
               ]

        let attributedString = NSAttributedString(string: "Terms".localized(), attributes: underlineAttributes)

       button.setAttributedTitle(attributedString, for: .normal)
        button.contentHorizontalAlignment = .left
        return  button
    }()
    
    let privacy_button = {
        let  button = UIButton(type: .custom)
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(red: 0.749, green: 0.753, blue: 0.765, alpha: 1),
            .font: sysfont(size: 13)
        ]

        let attributedString = NSAttributedString(string: "Privacy".localized(), attributes: underlineAttributes)

       button.setAttributedTitle(attributedString, for: .normal)
        button.contentHorizontalAlignment = .right
        return  button
    }()
    let restore_button = {
        let  button = UIButton(type: .custom)
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(red: 0.749, green: 0.753, blue: 0.765, alpha: 1),
            .font: sysfont(size: 13)
        ]

        let attributedString = NSAttributedString(string: "Restore".localized(), attributes: underlineAttributes)

       button.setAttributedTitle(attributedString, for: .normal)
        button.contentHorizontalAlignment = .right
        return  button
    }()
    
    let textView : UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.text = "Subscription info:\n-Get access to all functions of the application.\n-You can turn off the auto-renewal at any time: you'll find the option to do this change to a different payment plan in the settings of your iTunes and App Store account.\n-Your account will be automatically charged for the subscription if you will not stop it before the end of the free trial.\n-The subscription is auto-renewing. You can stop the subscription at any moment;\n-Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal.".localized()
        textView.font = sysfont(size: 13)
        textView.textColor = .hexString("#454545")
        return textView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        
        delayGCD(timeInval: 1.0) {
            UIView.animate(withDuration: 0.5) {
                self.titleItems[0].alpha = 1
            }
            delayGCD(timeInval: 1.0) {
                UIView.animate(withDuration: 0.5) {
                    self.destitleItems[0].alpha = 1
                }
            }
        }
    }
    
    // 初始化 ScrollView
    private func setupScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(numberOfPages), height: view.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.isScrollEnabled = false
        
        for i in 0..<numberOfPages {
            let page = createPage(pageIndex: i)
            page.frame = CGRect(x: CGFloat(i) * view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(page)
        }
        
        backBtn.imageView?.contentMode = .center
        backBtn.setImage(UIImage(named: "close_icon"), for: .normal)
        backBtn.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kStatusBarHeight + 12)
            make.left.equalToSuperview().inset(20)
            make.size.equalTo(24)
        }
        backBtn.isHidden = true
        terms_button.addTarget(self, action: #selector(termsButtonClick), for: .touchUpInside)
        privacy_button.addTarget(self, action: #selector(privacyButtonClick), for: .touchUpInside)
        restore_button.addTarget(self, action: #selector(restoreHandel), for: .touchUpInside)

    }
    
    // 创建页面视图
    private func createPage(pageIndex: Int) -> UIView {
        let pageView = UIView()
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: images[pageIndex])
        pageView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(pageView)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.isUserInteractionEnabled = true
        let blurEffect = UIBlurEffect(style: .light) // 使用深色材质效果

        // 添加毛玻璃效果视图在底部
        let blurView = UIVisualEffectView(effect: blurEffect)
        pageView.addSubview(blurView)

        // 设置毛玻璃视图的约束，覆盖底部区域
        blurView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(kStatusBarHeight + 300) // 根据内容调整高度
        }
        
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()

        titleLabel.text = titles[pageIndex]
        titleLabel.font = BoldFont(fontSize: 24)
        titleLabel.textAlignment = .center
        pageView.addSubview(titleLabel)
        
        descriptionLabel.text = subTitles[pageIndex]
        descriptionLabel.font = middleFont(fontSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        pageView.addSubview(descriptionLabel)
        titleLabel.textColor = .white
        descriptionLabel.textColor = .white
        
        let nextButton = UIButton(type: .custom)
//        nextButton.setTitle(pageIndex == numberOfPages - 1 ? "完成" : "下一页", for: .normal)
        nextButton.setTitle("Continue".localized(), for: .normal)
        nextButton.titleLabel?.font = middleFont(fontSize: 16)
        
        nextButton.tag = pageIndex
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        pageView.addSubview(nextButton)
        nextButton.backgroundColor = mainColor
        nextButton.layer.cornerRadius = 12
        nextButton.layer.masksToBounds = true
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalTo(pageView)
            make.width.equalTo(kScreenW - 40)
            make.height.equalTo(buttonHeight)
            make.bottom.equalTo(pageView).inset(kBottomSafeHeight + 98)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(pageView).offset(20)
            make.trailing.equalTo(pageView).inset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.bottom.equalTo(nextButton.snp.top).offset(-40)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(pageView).offset(20)
            make.trailing.equalTo(pageView).inset(20)
        }
//        descriptionLabel.textColor = .white
//        titleLabel.textColor = .white
        
        titleLabel.alpha = 0
        descriptionLabel.alpha = 0
        
        titleItems.append(titleLabel)
        destitleItems.append(descriptionLabel)
        
        if pageIndex == 3 {
            pageView.addSubview(terms_button)
            terms_button.snp.makeConstraints { make in
                make.left.equalTo(pageView).offset(20)
                make.height.equalTo(18)
                make.top.equalTo(nextButton.snp.bottom).offset(15)
                
            }
            
            pageView.addSubview(privacy_button)
            privacy_button.snp.makeConstraints { make in
                make.top.equalTo(terms_button)
                make.height.equalTo(18)
                make.centerX.equalTo(pageView)
            }
            pageView.addSubview(restore_button)
            restore_button.snp.makeConstraints { make in
                make.top.equalTo(terms_button)
                make.height.equalTo(18)
                make.right.equalTo(pageView).offset(-20)
            }
            pageView.addSubview(textView)
            textView.snp.makeConstraints { make in
                make.left.equalTo(pageView).offset(20)
                make.right.equalTo(pageView).offset(-20)
                make.top.equalTo(terms_button.snp.bottom).offset(10)
                make.bottom.equalToSuperview()
            }
            textView.isEditable = false
            terms_button.isHidden = true
            privacy_button.isHidden = true
            restore_button.isHidden = true
            priceLabel = descriptionLabel
        }
        
        return pageView
    }
    
    // 按钮点击事件
    @objc private func nextButtonTapped(_ sender: UIButton) {
        let currentPage = sender.tag
        
        if currentPage < numberOfPages - 1 {
            let nextOffset = CGPoint(x: CGFloat(currentPage + 1) * view.frame.width, y: 0)
            scrollView.setContentOffset(nextOffset, animated: true)
            
            delayGCD(timeInval: 1.0) {
                UIView.animate(withDuration: 0.5) {
                    self.titleItems[currentPage + 1].alpha = 1
                }
                
                delayGCD(timeInval: 1.0) {
                    UIView.animate(withDuration: 0.5) {
                        self.destitleItems[currentPage + 1].alpha = 1
                    }
                    
                    
                }
            }
            if currentPage == 2 {
                terms_button.isHidden = false
                privacy_button.isHidden = false
                restore_button.isHidden = false
                textView.isHidden = false
                delayGCD(timeInval: 3.0) {
                    self.backBtn.isHidden = false
                }
                var price = "$3.99"
                let priceArr = Defaults[\.priceArr]
                if priceArr.count == 2 {
                    price = priceArr[0]
                }
                priceLabel.text = "Enjoy all features free for 3 days, cancel anytime before renewal at \(price) per week."
            }
        } else {
            
            KLPayManager.shared.purchaseProduct("weekTransComic") {
                self.dismissVC()
               
            }
        }
    }
    @objc func termsButtonClick() {
        let safariLink = "https://docs.qq.com/doc/DVEZZb0dKRkRqa09x"
        if let url = URL(string: safariLink) {
           let safariViewController = SFSafariViewController(url: url)
           present(safariViewController, animated: true, completion: nil)
        }
    }
    
    @objc func privacyButtonClick() {
        let safariLink = "https://docs.qq.com/doc/DVFRYSEhZb2ZyekpG"
        if let url = URL(string: safariLink) {
           let safariViewController = SFSafariViewController(url: url)
           present(safariViewController, animated: true, completion: nil)
        }
    }
    @objc func restoreHandel(){
        KLPayManager.shared.restore {
            self.dismissVC()
        }
        
    }
    // 初始化页面指示器
    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.frame = CGRect(x: 0, y: view.frame.height - 100, width: view.frame.width, height: 20)
        pageControl.currentPageIndicatorTintColor = .blue
        pageControl.pageIndicatorTintColor = .gray
        view.addSubview(pageControl)
    }
    @objc func dismissVC(){
       
        kWindow?.rootViewController = UINavigationController(rootViewController: HomeViewController())
    }
    // 更新 PageControl 状态
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / view.frame.width)
//        pageControl.currentPage = page
    }
}

