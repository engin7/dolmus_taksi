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
 
   let db = Firestore.firestore()
   var tripReference: CollectionReference {
   return db.collection("Trips")
   }
   

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
