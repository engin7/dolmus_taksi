//
//  Trip.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.



import Foundation
import Firebase
import UIKit
import MapKit
 
let db = Firestore.firestore()
      var tripReference: CollectionReference {
      return db.collection("Trips")
      }
 
var tSpam = 0.0

 
struct Trips {
    
    let id: String
    var time: Date
    var from:String
    var fromCity: String
    var fromLocation: [Double]
    var to: String
    var toCity: String
    var Passengers: [String]
    var welcomed : Bool
 
    init(time:Date, to:String, toCity:String, from:String, fromLocation:[Double], fromCity:String, passengers:String, id:String) {
      self.id = id
      self.time = time
      self.to = to
      self.toCity = toCity
      self.from = from
      self.fromLocation = fromLocation
      self.fromCity = fromCity
      self.Passengers = [passengers]
      self.welcomed = false
      }
       
        // firestore initialization:
    
    init?(document: DocumentSnapshot) {
   
        let data = document.data()
 
        guard let date = data!["time"] as? Timestamp else {
           return nil
         }
         let time = date.dateValue()
        guard let to = data!["to"] as? String else {
           return nil
         }
        guard let from = data!["from"] as? String else {
           return nil
         }
        guard let fromCity = data!["fromCity"] as? String else {
           return nil
         }
        guard let fromLocation = data!["fromLocation"] as? [Double] else {
          return nil
        }
        guard let toCity = data!["toCity"] as? String else {
          return nil
        }
        guard let Passengers = data!["passengers"] as? [String] else {
                  return nil
         }
        guard let welcomed = data!["welcomed"] as? Bool else {
                         return nil
                }
      
        
         id = document.documentID
           self.time     = time
           self.to       = to
           self.from     = from
           self.fromCity = fromCity
           self.fromLocation = fromLocation
           self.toCity  = toCity
           self.Passengers = Passengers
           self.welcomed = welcomed
        }
}
    
 
extension Trips: DatabaseRepresentation {
  
    var representation: [String : Any]   {
    [
    "to": to,
    "from": from,
    "fromCity": fromCity,
    "fromLocation": fromLocation,
    "toCity" : toCity,
    "time": time,
    "passengers": Passengers,
    "id" : id,
    "welcomed": welcomed,
     ]
   }
 }

// MARK: Other Extensions

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
       dateFormatter.dateFormat = "HH:mm"
   
   return dateFormatter.string(from: date)
  
  }

