//
//  Book.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 25/04/21.
//

import Foundation

class Book: NSObject, Decodable{
    var name: String
    var information: String
    var url: String
    var author: String
    init(bookName: String, information: String, url: String, author: String) {
        self.information = information
        self.name  = bookName
        self.url = url
        self.author = author
    }
}
