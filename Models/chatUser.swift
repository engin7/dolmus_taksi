//
//  chatUsers.swift
//  Taxiz
//
//  Created by Engin KUK on 11.04.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import Firebase

var cUser: chatUser?
var userId: DocumentReference?
var host: chatUser?
var ratingCount = true

var chatUserReference: CollectionReference {
return db.collection("chatUsers")
}

struct chatUser {

var id: String?
let passenger: Bool
let nickName: String?
let uid: String?
var blocked: [String]
var fcmToken: String?
var chatUserId: [String:String]?
var passengerUserId: [String:String]?
var rating: [Int]
var ratedBy: [String:Date]?
    
    init(fcmToken: String) {
     self.nickName = currentUser?.displayName
     self.passenger = false
     self.uid = currentUser?.uid
     blocked = []
     rating = []
     ratedBy = [:]
     chatUserId = [:]
     passengerUserId = [:]
     self.fcmToken = fcmToken
    }
    
    init?(document: DocumentSnapshot) {
   
    let data = document.data()
 
        guard let nickName = data!["nick"] as? String? else {
                   return nil
                 }
        guard let uid = data!["uid"] as? String? else {
                          return nil
                        }
        guard let blocked = data!["blocked"] as? [String] else {
                               return nil
                             }
        guard let passenger = data!["passenger"] as? Bool else {
            return nil
          }
        guard let fcmToken = data!["fcmToken"] as? String? else {
          return nil
        }
        guard let chatUserId = data!["chatUserId"] as? [String:String]? else {
                 return nil
               }
        guard let passengerUserId = data!["passengerUserId"] as? [String:String]? else {
          return nil
        }
        guard let rating = data!["rating"] as? [Int] else {
                       return nil
                     }
        guard let dateRate = data!["ratedBy"]as? [String:Timestamp]? else {
                  return nil
                }
        
        let arrayOfValues = dateRate!.values
        var arrayOfValuesDate : [Date] = []
        
        let arrayOfKeys = dateRate?.keys
        
        for value in arrayOfValues {
            arrayOfValuesDate.append(value.dateValue())
        }
        
        let ratedBy = Dictionary(uniqueKeysWithValues: zip(arrayOfKeys!, arrayOfValuesDate))

        
    id = document.documentID
    self.nickName = nickName
    self.passenger = passenger
    self.uid = uid
    self.blocked = blocked
    self.fcmToken = fcmToken
    self.chatUserId = chatUserId
    self.passengerUserId = passengerUserId
    self.ratedBy = ratedBy
    self.rating = rating
    }
}

extension chatUser: DatabaseRepresentation {
  
  var representation: [String : Any] {
    [
           "nick": nickName,
           "uid" : uid,
      "passenger": passenger,
        "blocked": blocked,
            "id" : id,
      "fcmToken" : fcmToken,
    "chatUserId" : chatUserId,
    "passengerUserId" : passengerUserId,
      "rating"   : rating,
      "ratedBy"  : ratedBy,
    ]
   }
}

extension chatUser: Comparable {
    static func < (lhs: chatUser, rhs: chatUser) -> Bool {
        return lhs.rating.count < rhs.rating.count
    }

  static func == (lhs: chatUser, rhs: chatUser) -> Bool {
    return lhs.id == rhs.id
  }

}
