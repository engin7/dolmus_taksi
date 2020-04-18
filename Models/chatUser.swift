//
//  chatUsers.swift
//  Taxiz
//
//  Created by Engin KUK on 11.04.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import Firebase


struct chatUser {

var id: String?
let passenger: Bool
let nickName: String
let uid: String
    
    init(nickName: String, passenger: Bool, uid: String) {
     self.nickName = nickName
     self.passenger = passenger
     self.uid = uid
     id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
   
    let data = document.data()
 
        guard let nickName = data["nick"] as? String else {
                   return nil
                 }
        guard let uid = data["uid"] as? String else {
                          return nil
                        }
        guard let passenger = data["passenger"] as? Bool else {
            return nil
          }
        
    id = document.documentID
    self.nickName = nickName
    self.passenger = passenger
    self.uid = uid
    }
}

extension chatUser: DatabaseRepresentation {
  
  var representation: [String : Any] {
    [
           "nick": nickName,
           "uid" : uid,
      "passenger": passenger
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
