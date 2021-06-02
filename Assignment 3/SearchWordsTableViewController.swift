//
//  SearchWordsTableViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 20/05/21.
//

import UIKit
import PDFKit
class SearchWordsTableViewController: UITableViewController, UISearchResultsUpdating {
   
    @IBOutlet var myTableView: UITableView!
    var delegate: PDFFunctionalityDelegate?
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
           }
        matchingSelections = (currentPDFDoc?.findString(searchText, withOptions: .caseInsensitive))
        myTableView.reloadData()
        
    }
    let searchController = UISearchController(searchResultsController: nil)
    var currentPDFDoc: PDFDocument?
    var matchingSelections: [PDFSelection]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search the Document"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            
            if let matchingSelections = matchingSelections{
                return matchingSelections.count
            }
            
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
        if indexPath.section == 0{
            if let matchingSelections = matchingSelections{
                cell.textLabel!.text = "Page " + matchingSelections[indexPath.row].pages[0].label!
                let matchContext = matchingSelections[indexPath.row].copy() as! PDFSelection
                matchContext.extendForLineBoundaries()
                
                cell.detailTextLabel?.text = matchContext.string
            }
        }
        // Configure the cell...
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        if indexPath.section == 1{
            if let matchingSelections = matchingSelections{
                cell1.textLabel?.text = "\(matchingSelections.count) occurrences found"
            }
            else{
                cell1.textLabel?.text = "Word not found in document"
            }
            return cell1
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let matchingSelections = matchingSelections{
            delegate?.sendPDFSelect(matchingSelections[indexPath.row])
            navigationController?.popViewController(animated: true)
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
