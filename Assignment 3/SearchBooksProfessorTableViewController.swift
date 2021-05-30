//
//  SearchBooksProfessorTableViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 22/05/21.
//

import UIKit
import Firebase
class SearchBooksProfessorTableViewController: UITableViewController, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
           }
        if searchController.searchBar.selectedScopeButtonIndex == 2{
            allBooks = uploadedBooks ?? []
        }
        else if searchController.searchBar.selectedScopeButtonIndex == 1
        {
            if searchText.count > 0{
                indicator.startAnimating()
                newBooks = []
                requestBooksNamed(searchText)
            }
        }
        if searchText.count > 0 {
            filteredBooks = allBooks.filter({(book: Book) -> Bool in return (book.name.lowercased().contains(searchText)) || (book.information.lowercased().contains(searchText)) ||
                (book.author.lowercased().contains(searchText))
            })
            myTableView.reloadData()
        }
    }
    func requestBooksNamed(_ bookName: String){
        guard let queryString = bookName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Query string can't be encoded.")
        return
        }
        guard let requestURL = URL(string: REQUEST_STRING + queryString) else { print("Invalid URL.")
        return
        }
        let task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            // This closure is executed on a different thread at a later point in
        // time!
            DispatchQueue.main.async { self.indicator.stopAnimating()
            }
            if let error = error { print(error)
            return
            }
            do {
            let decoder = JSONDecoder()
            let volumeData = try decoder.decode(VolumeData.self, from: data!)
            if let books = volumeData.books {
                self.newBooks.append(contentsOf: books)
            }
                DispatchQueue.main.async {
                    self.myTableView.reloadData()
                }
            } catch let err {
            print(err) }
        }
        task.resume()
    }
    var user: String?
    var newBooks = [BookData]()
    var indicator = UIActivityIndicatorView()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredBooks: [Book] = []
    var allBooks: [Book] = []
    var uploadedBooks: [Book]?
    var downloadedBooks: [DownloadedBook]?
    var myBooks: [Book]?
    var database = {
        return Firestore.firestore()
    }()
 
    @IBOutlet var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Books"
        searchController.searchBar.scopeButtonTitles = ["University","Google Books","Uploads"]
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        
        
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
                    let myURL = URL(string: coverURL)
                    let year = data["year"] as? String ?? ""
                    let publisher = data["publisher"] as? String ?? ""
                    let edition = data["edition"] as? String ?? ""
                    let downloadTask = URLSession.shared.dataTask(with: myURL!) { data, response, error in
                        if let error = error{
                            print(error)
                            return
                        }
                        if let data = data{
                            let image = UIImage(data: data)
                            let book = Book(bookName: name, information: information, url: url,author: author, coverURL: coverURL, coverImage: image!,year: year, publisher: publisher, edition: edition)
                            self.allBooks.append(book)
                            DispatchQueue.main.async {
                                self.myTableView.reloadData()
                            }
                        }
                    }
                    downloadTask.resume()
                    
                    
                }
                

                

                
            }
        // Do any additional setup after loading the view.
    }
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.searchBar.selectedScopeButtonIndex != 1{
            self.performSegue(withIdentifier: "showBookDetails", sender: self)
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.searchBar.selectedScopeButtonIndex == 0 || searchController.searchBar.selectedScopeButtonIndex == 2{
            
            return filteredBooks.count
        }
        
        return newBooks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! SearchBookTableViewCell
        if searchController.searchBar.selectedScopeButtonIndex == 1{
            cell.nameLabel.text = newBooks[indexPath.row].title
            cell.authorLabel.text = newBooks[indexPath.row].authors
            cell.yearLabel.text = newBooks[indexPath.row].publicationDate
            //cell.customImageView.image = UIImage(named: "defaultBookImage")
            cell.informationView.text = newBooks[indexPath.row].bookDescription
            if var imageURL = newBooks[indexPath.row].imageURL
            {
                imageURL = imageURL.replacingOccurrences(of: "http:", with: "https:")
                let url = URL(string: imageURL)!
                
                let downloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error{
                        print(error)
                    }
                    if let response = response
                    {
                        print(response)
                    }
                    if let data = data{
                        DispatchQueue.main.async {
                            cell.customImageView.image = UIImage(data: data)
                        }
                    }
                }
                downloadTask.resume()
            }
            return cell
            }
        
        else if searchController.searchBar.selectedScopeButtonIndex == 0 || searchController.searchBar.selectedScopeButtonIndex == 2
        {
        cell.nameLabel.text = filteredBooks[indexPath.row].name
        cell.authorLabel.text = filteredBooks[indexPath.row].author
        cell.yearLabel.text = filteredBooks[indexPath.row].year
        
        cell.informationView.text = filteredBooks[indexPath.row].information
        cell.customImageView.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        cell.customImageView.layer.masksToBounds = true
        cell.customImageView.contentMode = .scaleToFill
        cell.customImageView.layer.borderWidth = 2
        cell.customImageView.image = filteredBooks[indexPath.row].coverImage
            
        }
        
            
        
        // Configure the cell...

        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookDetails"
        {
            
            let destVC = segue.destination as! ShowBookStudentViewController
            if let selectedRow = myTableView.indexPathForSelectedRow?.row
            {
                
                destVC.otherBooksByAuthor = []
                destVC.allBooks = allBooks
                destVC.currentBook = filteredBooks[selectedRow]
                for counter in 0...allBooks.count-1
                {
                    if allBooks[counter].author == filteredBooks[selectedRow].author
                    {
                        destVC.otherBooksByAuthor.append(allBooks[counter])
                       
                    }
                }
                
                destVC.otherBooksByAuthor.remove(at: destVC.otherBooksByAuthor.firstIndex(of:destVC.currentBook!)!)
                destVC.user = user
                
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
