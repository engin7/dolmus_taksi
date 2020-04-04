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
    
     init(trip: Trips) {
     self.trip = trip
     super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad()
    {
       overrideUserInterfaceStyle = .light

       tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatUsers")
        
        self.title = "Passengers "
        
        let exit  = UIBarButtonItem(title: "exit", style: .plain, target: self, action: #selector(exitRoom))
        
        navigationItem.rightBarButtonItems = [exit]
 
    }
      
    @objc func exitRoom(sender: UIButton!) {
        // go back 2 screens
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        
        let indexOfUser = trip?.Passengers.firstIndex(of: currentUser!.displayName)
        if indexOfUser != nil {
                   trip?.Passengers.remove(at: indexOfUser!)
               }
        let indexOfUser1 = trip?.Passengers.firstIndex(of: currentUser!.displayName + "+1")
        if indexOfUser1 != nil {
            trip?.Passengers.remove(at: indexOfUser1!)
        }
        let indexOfUser2 = trip?.Passengers.firstIndex(of: currentUser!.displayName + "+2")
        if indexOfUser2 != nil {
            trip?.Passengers.remove(at: indexOfUser2!)
        }
        
        TripsTableViewController().updatePassengers(trip!.id, trip!)
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

    }
