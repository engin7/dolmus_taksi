//
//  ChatUsersTableViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 3.04.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatUsersTableViewController: UITableViewController {

     private var trip: Trips
 
    init(trip: Trips ) {
     self.trip = trip
      super.init(nibName: nil, bundle: nil)

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
                 self.tableView.reloadData()
         }
    
    override func viewDidLoad()
    {
       overrideUserInterfaceStyle = .light
       
       tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatUsers")
        
        let p = NSLocalizedString("Passengers ", comment: "")

        self.title = p
        let leave = NSLocalizedString("leave trip", comment: "")

        if (trip.Passengers.contains(currentUser!.displayName)) {
        let exit  = UIBarButtonItem(title: leave, style: .plain, target: self, action: #selector(exitRoom))
        
        navigationItem.rightBarButtonItems = [exit]
        }
        
        let join = NSLocalizedString("join trip", comment: "")
        if !(trip.Passengers.contains(currentUser!.displayName)) {
        let join  = UIBarButtonItem(title: join, style: .plain, target: self, action: #selector(joinRoom))
        
        navigationItem.rightBarButtonItems = [join]
        }
    }
      
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
       }
       
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (trip.Passengers.count)
       }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUsers", for: indexPath)
        let users = trip.Passengers[indexPath.row]
        cell.textLabel?.text = users
        cell.selectionStyle = .none

        return cell
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt  indexPath: IndexPath) {
     
        }

   @objc func exitRoom(sender: UIButton!) {
       // go back
    
       let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      
   self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2],   animated: true)
        
        viewControllers[viewControllers.count - 2].navigationItem.rightBarButtonItem!.isEnabled = false
    }
    
    let indexOfUser = trip.Passengers.firstIndex(of: currentUser!.displayName)
       if indexOfUser != nil {
        trip.Passengers.remove(at: indexOfUser!)
        updatePassengers(trip.id!, trip)
 
              }
    let indexOfUser1 = trip.Passengers.firstIndex(of: currentUser!.displayName + "+1")
       if indexOfUser1 != nil {
        trip.Passengers.remove(at: indexOfUser1!)
        updatePassengers(trip.id!, trip)
 
       }
    let indexOfUser2 = trip.Passengers.firstIndex(of: currentUser!.displayName + "+2")
       if indexOfUser2 != nil {
        trip.Passengers.remove(at: indexOfUser2!)
        updatePassengers(trip.id!, trip)
 
       }

     }

       @objc func joinRoom(sender: UIButton!) {
    
     let documentId = trip.id!

     let message = NSLocalizedString("How many passengers will join the trip?", comment: "")

        let alert = UIAlertController(title: trip.to + "  " + getReadableDate(time: trip.time)!, message: message, preferredStyle: .alert)
     let justLooking = NSLocalizedString("Cancel", comment: "")
     alert.addAction(UIAlertAction(title: justLooking, style: .default, handler: { action in
        self.navigationController?.popViewController(animated: true)
     }))
     alert.addAction(UIAlertAction(title: "1", style: .destructive, handler: { action in
         self.trip.Passengers.append(currentUser!.displayName)
        self.updatePassengers(documentId, self.trip)
       self.navigationController?.popViewController(animated: true)
     }))
             
        if trip.Passengers.count < 3 {
     alert.addAction(UIAlertAction(title: "2", style: .default, handler: { action in
         self.trip.Passengers.append(currentUser!.displayName)
         self.trip.Passengers.append(currentUser!.displayName + "+1")
        self.updatePassengers(documentId, self.trip)
        self.navigationController?.popViewController(animated: true)
     }))
     }
         
        if trip.Passengers.count < 2 {
     alert.addAction(UIAlertAction(title: "3", style: .default, handler: { action in
         self.trip.Passengers.append(currentUser!.displayName)
         self.trip.Passengers.append(currentUser!.displayName + "+1")
         self.trip.Passengers.append(currentUser!.displayName + "+2")
        self.updatePassengers(documentId, self.trip)
        self.navigationController?.popViewController(animated: true)
     }))
     }
     self.present(alert, animated: true)
    }
      }
    
 
