 
import Foundation
import Firebase
import CoreLocation
import UserNotifications

var currentUser: User?
var initialName: String?

struct User {
  
  let uid: String 
  let displayName: String
  var previousTrip: Date?
    
  init(authData: Firebase.User) {
    
 
    uid = authData.uid
    displayName = String(uid.prefix(8)).lowercased()
    previousTrip = nil
    }
    
    init() {
        
        self.uid = "terminal"
        self.displayName = "terminal"
        self.previousTrip = nil
     }
    
}

  
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
