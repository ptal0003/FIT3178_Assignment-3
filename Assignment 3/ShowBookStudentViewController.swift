//
//  ShowBookStudentViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 13/05/21.
//

import UIKit
let sectionInsets1 = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
class ShowBookStudentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return otherBooksByAuthor.count
    }
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherBooksCell", for: indexPath) as! OtherBooksCollectionViewCell
        cell.imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
        cell.imageView.layer.masksToBounds = true
        cell.imageView.contentMode = .scaleToFill
        cell.imageView.layer.borderWidth = 2
        cell.imageView.image = otherBookCovers[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: widthPerItem)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets1.left
    }
    var coverImage: UIImage?

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var informationView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var allBooks: [Book] = []
    var allCovers: [UIImage] = []
    var otherBooksByAuthor: [Book] = []
    var otherBookCovers: [UIImage] = []
    var currentBook: Book?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentBook = currentBook, let coverImage = coverImage{
            myCollectionView.delegate = self
            myCollectionView.dataSource = self
            imageView?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleToFill
            imageView.layer.borderWidth = 2
            imageView.image = coverImage
            nameLabel.text = currentBook.name
            informationView.text = currentBook.information
            authorLabel.text = currentBook.author
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
            destVC.allCovers = allCovers
            destVC.otherBookCovers = []
            destVC.otherBooksByAuthor = []
            if let selectedRow = myCollectionView.indexPathsForSelectedItems?.first
            {
                destVC.coverImage = otherBookCovers[selectedRow.row]
                destVC.currentBook = otherBooksByAuthor[selectedRow.row]
                for counter in 0...allBooks.count-1
                {
                    if allBooks[counter].author == otherBooksByAuthor[selectedRow.row].author
                    {
                        destVC.otherBooksByAuthor.append(allBooks[counter])
                        destVC.otherBookCovers.append(allCovers[counter])
                    }
                }
            
                let oldBookIndex = destVC.otherBooksByAuthor.firstIndex(of: otherBooksByAuthor[selectedRow.row])!
                
                destVC.otherBooksByAuthor.remove(at: oldBookIndex)
                destVC.otherBookCovers.remove(at: oldBookIndex)
            
                
            }
        }
    }
}
