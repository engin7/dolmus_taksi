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
   
        
        @IBAction func shareButtonClicked(_ sender: Any) {
            
      
             //Set the link to share.
            if let link = NSURL(string: "https://apps.apple.com/app/id1509680367")
            {
                let objectsToShare = [link] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
            }
            
        }
        
        
        let vc = GeneralChatViewController()

        @IBAction func onlineButtton(_ sender: Any?) {
            // present modally
            
             vc.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            vc.modalTransitionStyle = .coverVertical

             self.navigationController?.present(vc, animated: true, completion: nil)

        }
       
        @IBOutlet weak var userCountBarButtonItem: UIBarButtonItem!
    
        
        private let TripsCellIdentifier = "TripsCell"
        private var currentTripsAlertController: UIAlertController?
       
        var tripListener: ListenerRegistration?
 
        
        let today = Date()
        private let imageView = UIImageView()
        deinit {
          tripListener?.remove()
        }
      
      override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "guide") as! GuideViewController

        self.addChild(popvc)
 
        popvc.view.frame = self.view.frame

        self.view.addSubview(popvc.view)

        popvc.didMove(toParent: self)
         
        
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
                
                       if  !trip.Passengers.contains(currentUser!.displayName)  {
                              
                         availableTrips.append(trip)
         
                       } else if trip.Passengers.contains(currentUser!.displayName)
                       {
                         myTrips.append(trip)
                       }
                                    
                        else {
                          trips.append(trip)
                        }
                    
                 case .modified:
                    guard let index =  trips.firstIndex(of: trip)    else {
                      return
                    }
                    trips[index] = trip
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    
                case .removed:
                    guard let index =   trips.firstIndex(of: trip) else {
                      return
                    }
                    trips.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }
                    
                 }
                
                sorting { (success)  in
                       guard success != nil else {print("Failed to sort."); return}
                  
                                  self.tableView.reloadData()
                        }
                }
                }
        
                usersRef.observe(.value, with: { snapshot in
              if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
              } else {
                self.userCountBarButtonItem?.title = "0"
              }
            })
         
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldReload), name: NSNotification.Name(rawValue: "newDataNotificationForItemEdit"), object: nil)
      }
        
        override func viewDidLayoutSubviews() {
              // for different screen size
              super.viewDidLayoutSubviews()
               self.imageView.frame = self.view.bounds
           }
      
        @objc func shouldReload() {
            self.tableView.reloadData()
        }
        
         
        // MARK: UITableView Delegate methods

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return   trips.count
         }
         
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsTableViewCell", for: indexPath) as! TripsTableViewCell
            let trip = trips[indexPath.row]
    
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
            imageView.backgroundColor = UIColor(red: 189/255, green: 185/255, blue: 189/255, alpha: 1.0)

            imageView.layer.cornerRadius = 25
            imageView.clipsToBounds = true

            imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

            let past = Calendar.current.date(byAdding: .minute, value: -15, to: today)
 
              cell.backgroundView = UIView()
              cell.backgroundView!.addSubview(imageView)
          
            if trip.time < past! {
                cell.selectionStyle = .none
                  cell.contentView.alpha = 0.25
                cell.backgroundView?.removeFromSuperview()
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
           
            let trip =  trips[indexPath.row]
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


