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
import MapKit
import CoreLocation
 
class TripsTableViewCell: UITableViewCell  {
  
    @IBOutlet weak var fromTextLabel: UILabel!
        
    @IBOutlet weak var toTextLabel: UILabel!
    
    @IBOutlet weak var timeTextLabel: UILabel!
    
    @IBOutlet weak var fromCityTextLabel: UILabel!
    
    @IBOutlet weak var toCityTextLabel: UILabel!
    
    
    @IBOutlet weak var PersonImage0: UIImageView!
    
    @IBOutlet weak var PersonImage1: UIImageView!
    
    @IBOutlet weak var PersonImage2: UIImageView!
    
    @IBOutlet weak var PersonImage3: UIImageView!
    
 
 }

    class TripsTableViewController: UITableViewController {

 
        @IBAction func chatButtton(_ sender: Any) {
   
             
        }

        private let TripsCellIdentifier = "TripsCell"
        private var currentTripsAlertController: UIAlertController?
       
        var tripListener: ListenerRegistration?
        var trips : [Trips] = []
        var availableTrips : [Trips] = []
        var myTrips : [Trips] = []
        let today = Date()
        var userLocation: CLLocation?
        private var locationManager: CLLocationManager?
        private let imageView = UIImageView()

        deinit {
          tripListener?.remove()
        }
              
      override func viewDidLoad() {
        super.viewDidLoad()        
        overrideUserInterfaceStyle = .light
      
        // warning for disabled user accounts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {

        if currentUser == nil  {

           let alert = UIAlertController(title: "Your account has been disabled", message: "As you violated our terms of use, we permenantly restricted your account to access our services. ", preferredStyle: .alert)
          
           alert.addAction(UIAlertAction(title: "acknowledged", style: .default, handler: { action in
               exit(0);
           }))
           self.present(alert, animated: true, completion: nil)

            } }
         
         self.imageView.image = #imageLiteral(resourceName: "chat")
         self.imageView.contentMode = .scaleAspectFill
         self.imageView.alpha = 0.3
         self.imageView.clipsToBounds = true
         self.view.addSubview(imageView)
    
         locationManager = CLLocationManager()
         locationManager?.delegate = self
         locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
         locationManager?.requestWhenInUseAuthorization()
         locationManager?.requestLocation()
          
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
                
                if (Auth.auth().currentUser?.uid) != nil {

                switch change.type {
     
                 case .added:
                
                       if  !trip.Passengers.contains(currentUser!.displayName) && trip.time.timeIntervalSinceNow > 0 {
                              
                        self.availableTrips.append(trip)
         
                       } else if trip.Passengers.contains(currentUser!.displayName) && trip.time.timeIntervalSinceNow > 0 {
                        self.myTrips.append(trip)
                       }
                                    
                        else {
                         self.trips.append(trip)
                        }
                    
                 case .modified:
                    guard let index = self.trips.firstIndex(of: trip)    else {
                      return
                    }
                    self.trips[index] = trip
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    
                case .removed:
                    guard let index =  self.trips.firstIndex(of: trip) else {
                      return
                    }
                    self.trips.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }
                }
            }
              
            self.availableTrips.sort(by: {$0.time < $1.time})

            if self.userLocation != nil {
              self.availableTrips.sort(by: {(abs($0.fromLocation[0] - (self.userLocation?.coordinate.latitude)!),abs($0.fromLocation[1] - (self.userLocation?.coordinate.longitude)!)) < (abs($1.fromLocation[0] - (self.userLocation?.coordinate.latitude)!),abs($1.fromLocation[1] - (self.userLocation?.coordinate.longitude)!)) })
             }
            
                 self.trips.insert(contentsOf: self.availableTrips, at: 0)
                 self.availableTrips = []
                  
                 self.trips.insert(contentsOf: self.myTrips, at: 0)
                 self.myTrips = []
            
                  self.tableView.reloadData()
                  self.deletePastChannels()
         }
      }
        override func viewDidLayoutSubviews() {
              // for different screen size
              super.viewDidLayoutSubviews()
               self.imageView.frame = self.view.bounds
           }
        
        func deletePastChannels() {
        // will lower time to 2 hours when reach many active users, chat messages stays in database, i'll delete them manually after checking if there is any reports in the chat rooms.
               let past = Calendar.current.date(byAdding: .hour, value: -12, to: today)
                
               for Trips in trips {
                   
                if Trips.time < past! || Trips.Passengers.count == 0 {
                      
                     let documentId = Trips.id
                    tripReference.document(documentId!).delete() { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("File deleted successfully")
                    }
                        
                    }
               }
        }
        }
        
        // MARK: UITableView Delegate methods

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return  self.trips.count
         }
         
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsTableViewCell", for: indexPath) as! TripsTableViewCell
            let trip =  self.trips[indexPath.row]
    
            cell.fromTextLabel.text =  trip.from
            cell.toTextLabel.text = trip.to
            cell.toCityTextLabel.text = trip.toCity
            cell.fromCityTextLabel.text = trip.fromCity
            let time = getReadableDate(time: trip.time)
            cell.timeTextLabel.text = time
            
            cell.fromTextLabel.textColor = UIColor.black
            cell.toTextLabel.textColor = UIColor.black
            cell.timeTextLabel.textColor = UIColor.black
            cell.fromCityTextLabel.textColor = UIColor.black
            cell.toCityTextLabel.textColor = UIColor.black

            let past = Calendar.current.date(byAdding: .minute, value: -15, to: today)

           
            
            switch trip.Passengers.count {
                
            case 1:
                cell.PersonImage1.isHidden = true
                cell.PersonImage2.isHidden = true
                cell.PersonImage3.isHidden = true
                cell.contentView.alpha = 0.8
                

            case 2:
                cell.PersonImage3.isHidden = true
                cell.PersonImage2.isHidden = true
                cell.PersonImage1.isHidden = false
                cell.contentView.alpha = 0.8
               
            case 3:
                cell.PersonImage3.isHidden = true
                cell.PersonImage2.isHidden = false
                cell.PersonImage1.isHidden = false
                cell.contentView.alpha = 0.8
                

            case 4:
                cell.contentView.alpha = 0.4
                cell.PersonImage3.isHidden = false
                cell.PersonImage2.isHidden = false
                cell.PersonImage1.isHidden = false
 
                
            default:
               break
            }
          
            if trip.time < past! {
            cell.contentView.alpha = 0.2
            cell.selectionStyle = .none
           }
            
            if trip.Passengers.contains(currentUser!.displayName) {
             cell.alpha = 0
             cell.backgroundColor = UIColor.lightGray
             UIView.animate(withDuration: 2.0, animations: {
              cell.alpha = 1.0
              cell.fromTextLabel.textColor = UIColor.red
              cell.toTextLabel.textColor = UIColor.red
              cell.timeTextLabel.textColor = UIColor.red
              cell.fromCityTextLabel.textColor = UIColor.red
              cell.toCityTextLabel.textColor = UIColor.red
              cell.backgroundColor = UIColor.white
            })
                 
          }
          
              return cell
            
          }
       
        
         override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
             }
     
