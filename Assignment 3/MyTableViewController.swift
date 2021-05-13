//
//  MyTableViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 13/05/21.
//

import UIKit
import Firebase
class MyTableViewController: UITableViewController, UISearchResultsUpdating {
    var filteredBooks: [Book] = []
    var allBooks: [Book] = []
    var database = {
        return Firestore.firestore()
    }()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
           }
        if searchText.count > 0 {
            filteredBooks = allBooks.filter({(book: Book) -> Bool in return (book.name.lowercased().contains(searchText)) || (book.information.lowercased().contains(searchText)) ||
                (book.author.lowercased().contains(searchText))
            })
            tableView.reloadData()
        }
       
        
        
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! SearchBookTableViewCell
        cell.nameLabel.text = "Harry Potter"
        cell.authorLabel.text = "Prateek Talukdar"
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Books"
        navigationItem.searchController = searchController
       
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
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
                    self.allBooks.append(book)
                    
                }
                
                self.filteredBooks = self.allBooks
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
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
