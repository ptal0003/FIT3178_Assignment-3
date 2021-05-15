//
//  SearchBookTableViewCell.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 13/05/21.
//

import UIKit

class SearchBookTableViewCell: UITableViewCell {

    @IBOutlet weak var informationView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var yearLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
