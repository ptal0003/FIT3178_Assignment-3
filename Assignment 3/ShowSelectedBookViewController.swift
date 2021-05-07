//
//  showSelectedBookViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 07/05/21.
//

import UIKit
import PDFKit
import Firebase
class ShowSelectedBookViewController: UIViewController {
    
    var currentBook: Book?
    override func viewDidLoad() {
        super.viewDidLoad()
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        if let currentBook = currentBook{
            nameLabel.text = currentBook.name
            authorLabel.text = currentBook.author
            informationView.text = currentBook.information
            let storageRef =  Storage.storage().reference(forURL: currentBook.url)
            storageRef.getData(maxSize: 25*1024*1024) { data, error in
                if let error = error {
                    print(error)
                }
                else if let data = data
                {
                    pdfView.document = PDFDocument(data: data)
                    
                }
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var informationView: UITextView!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}