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
import MessageUI


class ProfileTableViewController:  UITableViewController, MFMailComposeViewControllerDelegate
 {

    @IBAction func contactUs(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
  let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["kuk.engin@icloud.com"])
        mailVC.setSubject("Subject for email")
        mailVC.setMessageBody("Email message string", isHTML: false)

        present(mailVC, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: "e-mail not connected", message: "Please enable your email account in your device.", preferredStyle: .alert)
                    
                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil);
                 }))
                 self.present(alert, animated: true, completion: nil)

        }
        
  }
    
    @IBOutlet weak var nickName: UILabel!
    
 
    override func viewDidLoad() {
           super.viewDidLoad()
        overrideUserInterfaceStyle = .light
 
        nickName.text = "nickName: " + currentUser!.displayName
    }
 
    
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
    
   //MARK: - MFMail compose method
   func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
       controller.dismiss(animated: true, completion: nil)
   }
    
    
}
