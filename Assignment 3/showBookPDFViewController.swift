//
//  showBookPDFViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 17/05/21.
//

import UIKit
import PDFKit
class showBookPDFViewController: UIViewController, SearchWordDelegate{
    func sendPDFSelect(_ pdfSelection: PDFSelection) {
        if let pdfView = pdfView{
            pdfView.setCurrentSelection(pdfSelection, animate: true)
            pdfView.currentSelection?.color = UIColor.red
            pdfView.scrollSelectionToVisible(self)
            
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var selectedBook: DownloadedBook?
    var searchResult: [PDFSelection] = []
    var pdfView: PDFView?
    var pdfDoc: PDFDocument?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = selectedBook?.name
        pdfView = PDFView()
        if let pdfView = pdfView{
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfView.autoScales = true
        if let selectedBook = selectedBook{
            var myDoc = PDFDocument(data: selectedBook.pdfData!)
            pdfView.document = myDoc
            pdfDoc = myDoc
            
        }
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func findME(_ sender: UIBarButtonItem) {
        if let selectedBook = selectedBook{
            var myDoc = PDFDocument(data: selectedBook.pdfData!)
            if let pdfView = pdfView{
            pdfView.document = myDoc
            searchResult = (myDoc?.findString("book", withOptions: .regularExpression))!
            
            pdfView.setCurrentSelection(searchResult[0], animate: true)
            pdfView.currentSelection?.color = UIColor.red
            pdfView.scrollSelectionToVisible(self)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchInsideBookSegue"{
            let destVC = segue.destination as! SearchWordsTableViewController
            destVC.currentPDFDoc = pdfDoc
            destVC.delegate = self
        }
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
