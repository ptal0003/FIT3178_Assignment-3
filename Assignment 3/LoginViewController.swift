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
extension LoginViewController {
    
    private func updateButton(isLoggedIn: Bool) {
        // 1
        let title = isLoggedIn ? "Log Out" : "Continue as a Professor"
        loginButton.setTitle(title, for: .normal)
    }
    
    }

class LoginViewController: UIViewController, LoginButtonDelegate {
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func logMeIn(_ sender: Any) {
        let loginManager = LoginManager()
            
            if let _ = AccessToken.current {
                // Access token available -- user already logged in
                // Perform log out
                
                // 2
                loginManager.logOut()
                updateButton(isLoggedIn: false)

            }
            else {
                    // Access token not available -- user already logged out
                    // Perform log in
                    
                    // 3
                    loginManager.logIn(permissions: [], from: self) { [weak self] (result, error) in
                        
                        // 4
                        // Check for error
                        guard error == nil else {
                            // Error occurred
                            print(error!.localizedDescription)
                            return
                        }
                        
                        // 5
                        // Check for cancel
                        guard let result = result, !result.isCancelled else {
                            print("User cancelled login")
                            return
                        }
                      
                        // Successfully logged in
                        // 6
                        self?.updateButton(isLoggedIn: true)
                        
                        // 7
                        Profile.loadCurrentProfile { (profile, error) in
                            let facebookToken = AccessToken.current!.tokenString
                            let credential = FacebookAuthProvider.credential(withAccessToken: facebookToken)
                            let userRef = self!.database.collection("myCollection")
                            Auth.auth().signIn(with: credential) { (result, error) in
                              if let error = error {
                                print("Firebase auth fails with error: \(error.localizedDescription)")
                              } else if let result = result {
                                print("Firebase login succeeds")
                                
                                self!.loggedCredential = result.user.uid
                                self!.displayName = result.user.displayName
                                userRef.document(self!.loggedCredential!).setData(["type":"student"])
                                DispatchQueue.main.async {
                                
                                    self!.performSegue(withIdentifier: "booksByMeSegue", sender: nil)
                                   
                                }
                              }
                            }
                        }
                    
                    }
                }
            
        
        
    }
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
        updateButton(isLoggedIn: (AccessToken.current != nil))
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
            let destVC = segue.destination as! MyBooksProfessorViewController
            destVC.credentials = loggedCredential
            destVC.displayName = displayName
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
