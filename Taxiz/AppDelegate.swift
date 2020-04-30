//
//  AppDelegate.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {
  
   var ref: DatabaseReference!
 
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           // Use Firebase library to configure APIs
           FirebaseApp.configure()
          
           Database.database().isPersistenceEnabled = true

           ref = Database.database().reference()
            
        let listener = Auth.auth().addStateDidChangeListener() { auth, user in
                   // auto sign-in and move to next view:
               if user != nil {
                currentUser = User(authData: user!)
             
             if  KeychainWrapper.standard.string(forKey: "myKey") != nil {
                
             
            let documentID = KeychainWrapper.standard.string(forKey: "myKey")
                
                  userId = chatUserReference.document(documentID!)

                userId!.getDocument { (document, error) in
                    if let document = document, document.exists {
                    cUser = chatUser(document: document)
                       
                    } }}
               }
        
            
            if  KeychainWrapper.standard.string(forKey: "myKey") == nil {
        // if user disabled from firestore consol it won't get new uid
 
                Auth.auth().signInAnonymously() { (user, error) in
                           
                 if let user = user {
                   
                   currentUser = User(authData: user.user)
                    
                    cUser = chatUser(nickName: currentUser!.displayName, uid: currentUser!.uid)
                                 
                      userId = chatUserReference.addDocument(data: cUser!.representation) { error in
                    if let e = error {
                      print("Error sending message: \(e.localizedDescription)")
                      return
                        }

                       }
                    
                    _ = KeychainWrapper.standard.set(userId!.documentID, forKey: "myKey")

               }
           }
         }
             
      }
        
        Auth.auth().removeStateDidChangeListener(listener)
 
        return true

    }
 
    

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

 }
    


