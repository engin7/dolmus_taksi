//
//  LoginViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
//import FireBase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var  LoginEmail: UITextField!
     @IBOutlet weak var LoginPassword: UITextField!
    
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "loginToMap", sender: nil)
    }
    
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
    }
    
    
}
