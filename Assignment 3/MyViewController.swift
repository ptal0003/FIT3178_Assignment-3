//
//  MyViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 13/05/21.
//

import UIKit
import Firebase

class MyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var filteredBooks: [Book] = []
    var allBooks: [Book] = []
    var images: [UIImage] = []

    var database = {
        return Firestore.firestore()
    }()
    
   
    @IBOutlet weak var myTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
           }
        if searchText.count > 0 {
            filteredBooks = allBooks.filter({(book: Book) -> Bool in return (book.name.lowercased().contains(searchText)) || (book.information.lowercased().contains(searchText)) ||
                (book.author.lowercased().contains(searchText))
            })
            myTableView.reloadData()
        }
       
        
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! SearchBookTableViewCell
        let image = UIImage(named: "icloud.and.arrow.down")
        let imageView = UIImageView(image: image)
        cell.accessoryView = imageView
        cell.nameLabel.text = allBooks[indexPath.row].name
        cell.authorLabel.text = allBooks[indexPath.row].author
        cell.informationView.text = allBooks[indexPath.row].information
        cell.imageView?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.layer.borderWidth = 2
        cell.imageView?.image = images[indexPath.row]
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // This view controller decides how the search controller is presented
        database.collection("books").getDocuments { querySnapshot, error in
            if let error = error{
                print(error)
            }
            
            else if let querySnapshot = querySnapshot{
                print(querySnapshot.documents)
                for document in querySnapshot.documents{
                    let data = document.data()
                    let name = data["Name"] as? String ?? ""
                    let url = data["URL"] as? String ?? ""
                    let information = data["Information"] as? String ?? ""
                    let author = data["author"] as? String ?? ""
                    let coverURL = data["coverURL"] as? String ?? ""
                    let book = Book(bookName: name, information: information, url: url,author: author, coverURL: coverURL)
                                        
                    let imageRef = storageRef.child("cover/\(name)Cover")
                    imageRef.getData(maxSize: 1*1024*1024) { data, error in
                        if let error = error{
                            print(error)
                        }
                        else if let data = data{
                            let image = UIImage(data: data)
                            self.images.append(image!)
                            self.allBooks.append(book)
                            self.myTableView.reloadData()
                        }
                    }
                    
                }
                

                

                
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

}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStudentBookSegue"
        {
            
            let destVC = segue.destination as! ShowBookStudentViewController
            if let selectedRow = myTableView.indexPathForSelectedRow?.row
            {
                destVC.otherBookCovers = []
                destVC.otherBooksByAuthor = []
                destVC.allBooks = allBooks
                destVC.allCovers = images
                destVC.coverImage = images[selectedRow]
                destVC.currentBook = allBooks[selectedRow]
                for counter in 0...allBooks.count-1
                {
                    if allBooks[counter].author == allBooks[selectedRow].author
                    {
                        destVC.otherBooksByAuthor.append(allBooks[counter])
                        destVC.otherBookCovers.append(images[counter])
                    }
                }
                destVC.otherBooksByAuthor.remove(at: allBooks.firstIndex(of: allBooks[selectedRow])!)
                destVC.otherBookCovers.remove(at: allBooks.firstIndex(of: allBooks[selectedRow])!)
            }
            
        }
    }
}
