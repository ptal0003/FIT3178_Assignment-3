//
//  DownloadsViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 16/05/21.
//

import UIKit
import CoreData
import PDFKit
class DownloadsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let downloadedBooks = downloadedBooks
        {
            return downloadedBooks.count
        }
        return 0
    }
    var allDownloadedBooks: [DownloadedBook] = []
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "downloadCell", for: indexPath) as! DownloadsCollectionViewCell
        if let downloadedBooks = downloadedBooks{
            cell.nameLabel.text = downloadedBooks[indexPath.row].name
            cell.imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
            cell.imageView.layer.masksToBounds = true
            cell.imageView.contentMode = .scaleToFill
            cell.imageView.layer.borderWidth = 2
            cell.imageView.image = UIImage(data: downloadedBooks[indexPath.row].coverPage!)
            cell.yearLabel.text = downloadedBooks[indexPath.row].author
        
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 165, height: 250)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                self.performSegue(withIdentifier: "showBookSegue", sender: self)
    }
    var downloadedBooks: [DownloadedBook]?
    @IBOutlet weak var myCollectionView: UICollectionView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        updateMyData()
        
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        viewDidLoad()
    }
    func updateMyData()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        
            do
            {
                downloadedBooks = []
                allDownloadedBooks = try context.fetch(DownloadedBook.fetchRequest())
                if allDownloadedBooks.count > 0{
                    for book in allDownloadedBooks{
                        if book.user == nil{
                        
                            downloadedBooks?.append(book)
                            
                        }
                        else{
                         
                        }
                    }
                }
            }
            catch{
                print(error)
            }
        
        myCollectionView.reloadData()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchBookSegue"
        {
            let destVC = segue.destination as! SearchBookStudentsViewController
            if let downloadedBooks = downloadedBooks{
                destVC.downloadedBooks = downloadedBooks
            }
      
        }
        if segue.identifier == "showBookSegue"
        {
            let destVC = segue.destination as! showBookPDFViewController
            if let selectedRow = myCollectionView.indexPathsForSelectedItems?.first
            {
                destVC.selectedBook = downloadedBooks![selectedRow.row]
            }
            
        }
    
}
}
