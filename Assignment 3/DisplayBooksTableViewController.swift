//
//  DisplayBooksTableViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 07/05/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class DisplayBooksTableViewController: UITableViewController, UISearchResultsUpdating {
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
    var filteredBooks: [Book] = []
    var database = {
        return Firestore.firestore()
    }()
    var allBooks: [Book] = []
    @IBOutlet var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    let book = Book(bookName: name, information: information, url: url,author: author)
                    self.allBooks.append(book)
                    
                }
                
                self.filteredBooks = self.allBooks
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredBooks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        cell.textLabel?.text = filteredBooks[indexPath.row].name
        cell.detailTextLabel?.text = filteredBooks[indexPath.row].information
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectedBookSegue"
        {
            let destVC = segue.destination as! ShowSelectedBookViewController
            destVC.currentBook = allBooks[myTableView.indexPathForSelectedRow!.row]
            destVC.navigationItem.title = allBooks[myTableView.indexPathForSelectedRow!.row].name
        }
        
    }

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
