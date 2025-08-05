//
//  Define.swift
//  TranslationAnime
//
//  Created by 贺亚飞 on 2025/7/25.
//

import Foundation
import SwiftMessages

class SwiftMessagesBottomSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomMessage)
    }
}
func MainThread (completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
        completion!()
    }
}
func afterGCD (timeInval:CGFloat, completion: (() -> Void)? = nil) {
    DispatchQueue.main.asyncAfter(deadline: .now() + timeInval) {
        completion!()
    }
}
func log(_ message: Any) {
    let string = "\(message)"
    if let data = string.data(using: .utf8),
       let converted = NSString(data: data, encoding: String.Encoding.nonLossyASCII.rawValue) {
        print("\(converted)")
    } else {
        print("\(message)")
    }
}
