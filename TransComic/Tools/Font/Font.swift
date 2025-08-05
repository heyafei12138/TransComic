//
//  File.swift
//  TranslationAnime
//
//  Created by hebert on 2025/7/27.
//

import Foundation
public func BoldFont(fontSize: CGFloat) -> UIFont {
   
    return UIFont(name: "ChillHuoFangSong-ConBold", size: fontSize) ?? .boldSystemFont(ofSize: fontSize)
}
public func middleFont(fontSize: CGFloat) -> UIFont {
   
    return UIFont(name: "ChillHuoFangSong_Regular", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: 0.23))
}
public func sysfont(size fontSize: CGFloat)-> UIFont {
    return UIFont(name: "ChillHuoFangSong_ConRegular", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: UIFont.Weight(rawValue: 0.23))
}
