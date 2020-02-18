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

let tripItemsReference = Database.database().reference(withPath: "trip-items")
let tripItemsRef =  tripItemsReference.child(currentUser.uid.lowercased())




struct Trips {
    
    let key: String
    let addedByUser: String
    let ref: DatabaseReference?
    var completed: Bool
    var time: Int // for remaning minutes
    var from:String
    var to: String
    var persons: Int
    var price: Int
    
    init( addedByUser: String, time: Int, completed: Bool, key: String = "", to: String, from: String, persons: Int, price: Int) {
      self.key = key
      self.addedByUser = addedByUser
      self.completed = completed
      self.ref = nil
      self.time = time
      self.to = to
      self.from = from
      self.price = price
      self.persons = persons
        
    }
    
    
    init(snapshot: DataSnapshot) {
      key = snapshot.key
      let snapshotValue = snapshot.value as! [String: AnyObject]
      addedByUser = snapshotValue["addedByUser"] as! String
      completed = snapshotValue["completed"] as! Bool
      time = snapshotValue["time"] as! Int
      from = snapshotValue["from"] as! String
      to = snapshotValue["to"] as! String
      price = snapshotValue["price"] as! Int
      persons = snapshotValue["persons"] as! Int
        
      ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
      return [
        "addedByUser": addedByUser,
        "completed": completed
      ]
    }
    
}

