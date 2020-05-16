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
  
        @IBAction func onlineButtton(_ sender: Any) {
            // present modally
            let vc = GeneralChatViewController()
             vc.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            vc.modalTransitionStyle = .coverVertical

             self.navigationController?.present(vc, animated: true, completion: nil)

        }
       
        @IBOutlet weak var userCountBarButtonItem: UIBarButtonItem!
    
        
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
        
            usersRef.observe(.value, with: { snapshot in
              if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
              } else {
                self.userCountBarButtonItem?.title = "0"
              }
            })
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
 
                if Trips.time < past! ||   Trips.Passengers.count == 0 {
                      
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
         
            if trip.Passengers.contains(currentUser!.displayName) {
             cell.alpha = 0
              UIView.animate(withDuration: 2.0, animations: {
                cell.contentView.alpha = 0.8
              cell.fromTextLabel.textColor = UIColor.red
              cell.toTextLabel.textColor = UIColor.red
              cell.timeTextLabel.textColor = UIColor.red
              cell.fromCityTextLabel.textColor = UIColor.red
              cell.toCityTextLabel.textColor = UIColor.red
             })
                 
          }
          
            let imageView = UIImageView(frame: CGRect(x: 2, y: 5, width: cell.frame.width + 40, height: cell.frame.height - 15))
              let image = UIImage(named: "Image Name")

            imageView.image = image
            imageView.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.35)

            imageView.layer.cornerRadius = 25
            imageView.clipsToBounds = true

            imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

            let past = Calendar.current.date(byAdding: .minute, value: -15, to: today)

             if trip.time < past! {
             imageView.backgroundColor = .lightGray
             cell.selectionStyle = .none
                cell.contentView.alpha = 0.8

            }
            
              cell.backgroundView = UIView()
              cell.backgroundView!.addSubview(imageView)
          
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
           
            let trip =  self.trips[indexPath.row]
            let documentId = trip.id

            let past = Calendar.current.date(byAdding: .minute, value: -15, to: today)
         
            if ((trip.Passengers.count < 5  &&  trip.time > past!) && !trip.Passengers.contains(currentUser!.displayName) && CLLocationManager.authorizationStatus() == .authorizedWhenInUse && !cUser!.blocked.contains(trip.host))
              
              {
                
               let vc = ChatViewController(currentUser: currentUser!, trip: trip)

               self.navigationController?.pushViewController(vc, animated: true)
                   
              }
    
               if   cUser!.blocked.contains(trip.host) {

                     let title = NSLocalizedString("You have been blocked", comment: "")
                        let message = NSLocalizedString("Creator of this trip channel decided to ban you. Make sure that your notification settings is on as some hosts may decide to ban travellers not responding. If you believe there is a mistake or host abused its power please report to Count Dracula", comment: "")
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

                       alert.addAction(UIAlertAction(title: "acknowledged", style: .default, handler: nil))
                
                   if let selectedIndexPath = tableView.indexPathForSelectedRow {
                          tableView.deselectRow(at: selectedIndexPath, animated: false)
                       }
                          self.present(alert, animated: true, completion: nil)
                     }
                 
               if trip.Passengers.contains(currentUser!.displayName) && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                   self.updatePassengers(documentId!, trip)
                   let vc = ChatViewController(currentUser: currentUser!, trip: trip)

                   self.navigationController?.pushViewController(vc, animated: true)
               }
       
            if CLLocationManager.authorizationStatus() == .denied {
                
                let title = NSLocalizedString("Location services denied", comment: "")
                let message = NSLocalizedString("You need to allow our app to use your location when in use to access our services. Please go to Settings > Privacy > Location Services. Tap our app icon and change your settings.", comment: "")
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        
                         alert.addAction(UIAlertAction(title: "acknowledged", style: .default, handler: nil))
                         self.present(alert, animated: true, completion: nil)
 
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
 
 
