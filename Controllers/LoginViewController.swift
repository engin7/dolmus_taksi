//
//  LoginViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var  LoginEmail: UITextField!
    @IBOutlet weak var LoginPassword: UITextField!
    
    override func viewDidLoad() {
        
        let listener = Auth.auth().addStateDidChangeListener() { auth, user in
        if user != nil {
          self.performSegue(withIdentifier: "loggedIn", sender: nil)
            self.LoginEmail.text = nil
            self.LoginPassword.text = nil
            currentUser = User(authData: user!)
            AppSettings.displayName = "willbeUpdated..."

          }
       }
       Auth.auth().removeStateDidChangeListener(listener)
     }
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        
          guard
            let email = self.LoginEmail.text,
            let password = self.LoginPassword.text,
            email.count > 0,
            password.count > 0
            else {
              return
          }
          
          Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
              let alert = UIAlertController(title: "Sign In Failed",
                                            message: error.localizedDescription,
                                            preferredStyle: .alert)
              
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              
              self.present(alert, animated: true, completion: nil)
            }
          }
        }
 
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
      let alert = UIAlertController(title: "Register",
                                    message: "Register",
                                    preferredStyle: .alert)
      
      let saveAction = UIAlertAction(title: "Save",
                                     style: .default) { action in
      
         let emailField = alert.textFields![0]
         let passwordField = alert.textFields![1]

     Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
           if error != nil {
            if let errorCode = AuthErrorCode(rawValue: error!._code) {
              switch errorCode {
              case .weakPassword:
                print("please provide strong password")
              default:
                print("There is an error")
                
              }
            }
           }
          if user != nil {
            user?.user.sendEmailVerification() {
              error in
                print(error?.localizedDescription as Any)
            }
             Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!)
            self.performSegue(withIdentifier: "loggedIn", sender: nil)
          }
        }
      }
      let cancelAction = UIAlertAction(title: "Cancel",
                                       style: .default)
      
      alert.addTextField { textEmail in
        textEmail.placeholder = "Enter your email"
      }
      
      alert.addTextField { textPassword in
        textPassword.isSecureTextEntry = true
        textPassword.placeholder = "Enter your password"
      }
      
      alert.addAction(saveAction)
      alert.addAction(cancelAction)
      
      present(alert, animated: true, completion: nil)
    }
   
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == LoginEmail {
      LoginPassword.becomeFirstResponder()
    }
    if textField == LoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
  
}
