//
//  ChatUsersTableViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 3.04.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import UIKit

class ChatUsersTableViewController: UITableViewController {

     private var trip: Trips?
 
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
        
        self.title = "Passengers "
        
        if (trip?.Passengers.contains(currentUser!.displayName))! {
        let exit  = UIBarButtonItem(title: "leave trip", style: .plain, target: self, action: #selector(exitRoom))
        
        navigationItem.rightBarButtonItems = [exit]
        }
    }
      

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
       }
       
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (trip?.Passengers.count)!
       }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUsers", for: indexPath)
        let users = trip?.Passengers[indexPath.row]
        cell.textLabel?.text = users
        
        return cell
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt  indexPath: IndexPath) {
     
        }

   @objc func exitRoom(sender: UIButton!) {
       // go back
    
        
    
       let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
       self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2],   animated: true)
    
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      
        viewControllers[viewControllers.count - 2].dismiss(animated: true, completion: nil)

    }
    
       let indexOfUser = trip?.Passengers.firstIndex(of: currentUser!.displayName)
       if indexOfUser != nil {
                  trip?.Passengers.remove(at: indexOfUser!)
           updatePassengers(trip!.id, trip!)
 
              }
       let indexOfUser1 = trip?.Passengers.firstIndex(of: currentUser!.displayName + "+1")
       if indexOfUser1 != nil {
           trip?.Passengers.remove(at: indexOfUser1!)
           updatePassengers(trip!.id, trip!)
 
       }
       let indexOfUser2 = trip?.Passengers.firstIndex(of: currentUser!.displayName + "+2")
       if indexOfUser2 != nil {
           trip?.Passengers.remove(at: indexOfUser2!)
           updatePassengers(trip!.id, trip!)
 
       }

     }

}
