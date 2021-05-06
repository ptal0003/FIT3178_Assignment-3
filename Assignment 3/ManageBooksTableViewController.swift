//
//  ManageBooksTableViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 03/05/21.
//

import UIKit
import FirebaseFirestore

struct ShowData: Codable{
    var name: String
    var URL: String
    var information: String
}
class ManageBooksTableViewController: UITableViewController {
    @IBOutlet var myTableView: UITableView!
    var credentials: String?
    var database = {
        return Firestore.firestore()
    }()
    var allBooks: [Book] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let credentials = credentials{
            print(credentials)
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
                            let book = Book(bookName: name, information: information, url: url)
                            self.allBooks.append(book)
                        
                    }
                    self.myTableView.reloadData()
                }
                
            }
           
           
            
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        let userRef = database.collection("myCollection")
        userRef.document(credentials!).collection("Books").document(allBooks[indexPath.row].name).delete
     { error in
                if let error = error{
                    print(error)
                }
                else{
                    self.allBooks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()
                    print("Successfully Deleted")
                }
            }
            
        }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        return false
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0
        {
        return allBooks.count
        }
        else
        {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Books"
        }
        else
        {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        cell.textLabel?.text = allBooks[indexPath.row].name
            cell.detailTextLabel?.text = allBooks[indexPath.row].information
        // Configure the cell...

        return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "numCell", for: indexPath)
            cell.textLabel?.text = "You have written " + String(allBooks.count) + "books"
            // Configure the cell...
            return cell
          
        }
      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifyBookSegue"
        {
            let destVC = segue.destination as! AddBookViewController
            destVC.credentials = credentials
            if let selectedRow = myTableView.indexPathForSelectedRow?.row
            {
                destVC.currentBook = allBooks[selectedRow]
            }
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
