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
    
    @IBOutlet weak var persons: UIStackView!
    
    @IBOutlet weak var personImage: UIImageView!
    
    
    
//    func imageOfPersons {
//
//        let image = UIImage()
//        image.dra =
//
//
//    }
    
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
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                case .removed:
                    guard let index =  TripsTableViewController.trips.firstIndex(of: trip) else {
                      return
                    }
                    TripsTableViewController.trips.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
            
            cell.setHighlighted(true, animated: true)

            return cell
          }
       
         override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
             }

       
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            
              let trip =  TripsTableViewController.trips[indexPath.row]
            let vc = ChatViewController(currentUser: currentUser!, trip: trip)
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
  
    }


 