//        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//            if editingStyle == .delete   {
//                let trip =  self.trips[indexPath.row]
//                let documentId = trip.id
//
//                tripReference.document(documentId).delete() { error in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    print("File deleted successfully")
//                }
//            }
//          }
//        }
                
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
           
            var trip =  self.trips[indexPath.row]
            let documentId = trip.id //? get new host id calculate in advance to prevent entering it crashing now.. host = nil 
            let past = Calendar.current.date(byAdding: .minute, value: -15, to: today)
           
            let  hostID = chatUserReference.document(trip.hostID)
 
               hostID.getDocument { (document, error) in
                if let document = document, document.exists {
                  host = chatUser(document: document)!
                } }
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
             if ((trip.Passengers.count < 4 &&  trip.time > past!) || trip.Passengers.contains(currentUser!.displayName))
//                && ((host?.blocked!.contains(currentUser!.uid))!)
            {
              
             if !(trip.Passengers.contains(currentUser!.displayName))  {
   
            let alert = UIAlertController(title: trip.to + "  " + getReadableDate(time: trip.time)!, message: "How many passengers will join the trip?", preferredStyle: .alert)
       
            alert.addAction(UIAlertAction(title: "None, I'm just looking.", style: .default, handler: { action in
                let vc = ChatViewController(currentUser: currentUser!, trip: trip)
                self.navigationController?.pushViewController(vc, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "1", style: .destructive, handler: { action in
                trip.Passengers.append(currentUser!.displayName)
                self.updatePassengers(documentId!, trip)
                let vc = ChatViewController(currentUser: currentUser!, trip: trip)

                self.navigationController?.pushViewController(vc, animated: true)

            }))
                    
            if trip.Passengers.count < 3 {
            alert.addAction(UIAlertAction(title: "2", style: .default, handler: { action in
                trip.Passengers.append(currentUser!.displayName)
                trip.Passengers.append(currentUser!.displayName + "+1")
                self.updatePassengers(documentId!, trip)
                let vc = ChatViewController(currentUser: currentUser!, trip: trip)

                self.navigationController?.pushViewController(vc, animated: true)

            }))
            }
                
            if trip.Passengers.count < 2 {
            alert.addAction(UIAlertAction(title: "3", style: .default, handler: { action in
                trip.Passengers.append(currentUser!.displayName)
                trip.Passengers.append(currentUser!.displayName + "+1")
                trip.Passengers.append(currentUser!.displayName + "+2")
                self.updatePassengers(documentId!, trip)
                let vc = ChatViewController(currentUser: currentUser!, trip: trip)

                self.navigationController?.pushViewController(vc, animated: true)
            }))
            }
            self.present(alert, animated: true)
           }
            }  }
                
            if trip.Passengers.contains(currentUser!.displayName) {
                self.updatePassengers(documentId!, trip)
                let vc = ChatViewController(currentUser: currentUser!, trip: trip)

                self.navigationController?.pushViewController(vc, animated: true)

            }
      
        
                func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        }
    }
  }

extension TripsTableViewController : CLLocationManagerDelegate {
     
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager!.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //  will zoom to the first location
        if let location = locations.first {
              userLocation = location
                  }
            }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           
           print(error.localizedDescription)
       }
}
 
 
