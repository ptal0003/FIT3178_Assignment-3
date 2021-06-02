//
//  showBookPDFViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 17/05/21.
//

import UIKit
import PDFKit
import CoreData
class showBookPDFViewController: UIViewController, PDFFunctionalityDelegate{
    @IBOutlet weak var addBookmarkButton: UIBarButtonItem!
    
    func sendPDFPage(_ pdfPage: Int) {
        if let pdfView = pdfView{
            let bookmarkPage = (pdfDoc?.page(at: pdfPage))!
            pdfView.go(to: bookmarkPage)
            pdfView.scrollSelectionToVisible(self)
            
        }
    }
    
    func sendPDFSelect(_ pdfSelection: PDFSelection) {
        if let pdfView = pdfView{
            
            pdfView.setCurrentSelection(pdfSelection, animate: true)
            pdfView.currentSelection?.color = UIColor.red
            pdfView.scrollSelectionToVisible(self)
           
            
        }
    }
    
    @IBAction func bookmarkButton(_ sender: UIBarButtonItem) {
        showAlertWithTF()
    }
    override func viewWillAppear(_ animated: Bool) {
        handlePageChange()
    }
    func showAlertWithTF() {
            let alertController = UIAlertController(title: "Add a boookmark", message: nil, preferredStyle: .alert)
            let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
                if let txtField = alertController.textFields?.first, let text = txtField.text {
                    let newBookmark = NSEntityDescription.insertNewObject(forEntityName: "Bookmark", into: (self.selectedBook?.managedObjectContext)!) as! Bookmark
                    
                    newBookmark.name = text
                    newBookmark.page = Int32(self.pdfDoc!.index(for: (self.pdfView?.currentPage)!))
                    self.selectedBook?.addToBookmarks(newBookmark)
                    do {
                        try self.selectedBook?.managedObjectContext!.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                    
                    self.handlePageChange()
                

                      
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            alertController.addTextField { (textField) in
                textField.placeholder = "Bookmark name:"
            }
            alertController.addAction(addAction)
            alertController.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
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
            self.performSegue(withIdentifier: "showBookmarksSegue", sender: self)
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
            handlePageChange()
            NotificationCenter.default.addObserver (self, selector: #selector(handlePageChange), name: Notification.Name.PDFViewPageChanged, object: nil)
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    @objc func handlePageChange(){
        if let allBookmarks = selectedBook?.bookmarks?.allObjects {
            let allBookmarks = allBookmarks as! [Bookmark]
            for bookmark in allBookmarks{
                guard let pageNumber =
                        pdfDoc?.index(for: pdfView!.currentPage!) else {
                    return
                }
                if bookmark.page == pageNumber
                {
                    
                    
                    addBookmarkButton.isEnabled = false
                    break
                }
                else{
                    addBookmarkButton.isEnabled = true
                }
            }
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchInsideBookSegue"{
            
            let destVC = segue.destination as! SearchWordsTableViewController
            destVC.currentPDFDoc = pdfDoc
            destVC.delegate = self
        }
        if segue.identifier == "showBookmarksSegue"
        {
            let destVC = segue.destination as! ShowBookmarksTableViewController
            destVC.currentBook = selectedBook
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
