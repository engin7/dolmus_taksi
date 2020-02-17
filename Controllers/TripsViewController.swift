//
//  TripsViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 15.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase

class TripsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var from: UILabel!
    
    @IBOutlet weak var to: UILabel!
    
    
    @IBOutlet weak var ProfileImage: UIImageView!
    
}




class TripsViewController: UITableViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
            
        tripItemsReference.observe(.value, with: {
            snapshot in
            var newItems : [Trips] = []  //create empty array
            for from in snapshot.children {
              let tripItem = Trips(snapshot: from as! DataSnapshot)
              newItems.append(tripItem)
          }
            trips = newItems
            self.tableView.reloadData()
          })
 
    }
    
    // MARK: UITableView Delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
     }
     
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "TripsCell", for: indexPath) as! TripsTableViewCell
       let trip = trips[indexPath.row]
       
        cell.from.text = trip.from
        cell.to.text = trip.to
        cell.ProfileImage = nil

       return cell
     }
     
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
     }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
    
    // TODO:  load trip created here.
    
    
    
    
    
    // FIXME:
}
