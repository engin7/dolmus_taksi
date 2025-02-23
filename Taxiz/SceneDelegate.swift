//
//  SceneDelegate.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    let dateFormatter = DateFormatter()

   

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
         if  KeychainWrapper.standard.string(forKey: "Key97") != nil {

        guard let windowScene = (scene as? UIWindowScene) else { return }
         
                let vc = self.storyboard.instantiateViewController (withIdentifier: "tabs") as! UITabBarController
        
                self.window = UIWindow(windowScene: windowScene)
                self.window?.rootViewController = vc
                self.window?.makeKeyAndVisible()
        
            }
         }
   
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
     
          
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
        if cUser != nil {
        NotificationCenter.default.post(name: Notification.Name("foreground"), object: nil)
        
            // refresh to get rating list
            
        userId!.getDocument { (document, error) in
          if let document = document, document.exists {
          cUser = chatUser(document: document)
              } }
         
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
       
        NotificationCenter.default.post(name: Notification.Name("away"), object: nil)
         
        UserDefaults().set(Date(), forKey: "lastOnline")

        
    }


}

