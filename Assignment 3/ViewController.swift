//
//  ViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 25/04/21.
//

import UIKit
import Firebase
class ViewController: UIViewController {
    var credentials: String?
    var displayName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addBookSegue"
        {
            let destVC = segue.destination as! AddBookViewController
            destVC.credentials = credentials
            destVC.displayName = displayName
        }
        if segue.identifier == "manageBookSegue"
        {
            let destVC = segue.destination as! ManageBooksTableViewController
            destVC.credentials = credentials
            destVC.displayName = displayName
        }
    }

}

