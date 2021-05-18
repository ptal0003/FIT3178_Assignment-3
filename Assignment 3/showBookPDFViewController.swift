//
//  showBookPDFViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 17/05/21.
//

import UIKit
import PDFKit
class showBookPDFViewController: UIViewController {
    var selectedBook: DownloadedBook?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedBook?.name
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfView.autoScales = true
        if let selectedBook = selectedBook{
            pdfView.document = PDFDocument(data: selectedBook.pdfData!)
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
