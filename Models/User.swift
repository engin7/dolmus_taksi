//
//  User.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import Firebase
 
var currentUser: Firebase.User!
var trips : [Trips] = []  // Trips is an array many values like route, persons etc. So this is array in array
 

struct User {
  
  let uid: String
  let email: String
  
  init(authData: User) {
    uid = authData.uid
    email = authData.email
  }
  
  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
  
}

 


