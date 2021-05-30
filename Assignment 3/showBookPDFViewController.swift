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
    
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    let searchController = UISearchController(searchResultsController: nil)
    var selectedBook: DownloadedBook?
    var searchResult: [PDFSelection] = []
    var pdfView: PDFView?
    var pdfDoc: PDFDocument?
    
    override func viewDidLoad() {
        let searchAction = UIAction(title: "Search", image: UIImage(systemName: "magnifyingglass")) { action in
            self.performSegue(withIdentifier: "searchInsideBookSegue", sender: self)
        }
        let viewBookMarksAction = UIAction(title: "Bookmarks", image: UIImage(systemName: "book")) { action in
            self.performSegue(withIdentifier: "viewBookmarkSegue", sender: self)
        }
        barButtonItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: [searchAction,viewBookMarksAction])

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
            let myDoc = PDFDocument(data: selectedBook.pdfData!)
            pdfView.document = myDoc
            pdfDoc = myDoc
            
        }
        }
        
        // Do any additional setup after loading the view.
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
