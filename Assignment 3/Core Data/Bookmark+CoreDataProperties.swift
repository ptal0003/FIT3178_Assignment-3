//
//  Bookmark+CoreDataProperties.swift
//  
//
//  Created by Jyoti Talukdar on 31/05/21.
//
//

import Foundation
import CoreData


extension Bookmark {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bookmark> {
        return NSFetchRequest<Bookmark>(entityName: "Bookmark")
    }

    @NSManaged public var name: String?
    @NSManaged public var page: Int64
    @NSManaged public var book: DownloadedBook?

}
