//
//  MemoData.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 27/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import Foundation
import CoreData

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
    
    func returnTitleAndBody() -> (String, String) {
        let text = self.text
        var title = ""
        var body = "추가 텍스트 없음"
        
        if text.contains("\n") {
            let component = text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true)
            title = String(component[0])
            body = String(component[1])
        } else {
            title = text
        }
        
        return (title, body)
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

func convertMemoDataFromCoreData(_ coreData: MemoCoreData) -> MemoData{
    var memoData = MemoData(date: Date(), text: "")
    
    memoData.uniqueKey = coreData.uniqueKey ?? ""
    memoData.date = coreData.date ?? Date()
    memoData.text = coreData.text ?? ""
    memoData.isLocked = coreData.isLocked
    memoData.password = coreData.password ?? ""
    memoData.isPinned = coreData.isPinned
    
    return memoData
}

func saveCoreDataFromMemoData(coreData: MemoCoreData, memoData: MemoData) {
    var memoCoreDataObject = coreData
    
    memoCoreDataObject.uniqueKey = memoData.uniqueKey
    memoCoreDataObject.date = memoData.date
    memoCoreDataObject.text = memoData.text
    memoCoreDataObject.isLocked = memoData.isLocked
    memoCoreDataObject.password = memoData.password
    memoCoreDataObject.isPinned = memoData.isPinned
    
}
