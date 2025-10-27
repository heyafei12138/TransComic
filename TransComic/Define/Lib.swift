//
//  Lib.swift
//  TransComic
//
//  Created by hebert on 2025/8/6.
//

import Foundation
import StoreKit
import Toast_Swift


let TCGroupID = "group.TranslationComic"
let TCAppID = "6749008967"
public let StoreShareKey: String = "fad7f0c870914ada978f48c5edd485e9"

//延迟执行
func delayGCD (timeInval:CGFloat, completion: (() -> Void)? = nil) {
    DispatchQueue.main.asyncAfter(deadline: .now() + timeInval) {
        completion!()
    }
}

func Toast(_ message: String, position: ToastPosition = .center) {
    DispatchQueue.main.async {
        kWindow?.makeToast(message, duration: 2 , position: position)
    }
}

func Loading() {
    DispatchQueue.main.async {
        kWindow?.isUserInteractionEnabled = false
        kWindow?.makeToastActivity(.center)
    }
}

func HideLoading() {
    DispatchQueue.main.async {
        kWindow?.isUserInteractionEnabled = true
        kWindow?.hideToastActivity()
    }
}
func requestAppReview() {
    if #available(iOS 14.0, *) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            SKStoreReviewController.requestReview()
        }
    } else {
        SKStoreReviewController.requestReview()
    }
}
