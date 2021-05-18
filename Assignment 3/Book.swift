//
//  Book.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 25/04/21.
//

import UIKit
import Foundation
class Book: NSObject{
    var name: String
    var information: String
    var url: String
    var author: String
    var coverURL: String
    var coverImage: UIImage
    init(bookName: String, information: String, url: String, author: String, coverURL: String, coverImage: UIImage) {
        self.information = information
        self.name  = bookName
        self.url = url
        self.author = author
        self.coverURL = coverURL
        self.coverImage = coverImage
    }
}
