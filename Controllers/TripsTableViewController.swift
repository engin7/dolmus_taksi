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
      
        @objc func refresh(sender:AnyObject)
        {
            // Updating your data here...
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            // need to use firestore document change option
        }
        
      override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        // listed document and get document with snapshot
        tripListener = tripReference.addSnapshotListener { querySnapshot, error in
          guard let snapshot = querySnapshot else {
            print("Error listening updates: \(error?.localizedDescription ?? "No error")")
            return
            }
            // *type added gets initial values at the begining
            snapshot.documentChanges.forEach { change in
              if (change.type == .added) {
                TripsTableViewController.trips.append(Trips(document: change.document)!)
                self.tableView.reloadData()
                } else {
                  return
                }
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


 
