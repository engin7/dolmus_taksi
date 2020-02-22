//
//  Trip.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import Firebase
import UIKit

//let tripItemsReference = Database.database().reference(withPath: "trip-items") *Firebase
//let tripItemsRef =  tripItemsReference.child((currentUser!.uid.lowercased()))

struct Trips {
    
    let id: String?
    var time: Date
    var from:String
    var to: String
    var persons: Int
 
    init(time:Date, to:String, from:String, persons:Int) {
      self.id = nil
      self.time = time
      self.to = to
      self.from = from
      self.persons = persons
        
    }
    
    init?(document: QueryDocumentSnapshot) {
      let data = document.data()
      
      guard let time = data["time"] as? Date else {
        return nil
      }
      guard let to = data["to"] as? String else {
        return nil
      }
      guard let from = data["from"] as? String else {
        return nil
      }
      guard let persons = data["persons"] as? Int else {
        return nil
      }
      id = document.documentID
        self.time    = time
        self.to      = to
        self.from    = from
        self.persons = persons
 
    }
     
}

extension Trips: DatabaseRepresentation {
  
  var representation: [String : Any] {
    var rep: [String : Any] = [
    "to": to,
    "from": from,
    "time": time,
    "persons": persons
    ]
 
    if let id = id {
      rep["id"] = id
    }
    
    return rep
  }
  
}

extension Trips: Comparable {
  
  static func == (lhs: Trips, rhs: Trips) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Trips, rhs: Trips) -> Bool {
    return lhs.to < rhs.to
  }

}
