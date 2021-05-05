//
//  Book.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 25/04/21.
//

import Foundation

class Book: NSObject, Encodable{
    var name: String
    var information: String
    var url: String
    init(_ bookName: String, _ information: String, url: String) {
        self.information = information
        self.name  = bookName
        self.url = url
    }
}
