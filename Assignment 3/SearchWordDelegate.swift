//
//  SearchWordDelegate.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 20/05/21.
//

import Foundation
import PDFKit
protocol SearchWordDelegate {
    func sendPDFSelect(_ pdfSelection: PDFSelection)
}
