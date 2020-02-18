//
//  SecondViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController {    
    
    @IBAction func SignoutButton(_ sender: UIButton) {
     
          do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
          } catch (let error) {
            print("Auth sign out failed: \(error)")
          }
        }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

