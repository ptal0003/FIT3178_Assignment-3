//
//  BooksCollectionViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 14/05/21.
//

import UIKit
import Firebase
let itemsPerRow: CGFloat = 2
let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)

class MyBooksProfessorViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var displayName: String?
    var credentials: String?
    var coverImages: [UIImage] = []
    var database = {
        return Firestore.firestore()
    }()
 
    var allBooks: [Book] = []
    
        override func viewDidLoad() {
        super.viewDidLoad()
            //navigationItem.hidesBackButton = true
        let storageRef = Storage.storage().reference()
        if let credentials = credentials{
            collectionView.dataSource = self
            collectionView.delegate = self
            database.collection("myCollection/\(credentials)/Books").getDocuments { snapshot, error in
                if let error = error{
                    print(error)
                }
                else{
                    for document in snapshot!.documents
                    {
                            let data = document.data()
                            let name = data["Name"] as? String ?? ""
                            let url = data["URL"] as? String ?? ""
                            let information = data["Information"] as? String ?? ""
                            let author = data["author"] as? String ?? ""
                            let coverURL = data["coverURL"] as? String ?? ""
                            
                        let imageRef = storageRef.child("cover/\(name)Cover")
                        imageRef.getData(maxSize: 1*1024*1024) { data, error in
                            if let error = error{
                                print(error)
                            }
                            else if let data = data{
                                let image = UIImage(data: data)
                                let book = Book(bookName: name, information: information, url: url,author: author, coverURL: coverURL, coverImage: image!)
                                self.allBooks.append(book)
                                self.collectionView.reloadData()

                            }
                        }
                            
                            
                    }
                    
                    
                }
                
            }
           
           
            
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
       
        // Do any additional setup after loading the view.
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            
            return CGSize(width: 140, height: 200)
    }
 */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

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
        cell.imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
        cell.imageView.layer.masksToBounds = true
        cell.imageView.contentMode = .scaleToFill
        cell.imageView.layer.borderWidth = 2
        cell.imageView.image = allBooks[indexPath.row].coverImage
        cell.nameLabel.text = allBooks[indexPath.row].name
        cell.authorLabel.text = allBooks[indexPath.row].author
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifyBookSegue"
        {
            let destVC = segue.destination as! AddBookViewController
            destVC.credentials = credentials
            if let selectedRow = self.collectionView.indexPathsForSelectedItems?.first
            {
                destVC.currentBook = allBooks[selectedRow.row]
            }
        }
        if segue.identifier == "addBooksSegue"{
            let destVC = segue.destination as! AddBookViewController
            destVC.credentials = credentials
            destVC.displayName = displayName
        }
    }

}
