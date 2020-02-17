//
//  Trip.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import Firebase

struct Trips {
    
    let key: String
    let name: String
    let addedByUser: String
    let ref: DatabaseReference?
    var completed: Bool
    var time: DateFormatter // for remaning minutes
    var from:String
    var to: String
    var persons: Int
    var price: Int
    
    init(name: String, addedByUser: String, time: DateFormatter, completed: Bool, key: String = "", to: String, from: String, persons: Int, price: Int) {
      self.key = key
      self.name = name
      self.addedByUser = addedByUser
      self.completed = completed
      self.ref = nil
      self.time = time
      self.to = to
      self.from = from
      self.price = price
      self.persons = persons
        
    }
}

