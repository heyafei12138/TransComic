//
//  Progress.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/29.
//

import Foundation
import MBProgressHUD
public enum HUDType:String {
    case success = "progress_success"
    case error   = "progress_error"
    case loading = "progress_loading"
    case message = "progress_info"
    case custom  = "custom"
}

//public let ProgressLoadingView = ProgressHUD.loadingView
public class ProgressHUD: NSObject {
    
    private var HUD:MBProgressHUD? = MBProgressHUD()

    public static var isShowing :Bool{
        return ProgressHUD.shared.HUD?.superview != nil && !(ProgressHUD.shared.HUD?.isHidden ?? true)
    }
    private var type : HUDType?
        
    static let shared = ProgressHUD()
    
    static func createHUD(for view:UIView)->MBProgressHUD{
        let hud =  MBProgressHUD(view: view)
        hud.label.font = .boldSystemFont(ofSize: 18)
        hud.label.numberOfLines = 0
        hud.label.textColor = UIColor.black.withAlphaComponent(0.85)
        hud.backgroundView.isUserInteractionEnabled = false
        hud.bezelView.style = .solidColor
        hud.removeFromSuperViewOnHide = true
        hud.backgroundColor = .clear
        return hud
    }
    @discardableResult
    static public func showSuccess(_ status:String,view:UIView?=nil,delay:TimeInterval?=nil)->MBProgressHUD? {
        ProgressHUD.shared.showProgressHUD(type: .success, status: status, view: view, delay: delay)
        return ProgressHUD.shared.HUD
    }
    @discardableResult
    static public func showError(_ status:String,view:UIView?=nil,delay:TimeInterval?=nil)->MBProgressHUD?{
        ProgressHUD.shared.showProgressHUD(type: .error, status: status ,view: view, delay: delay)
        return ProgressHUD.shared.HUD
    }
    @discardableResult
    static public func showLoading(view:UIView?=nil,delay:TimeInterval?=nil)->MBProgressHUD?{
        ProgressHUD.shared.showProgressHUD(type: .loading, status: nil,view: view, delay: delay)
        return ProgressHUD.shared.HUD
    }
    @discardableResult
    static public func showMessage(_ status:String,view:UIView?=nil,delay:TimeInterval?=nil)->MBProgressHUD?{
        ProgressHUD.shared.showProgressHUD(type: .message, status: status, view: view, delay: delay)
        return ProgressHUD.shared.HUD
    }
    @discardableResult
    static public func showCustom(_ customView:UIView,view:UIView?=nil,delay:TimeInterval?=nil)->MBProgressHUD?{
        ProgressHUD.shared.showCustomProgressHUD(customView, view: view, delay: delay)
        return ProgressHUD.shared.HUD
    }
    @discardableResult
    static public func dismiss(_ delay:TimeInterval = 0 )->MBProgressHUD?{
        
        ProgressHUD.shared.dismiss(delay)
        return ProgressHUD.shared.HUD
    }
}

extension ProgressHUD{
    
    public func showProgressHUD(type:HUDType ,status:String?=nil,view:UIView?,delay:TimeInterval?){
        DispatchQueue.safeMainAsync {
 
            if let hud = ProgressHUD.shared.HUD, let _ = hud.superview{
                ProgressHUD.dismiss(0)
            }

            guard let currentView = view ?? kWindow else{
                return
            }
            

            let hud = ProgressHUD.createHUD(for: currentView)
            currentView.addSubview(hud)
            
            self.HUD = hud
            self.type = type
            
            switch type {
            case .message,.error,.success:

                hud.customView = nil
                hud.mode = .text
                hud.bezelView.color = .hexString("#323334")
                hud.label.textColor = .white
                hud.label.font = UIFont(name: "Nunito-Bold", size: 15)
                hud.label.text = status
                hud.show(animated: true)

                hud.hide(animated: true, afterDelay: delay ?? 3)
            case.loading:
                hud.mode = .indeterminate
                hud.bezelView.color = .white.withAlphaComponent(0.8)
                
//                let loadingView = ProgressHUD.loadingView
//
//                loadingView.startLoading()
//                hud.customView = loadingView
                hud.show(animated: true)
                
                if let time = delay,time > 0{
                    hud.hide(animated: true, afterDelay: time)
                }
                
            default:
                break
            }
        }
    }
    
    private func showCustomProgressHUD(_ customView:UIView,view:UIView?,delay:TimeInterval?){
        DispatchQueue.safeMainAsync {

            if let hud = ProgressHUD.shared.HUD, let _ = hud.superview{
                ProgressHUD.dismiss(0)
            }

            guard let currentView = view ?? kWindow else{
                return
            }

            let hud = ProgressHUD.createHUD(for: currentView)
            currentView.addSubview(hud)
            
            self.HUD = hud
            self.type = .custom
            
            hud.bezelView.color = UIColor.clear
            hud.mode = .customView
            hud.customView = customView
            hud.show(animated: true)
            
            let time = delay ?? 3
            hud.hide(animated: true, afterDelay: time)

        }
    }
    private func dismiss(_ delay:TimeInterval){
        
        DispatchQueue.safeMainAsync {
            
            if delay > 0{
                self.HUD?.hide(animated: true,afterDelay: delay)
            }else{
                self.HUD?.hide(animated: true)
            }
        }
    }
}
//extension AnimationView{
//    fileprivate func startLoading(){
//        ///注意：0.964-1之间的动画会出现闪烁
//        play(fromProgress: 0, toProgress: 0.963, loopMode: .loop, completion: nil)
//    }
//}



extension DispatchQueue{
    
    static func delay(_ interval:Double,block:@escaping ()->Void){
        
        if interval <= 0{
            block()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: block)
    }
}

extension MBProgressHUD{
//    open override func didMoveToWindow() {
//        super.didMoveToWindow()
//        if mode == .customView ,
//            self.isHidden == false,
//            self.alpha > 0,
//            let loadingView = customView as? AnimationView{
//            loadingView.startLoading()
//        }
//    }
//    private var touchArea:CGRect{
//        CGRect(x: 0, y: 0, width: 50, height: kNavBarHeight)
//    }
//
//    ///左上角可穿透
//    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let view = super.hitTest(point, with: event)
//        ///带导航的控制器的view,才可穿透，现在window根视图是导航控制器，要排除
//        if view == self,
//            self.mode == .customView,
//            let nav = view?.lx.viewController?.navigationController,
//            nav !== UIApplication.shared.keyWindow?.rootViewController,
//            nav.viewControllers.count > 1,
//            touchArea.contains(point){
//            return nil
//        }
//        return view
//    }
}
extension DispatchQueue{
   /// 主线程异步执行，当前在主线程则立即返回
   /// - Parameter block:
   static func safeMainAsync(_ block: @escaping ()->()) {
       self.main.safeAsync(block)
   }
   /// 主线程异步执行，当前在主线程则立即返回
   /// - Parameter block:
   func safeAsync(_ block: @escaping ()->()) {
       if self === DispatchQueue.main && Thread.isMainThread {
           block()
       } else {
           async(execute: block)
       }
   }
}
