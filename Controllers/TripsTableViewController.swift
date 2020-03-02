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
    
    @IBOutlet weak var PersonImage0: UIImageView!
    
    @IBOutlet weak var PersonImage1: UIImageView!
    
    @IBOutlet weak var PersonImage2: UIImageView!
    
    @IBOutlet weak var PersonImage3: UIImageView!
    
 
 }


    class TripsTableViewController: UITableViewController {


      
        @IBAction func chatButtton(_ sender: Any) {
    //        let vc = ChatViewController(currentUser: currentUser!, trip: Trips(time: Date(), to: "Africa", from: "rr", persons: 3))
    //        navigationController?.pushViewController(vc, animated: true)
            // !!should go to a list with joined trips
        }

        private let TripsCellIdentifier = "TripsCell"
        private var currentTripsAlertController: UIAlertController?
       
        private var tripListener: ListenerRegistration?
        static var trips : [Trips] = []
        
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
                    
                    TripsTableViewController.trips.append(trip)

                case .modified:
                    guard let index = TripsTableViewController.trips.firstIndex(of: trip)    else {
                      return
                    }
                    TripsTableViewController.trips[index] = trip
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    
                case .removed:
                    guard let index =  TripsTableViewController.trips.firstIndex(of: trip) else {
                      return
                    }
                    TripsTableViewController.trips.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                 }

                   self.tableView.reloadData()
                }
            }
          }
  
        // MARK: UITableView Delegate methods

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return  TripsTableViewController.trips.count
         }
         
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsTableViewCell", for: indexPath) as! TripsTableViewCell
            let trip =  TripsTableViewController.trips[indexPath.row]
                     
            cell.fromTextLabel.text =  trip.from
            cell.toTextLabel.text = trip.to
            let time = getReadableDate(time: trip.time)
            cell.timeTextLabel.text = time
            switch trip.Passengers.count {
                
            case 1:
                cell.PersonImage1.isHidden = true
                cell.PersonImage2.isHidden = true
                cell.PersonImage3.isHidden = true
            case 2:
                cell.PersonImage3.isHidden = true
                cell.PersonImage2.isHidden = true
                cell.PersonImage1.isHidden = false
            case 3:
                cell.PersonImage3.isHidden = true
                cell.PersonImage2.isHidden = false
                cell.PersonImage1.isHidden = false
            case 4:
                cell.backgroundColor  =  UIColor.gray
                cell.PersonImage3.isHidden = false
               
               
            default:
               break
            }
            return cell
          }
       
         override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
             }
     
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

            if editingStyle == .delete {
                let trip =  TripsTableViewController.trips[indexPath.row]
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
           
           
            var trip =  TripsTableViewController.trips[indexPath.row]
            let documentId = trip.id
             if trip.Passengers.count < 4 {
            let vc = ChatViewController(currentUser: currentUser!, trip: trip)
            navigationController?.pushViewController(vc, animated: true)

                  print(trip.Passengers)
            if trip.Passengers.contains(currentUser!.email) == false {
   
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
    }


 
