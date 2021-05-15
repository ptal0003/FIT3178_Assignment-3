//
//  DownloadsViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 15/05/21.
//

import UIKit
import PDFKit
import CoreData
class StudentDownloadsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var myTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let downloadedBooks = downloadedBooks
        {
            return downloadedBooks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! DownloadBooksTableViewCell
        if let downloadedBooks = downloadedBooks{
        cell.nameLabel.text = downloadedBooks[indexPath.row].name
        cell.authorLabel.text = downloadedBooks[indexPath.row].author
        cell.informationView.text = downloadedBooks[indexPath.row].information
            cell.imageView?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
            cell.imageView?.layer.borderWidth = 2
            cell.imageView?.image = UIImage(data: downloadedBooks[indexPath.row].coverPage!)
           
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pdfView = PDFView()

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        navigationItem.title = downloadedBooks![indexPath.row].name
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfView.document = PDFDocument(data: downloadedBooks![indexPath.row].pdfData!)
        
    }
    var downloadedBooks: [DownloadedBook]?
    override func viewDidLoad() {
        myTableView.delegate = self
        myTableView.dataSource = self
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        do{
        downloadedBooks = try context.fetch(DownloadedBook.fetchRequest())
        }
        catch{
            print(error)
        }
        myTableView.reloadData()
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
