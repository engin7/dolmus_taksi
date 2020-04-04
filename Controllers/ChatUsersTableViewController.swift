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
 
       tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatUsers")
        
        self.title = "Users in the Room"
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
