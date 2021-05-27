//
//  DownloadedBook+CoreDataProperties.swift
//  
//
//  Created by Jyoti Talukdar on 27/05/21.
//
//

import Foundation
import CoreData


extension DownloadedBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadedBook> {
        return NSFetchRequest<DownloadedBook>(entityName: "DownloadedBook")
    }

    @NSManaged public var author: String?
    @NSManaged public var coverPage: Data?
    @NSManaged public var coverURL: String?
    @NSManaged public var edition: String?
    @NSManaged public var information: String?
    @NSManaged public var name: String?
    @NSManaged public var pdfData: Data?
    @NSManaged public var url: String?
    @NSManaged public var user: String?
    @NSManaged public var year: String?
    @NSManaged public var publisher: String?

}
