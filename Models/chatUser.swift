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


var chatUserReference: CollectionReference {
return db.collection("chatUsers")
}

struct chatUser {

var id: String?
let passenger: Bool
let nickName: String
let uid: String
var blocked: [String]
var fcmToken: String?
var chatUserId: [String:String]?
    
    init(fcmToken: String) {
     self.nickName = currentUser!.displayName
     self.passenger = false
     self.uid = currentUser!.uid
     id = nil
     blocked = []
     chatUserId = [:]
     self.fcmToken = fcmToken
    }
    
    init?(document: DocumentSnapshot) {
   
    let data = document.data()
 
        guard let nickName = data!["nick"] as? String else {
                   return nil
                 }
        guard let uid = data!["uid"] as? String else {
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
        
      
        
    id = document.documentID
    self.nickName = nickName
    self.passenger = passenger
    self.uid = uid
    self.blocked = blocked
    self.fcmToken = fcmToken
    self.chatUserId = chatUserId
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
    ]
   }
}

extension chatUser: Comparable {
    static func < (lhs: chatUser, rhs: chatUser) -> Bool {
            return lhs.nickName < rhs.nickName
    }
  
  static func == (lhs: chatUser, rhs: chatUser) -> Bool {
    return lhs.id == rhs.id
  }
  
}
