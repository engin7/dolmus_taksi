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
    
    init(nickName: String, passenger: Bool) {
     self.nickName = nickName
     self.passenger = passenger
     id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
   
    let data = document.data()
 
        guard let nickName = data["nick"] as? String else {
                   return nil
                 }
    
        guard let passenger = data["passenger"] as? Bool else {
            return nil
          }
        
    id = document.documentID
    self.nickName = nickName
    self.passenger = passenger

    }
}

extension chatUser: DatabaseRepresentation {
  
  var representation: [String : Any] {
    [
           "nick": nickName,
      "passenger": passenger
    ]
   }
}
