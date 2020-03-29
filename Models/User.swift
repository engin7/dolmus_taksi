 
import Foundation
import Firebase
import CoreLocation
import UserNotifications

 
var currentUser: User?
 
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

 
 
