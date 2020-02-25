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
    
    let id: String
    var time: Date
    var from:String
    var to: String
    var persons: Int
 
    init(time:Date, to:String, from:String, persons:Int, id:String) {
      self.id = id
      self.time = time
      self.to = to
      self.from = from
      self.persons = persons
    }
  
    init?(document: QueryDocumentSnapshot) {
   
        let data = document.data()
 
         guard let date = data["time"] as? Timestamp else {
           return nil
         }
         let time = date.dateValue()
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
  
    var representation: [String : Any]   {
    [
    "to": to,
    "from": from,
    "time": time,
    "persons": persons,
        "id" : id
    ]
   }
 }
  
 

//- Other extensions

extension Trips: Comparable {
  
  static func == (lhs: Trips, rhs: Trips) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Trips, rhs: Trips) -> Bool {
    return lhs.to < rhs.to
  }

}

protocol DatabaseRepresentation {
  var representation: [String: Any] { get }
}


extension UIColor {
  
  static var primary: UIColor {
    return UIColor(red: 1 / 255, green: 93 / 255, blue: 48 / 255, alpha: 1)
  }
  
  static var incomingMessage: UIColor {
    return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
  }
  
}

    // convert time data to string
  func getReadableDate(time: Date) -> String? {
   let date = time
   let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "hh:mm"
  return dateFormatter.string(from: date)
  
  }
