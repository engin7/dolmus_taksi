//
//  sort.swift
//  Taxiz
//
//  Created by Engin KUK on 23.05.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation

var trips : [Trips] = []
var availableTrips : [Trips] = []
var myTrips : [Trips] = []
var userLocation = myUserLocation
let today = Date()

 
func sorting(completion: @escaping (_ success: Bool?) -> Void) {
 
    let success = true

    availableTrips.sort(by: {$0.time < $1.time} )
     
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

        trips.insert(contentsOf:  availableTrips, at: 0)
                availableTrips = []
        
          trips.insert(contentsOf:  myTrips, at: 0)
                myTrips = []
          
         deletePastChannels()
            
         completion(success)
        
          }
      }

   func deletePastChannels() {
       // will lower time to 2 hours when reach many active users, chat messages stays in database, i'll delete them manually after checking if there is any reports in the chat rooms.
              let past = Calendar.current.date(byAdding: .hour, value: -32, to: today)
               
              for Trips in trips {

               if Trips.time < past! || Trips.Passengers.count == 0 {
                     
                    let documentId = Trips.id
                   tripReference.document(documentId!).delete() { error in
                   if let error = error {
                       print(error.localizedDescription)
                   } else {
                       print("File deleted successfully")
                   }
                }
            }
         }
       }

        func sortLocation(){
    
          
         trips.sort(by: {(abs($0.fromLocation[0] - (  userLocation?.coordinate.latitude)!),abs($0.fromLocation[1] - ( userLocation?.coordinate.longitude)!)) < (abs($1.fromLocation[0] - ( userLocation?.coordinate.latitude)!),abs($1.fromLocation[1] - ( userLocation?.coordinate.longitude)!)) })

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {

              NotificationCenter.default.post(name: Notification.Name("newDataNotificationForItemEdit"), object: nil)
 
             }
            
      }
