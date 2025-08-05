//
//  TABaseViewController.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/12.
//

import UIKit


class BaseViewController: UIViewController {

    ///是否隐藏导航栏
    open var isHideCustomNav: Bool {
        get {
            return _isHideCustomNav
        }
        set {
            _isHideCustomNav = newValue
        }
    }

    // 需要引入一个存储属性来保存值
    private var _isHideCustomNav: Bool = false

    open override var title: String?{
        didSet{
            isHideCustomNav ? nil : (customNav.navigationBarTitle = title)
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    ///设置返回手势
    public var isPopGestureEnabled:Bool = false
    
    
    open lazy var customNav = NavigationBar()
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if navigationController?.interactivePopGestureRecognizer?.isEnabled != isPopGestureEnabled{
            navigationController?.interactivePopGestureRecognizer?.isEnabled = isPopGestureEnabled
        }
        ///接听电话或自定义拍照收起后导状态栏下移，高度增加20
        if (self.navigationController?.view.height ?? kScreenH) - kScreenH == kStatusBarHeight {
            self.navigationController?.viewControllers.forEach({$0.view.frame.size.height = kScreenH})
            self.navigationController?.view.frame.size.height = kScreenH
            
            let navVC =  UIApplication.jk.keyWindow?.rootViewController as? UINavigationController
            let barVC = navVC?.viewControllers.first as? UITabBarController
            barVC?.view.frame.size.height = kScreenH
        }
    }
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hexString("#F3F3F7")
        setupNavBar()
        setupUI()
        bindData()
    }
    
    private func setupUI(){
       
           
        
    }
    
    private func bindData(){
        ///调起子类UI初始化
//        if let vc = self as? LoadDataProvider{
//            vc.initData()
//            vc.loadData()
//        }
    }
    
    open func setupNavBar(){
        guard isHideCustomNav == false else { return }
        
        view.addSubview(customNav)
        
        customNav.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(kNavHeight)
        }
        
        customNav.leftButtonAction = {[weak self] in

            self?.onBackClick()
        }
//        customNav.navigationBarBackgroundImage = UIImage(named: "history_bg_title")
        
        if navigationController?.viewControllers.count ?? 1 > 1 {
//            let bundle = Bundle(path: (Bundle(for: BaseViewController.self).resourcePath ?? "") + "/LXBase.bundle")
            customNav.setLeftButton(normalImage: UIImage(named:"icon_webpag_back") ?? UIImage())
//            customNav.wr_setLeftButton(image: UIImage(named:"navbar_back_black",in: bundle, compatibleWith: nil) ?? UIImage())
        }
    }
    
    open func setupNavBarLeftButton() {
        if customNav.leftNavButton.isHidden, navigationController?.viewControllers.count ?? 1 > 1 {
//            let bundle = Bundle(path: (Bundle(for: BaseViewController.self).resourcePath ?? "") + "/LXBase.bundle")
//            customNav.wr_setLeftButton(image: UIImage(named:"navbar_back_black",in: bundle, compatibleWith: nil) ?? UIImage())
            customNav.setLeftButton(normalImage: UIImage(named:"icon_webpag_back") ?? UIImage())

        }
    }
    
    deinit {
        debugPrint("deinit----------------",self)
    }
    open func onBackClick(){
        popViewCon()
    }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func showLogin(){
    
    }

}
