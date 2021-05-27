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
import PDFKit
class AddBookViewController: UIViewController, UIDocumentPickerDelegate {
    @IBAction func saveBook(_ sender: Any) {
        
        if nameTextField.text == ""
        {
            displayMessage("Error", "Name of the book cannot be left blank. Kindly enter a name and save again.")
            return
        }
        if instructionTextView.text == "Click here to add a description" {
            displayMessage("Error", "Description of the book cannot be left blank. Kindly enter a description and save again.")
            return
        }
        if yearTextField.text == ""
        {
            displayMessage("Error", "Year of the book cannot be left blank. Kindly enter the year book was published in and save again.")
            return
        }
        if publisherTextField.text == ""
        {
            displayMessage("Error", "Publisher of the book cannot be left blank. Kindly enter the publisher and save again.")
            return
        }
        if editionTextField.text == ""
        {
            displayMessage("Error", "Edition of the book cannot be left blank. Kindly enter the edition and save again.")
            return
        }
        if let name = nameTextField.text, let information = instructionTextView.text, let year = yearTextField.text, let publisher = publisherTextField.text, let edition = editionTextField.text
        {
            addData(name, information,year,publisher,edition)
        }
        
    }
    @IBOutlet weak var yearTextField: UITextField!
    
    @IBOutlet weak var publisherTextField: UITextField!
    
