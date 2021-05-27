//
//  ShowBookStudentViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 13/05/21.
//

import UIKit
import CoreData
import Firebase
import PDFKit
let NOTIFICATION_IDENTIFIER = "edu.monash.fit3178.Workshop10"
let sectionInsets1 = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
class ShowBookStudentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var editionLabel: UILabel!
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return otherBooksByAuthor.count
    }
    
    var user: String?
    @IBAction func downloadBook(_ sender: Any) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let storageRef =  Storage.storage().reference(forURL: currentBook!.url)
        let coverRef = Storage.storage().reference(forURL: currentBook!.coverURL)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
            
        
        storageRef.getData(maxSize: 25*1024*1024) { [self] data, error in
            if let error = error {
                print(error)
            }
            else if let data = data
            {
                
                        let book = NSEntityDescription.insertNewObject(forEntityName: "DownloadedBook", into: context) as! DownloadedBook
                        book.name = self.currentBook!.name
                        book.author = self.currentBook!.author
                        book.url = self.currentBook!.url
                        book.coverURL = self.currentBook!.coverURL
                book.information = self.currentBook!.information
                book.coverPage = self.currentBook?.coverImage.jpegData(compressionQuality: 0.8)
                        book.pdfData = data
                    if let user = user{
                        book.user = user
                    }
                        do {
                            try context.save()
                            guard sceneDelegate.notificationsEnabled else {
                                print("Notifications disabled")
                                return
                            }
                            
                            let content = UNMutableNotificationContent()
                            
                            content.title = book.name! + " has been downloaded."
                            content.body = "Tap to read"
                            content.categoryIdentifier = sceneDelegate.CATEGORY_IDENTIFIER
                            
                            sceneDelegate.selectedBook = book
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: NOTIFICATION_IDENTIFIER, content: content, trigger: trigger)
                            
                            UNUserNotificationCenter.current().add(request) { error in
                                if let error = error{
                                    print(error)
                                    return
                                }
                                
                                //navigationController?.popViewController(animated: true)
                                //navigationController?.popViewController(animated: true)
                                
                            }

                        }
                        catch{
                            print(error)
                        }
                    
                
                
            }
            
            
            //print the file listing to the console
    
        }
        self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
    
        
    }
    @IBOutlet weak var myCollectionView: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherBooksCell", for: indexPath) as! OtherBooksCollectionViewCell
        cell.imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
        cell.imageView.layer.masksToBounds = true
        cell.imageView.contentMode = .scaleToFill
        cell.imageView.layer.borderWidth = 2
        cell.imageView.image = otherBooksByAuthor[indexPath.row].coverImage
        cell.nameLabel.text = otherBooksByAuthor[indexPath.row].name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: 200)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets1.left
    }
    var coverImage: UIImage?


    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var informationView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var downloadedBooks: [DownloadedBook]?
    var allBooks: [Book] = []
    var otherBooksByAuthor: [Book] = []
    var currentBook: Book?
    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        if let currentBook = currentBook{
            myCollectionView.delegate = self
            myCollectionView.dataSource = self
            imageView?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
            navigationItem.title = currentBook.name
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleToFill
            imageView.layer.borderWidth = 2
            imageView.image = currentBook.coverImage
            nameLabel.text = currentBook.name
            informationView.text = currentBook.information
            authorLabel.text = currentBook.author
            yearLabel.text = currentBook.year
            editionLabel.text = currentBook.edition
            publisherLabel.text = currentBook.publisher
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
            print(downloadedBooks?.count)
            if downloadedBooks?.count ?? 0 > 0{
            for counter in 0...(downloadedBooks?.count ?? 0) - 1 {
                if let downloadedBooks = downloadedBooks{
                    if let user = user
                    {
                        if downloadedBooks[counter].coverURL == currentBook.coverURL && downloadedBooks[counter].user == user
                            {
                            downloadButton.isHidden = true
                            }
                    }
                    else{
                        if downloadedBooks[counter].coverURL == currentBook.coverURL && downloadedBooks[counter].user == nil
                            {
                                downloadButton.isHidden = true
                            }
                    }
                    
                }

            }
                
            }
            
            myCollectionView.reloadData()
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
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
        header.configure()
        return header
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookPDFSegue"
        {
            let destVC = segue.destination as! ShowSelectedBookViewController
            destVC.currentBook = currentBook
        }
        if segue.identifier == "showUpdatedBookSegue"
        {
            let destVC = segue.destination as! ShowBookStudentViewController
            destVC.allBooks = allBooks
            destVC.otherBooksByAuthor = []
            if let selectedRow = myCollectionView.indexPathsForSelectedItems?.first
            {
                destVC.currentBook = otherBooksByAuthor[selectedRow.row]
                for counter in 0...allBooks.count-1
                {
                    if allBooks[counter].author == otherBooksByAuthor[selectedRow.row].author
                    {
                        destVC.otherBooksByAuthor.append(allBooks[counter])
                    }
                }
            
                let oldBookIndex = destVC.otherBooksByAuthor.firstIndex(of: otherBooksByAuthor[selectedRow.row])!
                
                destVC.otherBooksByAuthor.remove(at: oldBookIndex)
            
                
            }
        }
    }
}
