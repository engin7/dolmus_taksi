 
import Foundation
import Firebase
import CoreLocation
import UserNotifications
import UIKit
 
var currentUser: User?
var initialName: String?
 
var reportedReference: CollectionReference {
return db.collection("reportedUsers")
}
let usersRef = Database.database().reference(withPath: "online")
var  docRefOnline : DatabaseReference?

struct User {
  
  let uid: String 
  let displayName: String
  var previousTrip: Date?
  

  init(authData: Firebase.User) {
    
    uid = authData.uid
    displayName = String(uid.prefix(6)).lowercased()
    previousTrip = nil
    }
    
    init() {
        
        self.uid = "terminal"
        self.displayName = "terminal"
        self.previousTrip = nil
     }
    
}

 struct rUser {
 
 let uid: String
 let docName: String
 
    
      init(uid: String, docName: String) {
       self.uid = uid
       self.docName = docName
       }
      
      init?(document: QueryDocumentSnapshot) {
     
      let data = document.data()
   
          guard let docName = data["docName"] as? String else {
                     return nil
                   }
          guard let uid = data["uid"] as? String else {
                            return nil
                          }
        
          
      self.docName = docName
      self.uid = uid
      }
  }
 
  extension rUser: DatabaseRepresentation {
   
     var representation: [String : Any]   {
     [
     "docName": docName,
     "uid": uid,
     ]
    }
  }

 // for online users
 
 
 
 
 
// TODO: Autogen weekly random nicks
// func randomAlphaNumericString(length: Int) -> String {
//     let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDE-0123456789"
//     let allowedCharsCount = UInt32(allowedChars.count)
//     var randomString = ""
//
//     for _ in 0..<length {
//         let randomNum = Int(arc4random_uniform(allowedCharsCount))
//         let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
//         let newCharacter = allowedChars[randomIndex]
//         randomString += String(newCharacter)
//      }
//
//
//     return randomString
// }
//
 
