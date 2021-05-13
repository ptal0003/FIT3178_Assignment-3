//
//  ShowBookStudentViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 13/05/21.
//

import UIKit

class ShowBookStudentViewController: UIViewController {
    var coverImage: UIImage?
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var informationView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var currentBook: Book?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentBook = currentBook, let coverImage = coverImage{
            imageView?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleToFill
            imageView.layer.borderWidth = 2
            imageView.image = coverImage
            nameLabel.text = currentBook.name
            informationView.text = currentBook.information
            authorLabel.text = currentBook.author
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
