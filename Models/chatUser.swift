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
var host: chatUser?
var userId: DocumentReference?
 

var chatUserReference: CollectionReference {
return db.collection("chatUsers")
}

struct chatUser {

var id: String?
let passenger: Bool
let nickName: String
let uid: String
var blocked: [String]?

    init(nickName: String, uid: String) {
     self.nickName = nickName
     self.passenger = false
     self.uid = uid
     id = nil
     blocked = []
    }
    
    init?(document: DocumentSnapshot) {
   
    let data = document.data()
 
        guard let nickName = data!["nick"] as? String else {
                   return nil
                 }
        guard let uid = data!["uid"] as? String else {
                          return nil
                        }
        guard let blocked = data!["blocked"] as? [String]? else {
                               return nil
                             }
        guard let passenger = data!["passenger"] as? Bool else {
            return nil
          }
        
    id = document.documentID
    self.nickName = nickName
    self.passenger = passenger
    self.uid = uid
    self.blocked = blocked
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
