 
import Foundation
import Firebase
import CoreLocation
import UserNotifications

 
var currentUser: User?
 
struct User {
  
  let uid: String
  let displayName: String
  
  init(authData: Firebase.User) {
    uid = authData.uid
    displayName = randomAlphaNumericString(length: 9)
  }
  
    init(uid: String, nick: String) {
    self.uid = uid
    self.displayName = nick
    }
}
 
 func randomAlphaNumericString(length: Int) -> String {
     let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDE-0123456789"
     let allowedCharsCount = UInt32(allowedChars.count)
     var randomString = ""

     for _ in 0..<length {
         let randomNum = Int(arc4random_uniform(allowedCharsCount))
         let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
         let newCharacter = allowedChars[randomIndex]
         randomString += String(newCharacter)
     }

     return randomString
 }
 