    @IBOutlet weak var editionTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var credentials: String?
    var displayName: String?
    var selectedURL: URL?
    var currentBook: Book?
    let storage = Storage.storage()
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var instructionTextView: UITextView!
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        selectedURL = urls.first
        if let selectedURL = urls.first{
            
            let tempDirPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            let tempDir = tempDirPaths[0]
            let localURL = tempDir.appendingPathComponent(selectedURL.lastPathComponent)
            
            if selectedURL.startAccessingSecurityScopedResource(){
                try? FileManager.default.copyItem(at: selectedURL, to: localURL)
            }
            self.selectedURL?.stopAccessingSecurityScopedResource()
            self.imageView.image =  PDFDocument(url: localURL)?.page(at: 0)?.thumbnail(of: CGSize(width: 1024, height: 1024), for: .mediaBox)
            
            
        }
        
    }
    func displayMessage(_ title: String,_ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (_) in
            
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
    func displaySuccessMessage(_ title: String,_ message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: {
            
        })
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
    
    lazy var database = {
        return Firestore.firestore()
    }()
    var indicator = UIActivityIndicatorView()
    override func viewDidLoad() {

        super.viewDidLoad()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        
        imageView.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 2
        navigationItem.title = "Add a Book"
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if let currentBook = currentBook {
            nameTextField.text = currentBook.name
            instructionTextView.text = currentBook.information
            navigationItem.title = currentBook.name
            imageView.image = currentBook.coverImage
            yearTextField.text = currentBook.year
            publisherTextField.text = currentBook.publisher
            editionTextField.text = currentBook.edition
            
        }
        // Do any additional setup after loading the view.
    }
    
    func addData(_ bookName: String, _ bookInformation: String, _ year: String, _ publisher: String, _ edition: String) {
        let userRef = database.collection("myCollection")
        let bookRef = database.collection("books")
        
        guard let credentials = credentials else {
            print("Credentials not set")
            return
        }
        
        if let currentBook = currentBook {
            
            if let selectedURL = selectedURL {
                let tempDirPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                let tempDir = tempDirPaths[0]
                let localURL = tempDir.appendingPathComponent(selectedURL.lastPathComponent)
                
                if selectedURL.startAccessingSecurityScopedResource(){
                    try? FileManager.default.copyItem(at: selectedURL, to: localURL)
                }
                self.selectedURL?.stopAccessingSecurityScopedResource()
                let coverStorageRef = storage.reference(withPath: "/cover/\(currentBook.name)Cover")
                let bookStorageRef = storage.reference(withPath: "/books/\(selectedURL.lastPathComponent)")
                
                
                bookStorageRef.putFile(from: localURL, metadata: nil) { metadata, error in
                    if let error = error{
                        print(error)
                    }
                    else
                    {
                        bookStorageRef.downloadURL { url, error in
                            if let error = error {
                                print("Could not get downloadable link \(error)")
                            }
                            else{
                                let myMetaData = StorageMetadata()
                                myMetaData.contentType = "images/jpeg"
                                coverStorageRef.putData((self.imageView.image?.jpegData(compressionQuality: 0.5))!, metadata: myMetaData) { metadata, error in
                                    if let error = error{
                                        print(error)
                                    }
                                    else{
                                        coverStorageRef.downloadURL { coverURLFirebase, error in
                                            if let error = error{
                                                print(error)
                                            }
                                            else{
                                                let downloadURL = url?.absoluteString
                                                
                                                let newBook = ["Name": bookName, "Information": bookInformation, "URL": downloadURL, "author": self.displayName,"coverURL": coverURLFirebase?.absoluteString,"year":year, "publisher": publisher, "edition": edition]
                                                bookRef.document(currentBook.name).updateData(newBook)
                                                userRef.document(credentials).collection("Books").document(currentBook.name).updateData(newBook)
                                                let VC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? MyBooksProfessorViewController
                                                VC?.updateData()
                                                
                                                self.displaySuccessMessage("Success", "Your book has been updated Successfully. You can access it in the uploads section")
                                            }
                                        }
                                    }
                                }
                                
                                
                                
                            }
                        }
                        
                        self.indicator.stopAnimating()
                        
                    }
                }
                
            }
            else {
                let newBook = ["Name": bookName, "Information": bookInformation, "URL": currentBook.url, "author": self.displayName, "coverURL": currentBook.coverURL,"year":year, "publisher": publisher, "edition": edition]
                bookRef.document(currentBook.name).delete()
                
                bookRef.document(newBook["Name"]!!).setData(newBook)
                userRef.document(credentials).collection("Books").document(currentBook.name).delete()
                userRef.document(credentials).collection("Books").document(newBook["Name"]!!).setData(newBook)
                
                indicator.stopAnimating()
                let VC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? MyBooksProfessorViewController
                VC?.updateData()
                
                self.displaySuccessMessage("Success", "Your book has been updated Successfully. You can access it in the uploads section")
                
            }
        }
        else
        {
            
            if let selectedURL = selectedURL
            {
                indicator.startAnimating()
                let tempDirPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
                let tempDir = tempDirPaths[0]
                let localURL = tempDir.appendingPathComponent(selectedURL.lastPathComponent)
                
                selectedURL.startAccessingSecurityScopedResource()
                try? FileManager.default.copyItem(at: selectedURL, to: localURL)
                self.selectedURL?.stopAccessingSecurityScopedResource()
                let storageRef = storage.reference(withPath: "/books/\(selectedURL.lastPathComponent)")
                let fileRef = storageRef.child(selectedURL.lastPathComponent)
                let coverStorageRef = storage.reference(withPath: "/cover/\(bookName)Cover")
                storageRef.putFile(from: localURL, metadata: nil) { metadata, error in
                    if let error = error{
                        print(error)
                    }
                    else
                    {
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                print("Could not get downloadable link \(error)")
                            }
                            else{
                                let downloadURL = url?.absoluteString
                                
                                let metadata = StorageMetadata()
                                metadata.contentType = "image/jpeg"
                                coverStorageRef.putData((self.imageView.image?.jpegData(compressionQuality: 0.5))!, metadata: metadata){metadata,error in
                                    if let error = error{
                                        print(error)
                                    }
                                    else
                                    {
                                        self.indicator.stopAnimating()
                                        coverStorageRef.downloadURL { url, error in
                                            let newBook = ["Name": bookName, "Information": bookInformation, "URL": downloadURL, "author": self.displayName, "coverURL": url?.absoluteString,"year":year, "publisher": publisher, "edition": edition]
                                            self.database.collection("books").document(bookName).setData(newBook)
                                            userRef.document(credentials).collection("Books").document(bookName).setData(newBook)
                                            let VC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? MyBooksProfessorViewController
                                            VC?.updateData()
                                            self.displaySuccessMessage("Success", "Your book has been uploaded succesfully, you can find it with the other uploaded books.")
                                            
                                            
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                        
                    }
                }
                
            }
            else{
                displayMessage("Error", "You must select a PDF file to upload with the book. Click the button below to add a file.")
                return
            }
            
            
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
}

