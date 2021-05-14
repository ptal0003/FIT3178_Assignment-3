//
//  LoginViewController.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 29/04/21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
class LoginViewController: UIViewController, LoginButtonDelegate {
    var loggedCredential: String?
    var displayName: String?
    var database = {
        return Firestore.firestore()
    }()
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
          }
        let facebookToken = AccessToken.current!.tokenString
        let credential = FacebookAuthProvider.credential(withAccessToken: facebookToken)
        let userRef = database.collection("myCollection")
        Auth.auth().signIn(with: credential) { (result, error) in
          if let error = error {
            print("Firebase auth fails with error: \(error.localizedDescription)")
          } else if let result = result {
            print("Firebase login succeeds")
            
            self.loggedCredential = result.user.uid
            self.displayName = result.user.displayName
            userRef.document(self.loggedCredential!).setData(["type":"student"])
            DispatchQueue.main.async {
            
                self.performSegue(withIdentifier: "booksByMeSegue", sender: nil)
               
            }
          }
        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "home_bg")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        loginButton.layoutMargins.left = 0
        loginButton.layoutMargins.right = 0
        loginButton.layoutMargins.bottom = 0
        loginButton.center = view.center
        loginButton.sizeToFit()
        view.addSubview(loginButton)
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
        if segue.identifier == "booksByMeSegue"
        {
            let destVC = segue.destination as! BooksCollectionViewController
            destVC.credentials = loggedCredential
            destVC.displayName = displayName
        }
    }
}
