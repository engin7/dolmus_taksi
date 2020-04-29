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
        mailVC.setMessageBody("email message ...", isHTML: false)

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
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

   //MARK: - MFMail compose method
   func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
       controller.dismiss(animated: true, completion: nil)
   }
    
}
