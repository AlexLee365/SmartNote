//
//  MemoData.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 27/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import Foundation

class MemoData {
    var uniqueKey: String
    var date: Date
    var text: String
    var isLocked: Bool = false
    var password: String = ""
    var isPinned: Bool = false
    
    init(date: Date, text: String) {
        self.uniqueKey = makeRandomString()
        self.date = date
        self.text = text
    }
    
    func returnTitle() -> String {
        var text = self.text
        
        return ""
    }
    
    func returnBody() -> String {
        var text = self.text
        
        
        return ""
    }
}

fileprivate func makeRandomString() -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let length = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< 10 {
        let rand = arc4random_uniform(length)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}
