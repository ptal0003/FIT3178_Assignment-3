//
//  BooksCollectionViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 14/05/21.
//

import UIKit
import Firebase
//Used
class MyBooksProfessorViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    var displayName: String?
    var credentials: String?
    var coverImages: [UIImage] = []
    var database = {
        return Firestore.firestore()
    }()
    
    func displayMessage(_ title: String,_ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (_) in
                  
                }))
        self.present(alert, animated: true, completion: {
                    
                })
    }
    var allBooks: [Book] = []
    
    var indicator =  UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.hidesBackButton = true
        let addAction = UIAction(title: "Add Book", image: UIImage(systemName: "plus")) { action in
            self.performSegue(withIdentifier: "addBooksSegue", sender: self)
        }
        let searchAction = UIAction(title: "Search", image: UIImage(systemName: "magnifyingglass")) { action in
            self.performSegue(withIdentifier: "searchBookSegue", sender: self)
        }
        let downloadsAction = UIAction(title: "Downloads", image: UIImage(systemName: "square.and.arrow.down")) { action in
            self.performSegue(withIdentifier: "downloadedBooksProfessor", sender: self)
        }
        barButtonItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: .destructive, children: [addAction, searchAction, downloadsAction])
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        collectionView.dataSource = self
        collectionView.delegate = self
        updateData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        
        // Do any additional setup after loading the view.
    }
    func updateData()
    {
        allBooks = []
        if let credentials = credentials{
            database.collection("myCollection/\(credentials)/Books").getDocuments { snapshot, error in
                if let error = error{
                    self.displayMessage("Error",error.localizedDescription + " kindly contact the developer for more information on this.")
                    return
                }
                else
                {
                    for document in snapshot!.documents
                    {
                        let data = document.data()
                        let name = data["Name"] as? String ?? ""
                        let url = data["URL"] as? String ?? ""
                        let information = data["Information"] as? String ?? ""
                        let author = data["author"] as? String ?? ""
                        let coverURL = data["coverURL"] as? String ?? ""
                        let urlCover = URL(string: coverURL)
                        let year = data["year"] as? String ?? ""
                        let publisher = data["publisher"] as? String ?? ""
                        let edition = data["edition"] as? String ?? ""
                        let downloadTask = URLSession.shared.dataTask(with: urlCover!) { data, response, error in
                            if let error = error{
                                print(error)
                            }
                            else if let data = data{
                                let image = UIImage(data: data)
                                let book = Book(bookName: name, information: information, url: url,author: author, coverURL: coverURL, coverImage: image!, year: year, publisher: publisher, edition: edition)
                                self.allBooks.append(book)
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                        downloadTask.resume()
                    }
                }
                
            }
        }
    }
    

     
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let delete = UIAction(title: "Delete from Library", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                self.indicator.startAnimating()
                let userRef = self.database.collection("myCollection")
                userRef.document(self.credentials!).collection("Books").document(self.allBooks[indexPath.row].name).delete{ error in
                    if let error = error{
                        print(error)
                    }
                    else{
                        let bookRef = self.database.collection("books")
                        bookRef.document(self.allBooks[indexPath.row].name).delete { error in
                            if let error = error{
                                print(error)
                            }
                            else{
                                self.indicator.stopAnimating()
                                self.allBooks.remove(at: indexPath.row)
                                self.collectionView.reloadData()
                                print("Successfully Deleted")
                            }
                        }
                        
                    }
                }
                
            }
            return UIMenu(title: "", children: [delete])
        }
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return allBooks.count
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookViewCell", for: indexPath) as! BookCollectionViewCell
        cell.customImageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
        cell.customImageView.layer.masksToBounds = true
        cell.customImageView.contentMode = .scaleToFill
        cell.customImageView.layer.borderWidth = 2
        cell.customImageView.image = allBooks[indexPath.row].coverImage
        cell.nameLabel.text = allBooks[indexPath.row].name
        cell.authorLabel.text = allBooks[indexPath.row].author
        // Configure the cell
        
        return cell
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifyBookSegue"
        {
            let destVC = segue.destination as! AddBookViewController
            destVC.credentials = credentials
            if let selectedRow = self.collectionView.indexPathsForSelectedItems?.first
            {
                destVC.currentBook = allBooks[selectedRow.row]
                destVC.displayName = displayName
                destVC.credentials = credentials
            }
        }
        if segue.identifier == "addBooksSegue"{
            let destVC = segue.destination as! AddBookViewController
            destVC.credentials = credentials
            destVC.displayName = displayName
        }
        if segue.identifier == "searchBookSegue"{
            let destVC = segue.destination as! SearchBooksProfessorTableViewController
            destVC.uploadedBooks = allBooks
            destVC.user = credentials
        }
        if segue.identifier == "downloadedBooksProfessor"{
            let destVC = segue.destination as! ProfessorDownloadsViewController
            destVC.user = credentials
        }
    }
    
}
