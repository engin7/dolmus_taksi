//
//  TripsViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class TripsTableViewCell: UITableViewCell  {
  
    @IBOutlet weak var fromTextLabel: UILabel!
        
    @IBOutlet weak var toTextLabel: UILabel!
    
    @IBOutlet weak var timeTextLabel: UILabel!
    
    @IBOutlet weak var fromCityTextLabel: UILabel!
    
    @IBOutlet weak var toCityTextLabel: UILabel!
    
    
    @IBOutlet weak var PersonImage0: UIImageView!
    
    @IBOutlet weak var PersonImage1: UIImageView!
    
    @IBOutlet weak var PersonImage2: UIImageView!
    
    @IBOutlet weak var PersonImage3: UIImageView!
    
 
 }


    class TripsTableViewController: UITableViewController {


      
        @IBAction func chatButtton(_ sender: Any) {
   
            
            
        }

        private let TripsCellIdentifier = "TripsCell"
        private var currentTripsAlertController: UIAlertController?
       
        var tripListener: ListenerRegistration?
        var trips : [Trips] = []
        var joinedTrips : [Trips] = []
        let today = Date()
       
        
        deinit {
          tripListener?.remove()
        }
              
      override func viewDidLoad() {
        super.viewDidLoad()
        
        // listed document and get document with snapshot
        tripListener = tripReference.addSnapshotListener { querySnapshot, error in
          guard let snapshot = querySnapshot else {
            print("Error listening updates: \(error?.localizedDescription ?? "No error")")
            return
            }
            
            // *type added gets initial values at the begining
            snapshot.documentChanges.forEach { change in
                guard let trip = Trips(document: change.document) else {
                     return
                   }
                
                switch change.type {
                
                case .added:
                
                  if  !trip.Passengers.contains(currentUser!.email) {
                    self.trips.append(trip)
                    
//                    self.trips.sort(by: {$0.from < $1.from})
//                    self.trips.sort(by: {$0.to < $1.to})
                      self.trips.sort(by: {$0.time < $1.time})
               
                 } else {
                    self.joinedTrips.append(trip)
                 }
                 
                case .modified:
                    guard let index = self.trips.firstIndex(of: trip)    else {
                      return
                    }
                    self.trips[index] = trip
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    
                case .removed:
                    guard let index =  self.trips.firstIndex(of: trip) else {
                      return
                    }
                    self.trips.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                 }
                   
                }
               
                  self.trips.insert(contentsOf: self.joinedTrips, at: 0)
                  self.joinedTrips = []
                  self.deletePastChannels()
                  self.tableView.reloadData()
            }
          }
  
        
        func deletePastChannels() {
            
               let past = Calendar.current.date(byAdding: .hour, value: -24, to: today)
              //will update, will make  < now deletes bigger than yesterday
               for Trips in trips {
                   
                   if Trips.time > past! {
                      
                     let documentId = Trips.id
                    tripReference.document(documentId).delete() { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("File deleted successfully")
                    }
                        
                    }
               }
        }
        }
        
        // MARK: UITableView Delegate methods

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return  self.trips.count
         }
         
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsTableViewCell", for: indexPath) as! TripsTableViewCell
            let trip =  self.trips[indexPath.row]
            
            cell.fromTextLabel.text =  trip.from
            cell.toTextLabel.text = trip.to
            cell.toCityTextLabel.text = trip.toCity
            cell.fromCityTextLabel.text = trip.fromCity
            let time = getReadableDate(time: trip.time)
            cell.timeTextLabel.text = time
            
            cell.fromTextLabel.textColor = UIColor.black
            cell.toTextLabel.textColor = UIColor.black
            cell.timeTextLabel.textColor = UIColor.black
            cell.fromCityTextLabel.textColor = UIColor.black
            cell.toCityTextLabel.textColor = UIColor.black

            switch trip.Passengers.count {
                
            case 1:
                cell.PersonImage1.isHidden = true
                cell.PersonImage2.isHidden = true
                cell.PersonImage3.isHidden = true
                cell.contentView.alpha = 0.8

            case 2:
                cell.PersonImage3.isHidden = true
                cell.PersonImage2.isHidden = true
                cell.PersonImage1.isHidden = false
                cell.contentView.alpha = 0.8

            case 3:
                cell.PersonImage3.isHidden = true
                cell.PersonImage2.isHidden = false
                cell.PersonImage1.isHidden = false
                cell.contentView.alpha = 0.8

            case 4:
                cell.contentView.alpha = 0.4
                cell.PersonImage3.isHidden = false
                cell.PersonImage2.isHidden = false
                cell.PersonImage1.isHidden = false
                cell.selectionStyle = .none
                
            default:
               break
            }
          
            if trip.Passengers.contains(currentUser!.email) {
             cell.alpha = 0
             cell.backgroundColor = UIColor.lightGray
             UIView.animate(withDuration: 2.0, animations: {
              cell.alpha = 1.0
              cell.fromTextLabel.textColor = UIColor.red
              cell.toTextLabel.textColor = UIColor.red
              cell.timeTextLabel.textColor = UIColor.red
              cell.fromCityTextLabel.textColor = UIColor.red
              cell.toCityTextLabel.textColor = UIColor.red
              cell.backgroundColor = UIColor.white
            })
                 
          }
              return cell
            
          }
       
        
         override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
             }
     
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            if editingStyle == .delete   {
                let trip =  self.trips[indexPath.row]
                let documentId = trip.id
                            
                tripReference.document(documentId).delete() { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("File deleted successfully")
                }
            }
          }
        }
                
        fileprivate func updatePassengers(_ documentId: String, _ trip: Trips) {
            tripReference.document(documentId).updateData([
                "passengers": trip.Passengers
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
            var trip =  self.trips[indexPath.row]
            let documentId = trip.id
            
          if trip.Passengers.count < 4 || trip.Passengers.contains(currentUser!.email) {
                
             let vc = ChatViewController(currentUser: currentUser!, trip: trip)
            navigationController?.pushViewController(vc, animated: true)

                  print(trip.Passengers)
            if !(trip.Passengers.contains(currentUser!.email))  {
   
            let alert = UIAlertController(title: trip.to + "  " + getReadableDate(time: trip.time)!, message: "How many passengers will join the trip?", preferredStyle: .alert)
       
            alert.addAction(UIAlertAction(title: "None, I'm just looking.", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "1", style: .destructive, handler: { action in
                trip.Passengers.append(currentUser!.email)
                self.updatePassengers(documentId, trip)
            }))
           
            if trip.Passengers.count < 3 {
            alert.addAction(UIAlertAction(title: "2", style: .default, handler: { action in
                trip.Passengers.append(currentUser!.email)
                trip.Passengers.append(currentUser!.email + "+1")
                self.updatePassengers(documentId, trip)
            }))
            }
                
            if trip.Passengers.count < 2 {
            alert.addAction(UIAlertAction(title: "3", style: .default, handler: { action in
                trip.Passengers.append(currentUser!.email)
                trip.Passengers.append(currentUser!.email + "+1")
                trip.Passengers.append(currentUser!.email + "+2")
                self.updatePassengers(documentId, trip)
            }))
            }
            self.present(alert, animated: true)
          }
        }
      }
        
        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            
        
            
            
        }
    }


 
