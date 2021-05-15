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
            
            selectedURL.startAccessingSecurityScopedResource()
            try? FileManager.default.copyItem(at: selectedURL, to: localURL)
            self.selectedURL?.stopAccessingSecurityScopedResource()
            self.imageView.image =  PDFDocument(url: localURL)?.page(at: 0)?.thumbnail(of: CGSize(width: 1024, height: 1024), for: .mediaBox)
            

        }
        
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
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            let imageRef = storageRef.child("cover/\(currentBook.name)Cover")
            imageRef.getData(maxSize: 1024*1024) { data, error in
                if let error = error{
                    print(error)
                }
                else if let data = data{
                    self.imageView.image = UIImage(data: data)
                }
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    func addData(_ bookName: String, _ bookInformation: String) {
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
                
                selectedURL.startAccessingSecurityScopedResource()
                try? FileManager.default.copyItem(at: selectedURL, to: localURL)
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
                                                
                                                let newBook = ["Name": bookName, "Information": bookInformation, "URL": downloadURL, "author": self.displayName,"coverURL": coverURLFirebase?.absoluteString]
                                                bookRef.document(currentBook.name).updateData(newBook)
                                                userRef.document(credentials).collection("Books").document(currentBook.name).updateData(newBook)
                                            }
                                        }
                                    }
                                }
                                
                               
                                
                            }
                        }
                        
                        
                        print("Successfully Uploaded")
                    }
                }

            }
            else {
                let newBook = ["Name": bookName, "Information": bookInformation, "URL": currentBook.url, "author": self.displayName, "coverURL": currentBook.coverURL]
                bookRef.document(currentBook.name).delete()
                bookRef.document(newBook["Name"]!!).setData(newBook)
                userRef.document(credentials).collection("Books").document(currentBook.name).delete()
                userRef.document(credentials).collection("Books").document(currentBook.name).setData(newBook)
                
            }
        }
        else
        {
            
            if let selectedURL = selectedURL {
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
                                        coverStorageRef.downloadURL { url, error in
                                            let newBook = ["Name": bookName, "Information": bookInformation, "URL": downloadURL, "author": self.displayName, "coverURL": url?.absoluteString]
                                            self.database.collection("books").document(bookName).setData(newBook)
                                            userRef.document(credentials).collection("Books").document(bookName).setData(newBook)
                                            let alert = UIAlertController(title: "Success", message: "Your book has been uploaded successfully.", preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (_) in
                                                        self.navigationController?.popViewController(animated: true)
                                                    }))
                                            self.present(alert, animated: true, completion: {
                                                        print("completion block")
                                                    })
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                        
                    }
                }

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

}

