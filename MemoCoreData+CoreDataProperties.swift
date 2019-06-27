//
//  MemoCoreData+CoreDataProperties.swift
//  
//
//  Created by 행복한 개발자 on 27/06/2019.
//
//

import Foundation
import CoreData


extension MemoCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoCoreData> {
        return NSFetchRequest<MemoCoreData>(entityName: "MemoCoreData")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var isLocked: Bool
    @NSManaged public var isPinned: Bool
    @NSManaged public var password: String?
    @NSManaged public var text: String?
    @NSManaged public var uniqueKey: String?

}
