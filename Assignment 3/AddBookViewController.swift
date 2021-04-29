//
//  AddBookViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 25/04/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import UniformTypeIdentifiers
class AddBookViewController: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextView: UITextView!
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    @IBAction func importPDF(_ sender: Any) {
        //Create a picker specifying file type and mode
       
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        documentPicker.delegate = self
           documentPicker.allowsMultipleSelection = false
           documentPicker.modalPresentationStyle = .fullScreen
           present(documentPicker, animated: true, completion: nil)
    }
    @IBAction func saveBook(_ sender: Any) {
        addData(nameTextField.text ?? "", nameTextView.text ?? "")
    }
    lazy var database = {
        return Firestore.firestore()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func addData(_ bookName: String, _ bookInformation: String) {
        let booksRef = database.collection("books")
        let newBook = ["Name": bookName, "Information": bookInformation]
        booksRef.document(bookName).setData(newBook)    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

