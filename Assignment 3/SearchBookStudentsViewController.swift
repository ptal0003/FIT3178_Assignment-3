//
//  MyViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 13/05/21.
//

import UIKit
import Firebase
let CELL_BOOK = "bookCell"
let REQUEST_STRING = "https://www.googleapis.com/books/v1/volumes?q="
class SearchBookStudentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating{
    var filteredBooks: [Book] = []
    var newBooks = [BookData]()
    var allBooks: [Book] = []
    var downloadedBooks: [DownloadedBook]?
    var database = {
        return Firestore.firestore()
    }()
    let searchController = UISearchController(searchResultsController: nil)
    var indicator = UIActivityIndicatorView()
   
    @IBOutlet weak var myTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.selectedScopeButtonIndex == 1{
            return newBooks.count
        }
        return filteredBooks.count
        
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
    @objc(updateSearchResultsForSearchController:) func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
           }
        if searchController.searchBar.selectedScopeButtonIndex == 0
        {
            if searchText.count > 0 {
                filteredBooks = allBooks.filter({(book: Book) -> Bool in return (book.name.lowercased().contains(searchText)) || (book.information.lowercased().contains(searchText)) ||
                    (book.author.lowercased().contains(searchText))
                })
                myTableView.reloadData()
            }
            
        }
        else if searchController.searchBar.selectedScopeButtonIndex == 1{
            newBooks.removeAll()
            filteredBooks.removeAll()
            myTableView.reloadData()
            guard let searchText = searchController.searchBar.text?.lowercased() else {
                return
               }
            indicator.startAnimating()
            requestBooksNamed(searchText)
            
        }
        else if searchController.searchBar.selectedScopeButtonIndex == 2{

            if searchText.count > 0 {
                var allBooksCopy: [Book] = []
                if let downloadedBooks = downloadedBooks{
                    for downloadedBook in downloadedBooks{
                        let newBook = Book(bookName: downloadedBook.name!, information: downloadedBook.information!, url: downloadedBook.url!, author: downloadedBook.author!, coverURL: downloadedBook.coverURL!, coverImage: UIImage(data: downloadedBook.coverPage!)!, year: downloadedBook.year ?? "", publisher: downloadedBook.publisher ?? "", edition: downloadedBook.edition ?? "")
                        allBooksCopy.append(newBook)
                    }
                }
                 filteredBooks = allBooksCopy.filter({(book: Book) -> Bool in return (book.name.lowercased().contains(searchText)) || (book.information.lowercased().contains(searchText)) ||
                    (book.author.lowercased().contains(searchText))

                })
                myTableView.reloadData()
            }
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            self.performSegue(withIdentifier: "alpha", sender: self)
        }
        if searchController.searchBar.selectedScopeButtonIndex == 2 {
            self.performSegue(withIdentifier: "showBookPDF", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! SearchBookTableViewCell
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
           
        
        cell.nameLabel.text = filteredBooks[indexPath.row].name
        cell.authorLabel.text = filteredBooks[indexPath.row].author
        cell.yearLabel.text = filteredBooks[indexPath.row].year
        cell.informationView.text = filteredBooks[indexPath.row].information
        cell.customImageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
        cell.customImageView.layer.masksToBounds = true
        cell.customImageView.contentMode = .scaleToFill
        cell.customImageView.layer.borderWidth = 2
        cell.customImageView.image = filteredBooks[indexPath.row].coverImage
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Books"
        searchController.searchBar.scopeButtonTitles = ["University","Google Books","Downloaded"]
        navigationItem.searchController = searchController
       
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
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
                            let book = Book(bookName: name, information: information, url: url,author: author, coverURL: coverURL, coverImage: image!, year: year, publisher: publisher, edition: edition)
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
        if segue.identifier == "alpha"
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
                
                destVC.otherBooksByAuthor.remove(at: destVC.otherBooksByAuthor.firstIndex(of: destVC.currentBook!)!)
                
                destVC.otherBooksOfInterest = []
                for counter in 0...allBooks.count-1
                {
                    if allBooks[counter].author != filteredBooks[selectedRow].author
                    {
                        destVC.otherBooksOfInterest.append(allBooks[counter])
                       
                    }
                }
                
                
            }
            
            
        }
        if segue.identifier == "showBookPDF"
        {
            let destVC = segue.destination as! showBookPDFViewController
            if let selectedRow = myTableView.indexPathForSelectedRow?.row
            {
                destVC.selectedBook = downloadedBooks![selectedRow]
            }
        }
    }
}
