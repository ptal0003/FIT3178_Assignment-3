//
//  SceneDelegate.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 25/04/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    var user: String?
    var window: UIWindow?
    var selectedBook: DownloadedBook?
    let CATEGORY_IDENTIFIER = "edu.monash.fit3178.Workshop10.democategory"
    var notificationsEnabled = false
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            if granted {
                self.notificationsEnabled = granted
                UNUserNotificationCenter.current().delegate = self
                
                
                let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept", options: .foreground)
                let declineAction = UNNotificationAction(identifier: "decline", title: "Decline", options: .destructive)
                let commentAction = UNTextInputNotificationAction(identifier: "comment", title: "Comment", options: .authenticationRequired, textInputButtonTitle: "Send", textInputPlaceholder: "Share your thoughts..")
                
                // Set up the category
                let appCategory = UNNotificationCategory(identifier: self.CATEGORY_IDENTIFIER, actions: [acceptAction, declineAction, commentAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
                
                // Register the category just created with the notification centre
                UNUserNotificationCenter.current().setNotificationCategories([appCategory])
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        let navigationController = self.window?.rootViewController as? UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "ViewPDF") as! showBookPDFViewController
            
        if let selectedBook = self.selectedBook{
            VC.selectedBook = selectedBook
            
        }
        
        navigationController?.pushViewController(VC, animated: true)
        
        completionHandler()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    //Gets called when the notification is presented, it's called as soon as the notification is displayed
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification arrived")
        
        let navigationController = self.window?.rootViewController as? UINavigationController
        if let savedBooksViewController = navigationController?.viewControllers[1] as? DownloadsViewController
        {
            savedBooksViewController.updateMyData()
        }
        
        completionHandler(.alert)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

