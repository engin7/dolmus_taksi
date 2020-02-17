//
//  TripsViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase

class TripsViewController: UITableViewController {

    static var trips: [[Trips]] = []  //array in array. Trips has many values like route, persons etc.
 
    override func viewDidLoad() {
    super.viewDidLoad()
    

    }
    
    // MARK: UITableView Delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TripsViewController.trips.count
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
       let trip = TripsViewController.trips[indexPath.row]
       
//        cell.textLabel?.text = Trips.
//       cell.detailTextLabel?.text = Trips.addedByUser
//
//       toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
       
       return cell
     }
     
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
     }
    
    
    
    // TODO:  load trip created here.
    
    
    
    
    
    // FIXME:
}
