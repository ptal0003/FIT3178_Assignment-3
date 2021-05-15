//
//  DownloadBooksTableViewCell.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 15/05/21.
//

import UIKit

class DownloadBooksTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var informationView: UITextView!
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var yearLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
