//
//  GoogleBooks.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 18/05/21.
//

import Foundation
import UIKit
class VolumeData: NSObject, Decodable
{
    
    var books: [BookData]?
    private enum CodingKeys: String, CodingKey { case books = "items"
    }
}
class BookData: NSObject, Decodable{
    required init(from decoder: Decoder) throws {
        // Get the root container first
        let rootContainer = try decoder.container(keyedBy: RootKeys.self) // Get the book container for most info
        let bookContainer = try rootContainer.nestedContainer(keyedBy: BookKeys.self, forKey: .volumeInfo)
        // Get the image links container for the thumbnail
        let imageContainer = try? bookContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .imageLinks)
        title = try bookContainer.decode(String.self, forKey: .title)
        publisher = try? bookContainer.decode(String.self, forKey: .publisher)
        publicationDate = try? bookContainer.decode(String.self, forKey:
        .publicationDate)
        bookDescription = try? bookContainer.decode(String.self, forKey:
            .bookDescription)
        if let authorArray = try? bookContainer.decode([String].self, forKey: .authors) {
            authors = authorArray.joined(separator: ", ")
        }
        if let isbnCodes = try? bookContainer.decode([ISBNCode].self, forKey:
            .industryIdentifiers) {
            // Loop through array and find the ISBN13
            for code in isbnCodes
            {
                if code.type == "ISBN_13"
                {
                    isbn13 = code.identifier
                }
                
            }
            
        }
        imageURL = try imageContainer?.decode(String.self, forKey: .smallThumbnail)
            }
    var isbn13: String?
    var title: String
    var authors: String?
    var publisher: String?
    var publicationDate: String?
    var bookDescription: String?
    var imageURL: String?
    var image: UIImage?
    private enum RootKeys: String, CodingKey {
        case volumeInfo
    
    }
    private enum BookKeys: String, CodingKey { case title
    case publisher
    case publicationDate = "publishedDate"
    case bookDescription = "description"
    case authors
    case industryIdentifiers
    case imageLinks
    }
    private enum ImageKeys: String, CodingKey {
        case smallThumbnail
    }
    private struct ISBNCode: Decodable { var type: String
    var identifier: String
    }
    
}
