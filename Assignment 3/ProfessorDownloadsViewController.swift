//
//  ProfessorDownloadsViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 22/05/21.
//

import UIKit

class ProfessorDownloadsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var myCollectionView: UICollectionView!
    var allDownloads: [DownloadedBook] = []
    var user: String?
    var downloadedBooks: [DownloadedBook] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "downloadCell", for: indexPath) as! DownloadsCollectionViewCell
        
            cell.nameLabel.text = downloadedBooks[indexPath.row].name
            cell.imageView.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
            cell.imageView.layer.masksToBounds = true
            cell.imageView.contentMode = .scaleToFill
            cell.imageView.layer.borderWidth = 2
            cell.imageView.image = UIImage(data: downloadedBooks[indexPath.row].coverPage!)
            cell.yearLabel.text = downloadedBooks[indexPath.row].author
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let delete = UIAction(title: "Delete from Library", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                
                self.downloadedBooks[indexPath.row].managedObjectContext?.delete(self.downloadedBooks[indexPath.row])
                self.downloadedBooks.remove(at: indexPath.row)
                self.myCollectionView.reloadData()
            }
            return UIMenu(title: "", children: [delete])
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showBookSegue", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        
            do
            {
                allDownloads = try context.fetch(DownloadedBook.fetchRequest())
                if allDownloads.count > 0{
                    for counter in 0...allDownloads.count-1
                    {
                        if allDownloads[counter].user == user{
                            downloadedBooks.append(allDownloads[counter])
                        }
                    }
                }
            }
            catch{
                print(error)
            }
        
        
        myCollectionView.reloadData()
        
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
        if segue.identifier == "showBookSegue"
        {
            let destVC = segue.destination as! showBookPDFViewController
            if let selectedRow = myCollectionView.indexPathsForSelectedItems?.first
            {
                destVC.selectedBook = downloadedBooks[selectedRow.row]
            }
            
        }
    }

}
