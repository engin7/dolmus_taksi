//
//  ProfileTableViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 24.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import Foundation


class ProfileTableViewController:  UITableViewController {
 
    @IBAction func SignOutButton(_ sender: Any) {
        
        let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
          ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
              try Auth.auth().signOut()
                // clear array not to have duplicate
//                 trips.removeAll()
                // go backt to sing in screen
             self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                
             } catch {
              print("Error signing out: \(error.localizedDescription)")
            }
          }))
          present(ac, animated: true, completion: nil)
    }
    
   
    
}
