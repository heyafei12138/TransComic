//
//  DictionaryExtension.swift
//  TranslationAI
//
//  Created by 贺亚飞 on 2025/4/17.
//

import Foundation
extension Dictionary {

    func jsonPrint() {
        let ff = try! JSONSerialization.data(withJSONObject:self, options: [])
        let str = String(data:ff, encoding: .utf8)
        print(str!)
    }

}

extension Array {
    
    func jsonPrint() {let ff = try! JSONSerialization.data(withJSONObject:self, options: [])
        let str = String(data:ff, encoding: .utf8)
        print(str!)
    }
    
}

