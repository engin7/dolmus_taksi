//
//  AppDelegate.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UIWindowSceneDelegate {
    
    var window:UIWindow? // ios13 moved window to sceneDelegate

    override init() {
      FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Use Firebase library to configure APIs
 
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        Database.database().isPersistenceEnabled = true
        
         return true
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
      -> Bool {
        // handle the URL that your application receives at the end of the authentication process.
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    // to run on iOS 8 and older, also implement the deprecated method
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
  
    // MARK: GIDSignInDelegate (handle sign-in process)
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
      if let error = error {
        print(error)
        print("can not sign in with Google")
        return
      }
        print("Successfully logged into Google", user!)

      guard let authentication = user.authentication else { return }
      let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                        accessToken: authentication.accessToken)
       Auth.auth().signIn(with: credential) { (authResult, error) in
                 if let error = error {
                    print(error)
                    print("can't sign in to Firebase")
                     return
                 }
                 // User is signed in
        guard let mainController = self.window?.rootViewController?.presentedViewController else { return }
 
                mainController.performSegue(withIdentifier: "loggedIn", sender: nil)
 
            }
     
        }
    
    }

        
//        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
//            // Perform any operations when the user disconnects from app here.
//            // ...
//        }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


 

