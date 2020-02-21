//
//  User.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import Firebase
import UIKit
 
var currentUser : User!
 
var trips : [Trips] = []  // Trips is an array many values like route, persons etc. So this is array in array
 

struct User {
  
  let uid: String
  let email: String
  
  init(authData: Firebase.User) {
    uid = authData.uid
    email = authData.email!
  }
  
  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
}

// Other Models

 protocol DatabaseRepresentation {
   var representation: [String: Any] { get }
 }

extension UIColor {
  
  static var primary: UIColor {
    return UIColor(red: 1 / 255, green: 93 / 255, blue: 48 / 255, alpha: 1)
  }
  
  static var incomingMessage: UIColor {
    return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
  }
  
}
