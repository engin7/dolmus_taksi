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
    
    @IBOutlet weak var profileImage: UIImageView!
    
 }


    class TripsTableViewController: UITableViewController {


      
        @IBAction func chatButtton(_ sender: Any) {
    //        let vc = ChatViewController(currentUser: currentUser!, trip: Trips(time: Date(), to: "Africa", from: "rr", persons: 3))
    //        navigationController?.pushViewController(vc, animated: true)
            // should go to a list with joined trips
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
            // type added gets initial values at the begining
            snapshot.documentChanges.forEach { diff in
            if (diff.type == .added) {
                let to  = diff.document.get("to") as! String
                let from = diff.document.get("from") as! String
                let persons = diff.document.get("persons") as! Int
                let time = diff.document.get("time") as! Timestamp
                let id = diff.document.documentID as String
                let newTrip = Trips(time: time.dateValue(), to: to, from: from, persons: persons, id: id)
                TripsTableViewController.self.trips.append(newTrip)
                print(diff.document )
            }
            }
            self.tableView.reloadData()
        }
 
 
        }
           
     
        // MARK: - Actions
        
        @objc private func signOut() {
          let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
          ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
              try Auth.auth().signOut()
            } catch {
              print("Error signing out: \(error.localizedDescription)")
            }
          }))
          present(ac, animated: true, completion: nil)
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


 
