//
//  ViewExtension.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/8.
//

import Foundation
extension UIView {
    
    func cornerRoundPath(bounds:CGRect, corners: UIRectCorner, radius: CGFloat) {
        // 强制布局以确保 bounds 已更新
//        self.layoutIfNeeded()
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// Applies a uniform corner radius to the view
    func cornerlayer(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    /// x position of the view
    var x: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    /// y position of the view
    var y: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    /// Center x of the view
    var centerX: CGFloat {
        get { return self.center.x }
        set { self.center = CGPoint(x: newValue, y: self.center.y) }
    }
    
    /// Center y of the view
    var centerY: CGFloat {
        get { return self.center.y }
        set { self.center = CGPoint(x: self.center.x, y: newValue) }
    }
    
    /// Height of the view
    var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    /// Width of the view
    var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    /// Size of the view
    var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    /// Returns the distance from the left of the parent view
    func left() -> CGFloat {
        return frame.origin.x
    }
    
    /// Sets the left position of the view relative to its parent
    func setLeft(left: CGFloat) {
        frame.origin.x = left
    }
    
    /// Returns the distance from the right of the parent view
    func right() -> CGFloat {
        return frame.maxX
    }
    
    /// Sets the right position of the view relative to its parent
    func setRight(right: CGFloat) {
        frame.origin.x = right - self.width
    }
    
    /// Returns the distance from the top of the parent view
    func top() -> CGFloat {
        return frame.origin.y
    }
    
    /// Sets the top position of the view relative to its parent
    func setTop(top: CGFloat) {
        frame.origin.y = top
    }
    
    /// Returns the distance from the bottom of the parent view
    func bottom() -> CGFloat {
        return frame.maxY
    }
    
    /// Sets the bottom position of the view relative to its parent
    func setBottom(bottom: CGFloat) {
        frame.origin.y = bottom - self.height
    }
    
    /// Adds an array of subviews to the view
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
    
    /// Finds a subview by its tag
    func viewWithTag(tag: Int) -> UIView? {
        if self.tag == tag {
            return self
        }
        
        for subview in self.subviews {
            if let foundView = subview.viewWithTag(tag) {
                return foundView
            }
        }
        
        return nil
    }
    
    /// Removes all subviews from the view
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as! T
    }
}
