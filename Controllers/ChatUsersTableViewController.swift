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
     private var referencePassengers: CollectionReference?
     private var referenceChat: CollectionReference?
     let documentId : String
     let passID = cUser?.id
     var usertobeRated: chatUser?
    var  usertobeRatedId: DocumentReference?

    
    init(trip: Trips ) {
     self.trip = trip
     documentId = trip.id!
     super.init(nibName: nil, bundle: nil)
    }

    fileprivate func updatePassengers(_ documentId: String, _ trip: Trips) {
             tripReference.document(documentId).updateData([
                 "passengers": trip.Passengers,
                 "PassID": trip.PassID
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
       
        guard let id = trip.id else {
                       navigationController?.popViewController(animated: true)
                       return
                      }
        
       referencePassengers = db.collection(["Trips", id, "passengers"].joined(separator: "/"))
       referenceChat = db.collection(["Trips", documentId, "users"].joined(separator: "/"))

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
     
                    return (trip.Passengers.count+1)
           }
       
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
            
            {
                    if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUsers", for: indexPath)
                        cell.textLabel?.text = "Travellers"
                        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
                        cell.textLabel?.textAlignment = .center
                         cell.selectionStyle = .none
                         return cell
                    } else {
            
                   let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUsers", for: indexPath)
                   let users = trip.Passengers[indexPath.row-1]
                   cell.textLabel?.text = users
                   cell.selectionStyle = .none
                   return cell
            
          }
        }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt  indexPath: IndexPath) {
     
        }
    
    func updatePassengerUserId() {
      
        let dokumanId = userId?.documentID
 
        chatUserReference.document(dokumanId!).updateData([
       "passengerUserId": cUser!.passengerUserId!
          ]) { err in
              if let err = err {
                  print("Error updating document: \(err)")
              } else {
                  print("Document successfully updated")
              }
                         }
    }

    func updateChatUserId() {
    
     let dokumanId = userId?.documentID
   
        chatUserReference.document(dokumanId!).updateData([
    "chatUserId": cUser!.chatUserId!
       ]) { err in
           if let err = err {
               print("Error updating document: \(err)")
           } else {
               print("Document successfully updated")
           }
                    
             }
      }
    
    func uptadeTobeRated(id: String) {
     
        chatUserReference.document(id).updateData([
           "ratedBy": self.usertobeRated?.ratedBy
             ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                 }
            }
    }
    
   @objc func exitRoom(sender: UIButton!) {
       // go back
     
    let indexOfUser = trip.Passengers.firstIndex(of: currentUser!.displayName)
       if indexOfUser != nil {
        let indexId = trip.PassID.firstIndex(of: passID!)
        trip.PassID.remove(at: indexId!)
        trip.Passengers.remove(at: indexOfUser!)
        updatePassengers(trip.id!, trip)
      
          for id in self.trip.PassID {
                        
                        self.usertobeRatedId = chatUserReference.document(id)
                        self.usertobeRatedId!.getDocument { (document, error) in
                             if let document = document, document.exists {
                               self.usertobeRated = chatUser(document: document)
                                self.usertobeRated?.ratedBy![cUser!.id!] = nil
        
                                self.uptadeTobeRated(id: id)
                        }
                   }
               }
        
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
    
        let id = cUser?.passengerUserId![documentId]
        referencePassengers!.document(id!).delete() { error in
        if let e = error {
          print("Error sending message: \(e.localizedDescription)")
          return
            }
          }
    
         let idChat = cUser?.chatUserId![documentId]
        referenceChat!.document(idChat!).delete() { error in
              if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
                  }
                }
        cUser?.passengerUserId![documentId] = nil
        cUser?.chatUserId![documentId] = nil
        updatePassengerUserId()
        updateChatUserId()
        
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.dismiss(animated: true, completion: nil)
       }
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationID"), object: nil)

     }

       @objc func joinRoom(sender: UIButton!) {
    
     let documentId = trip.id!

        let blurEffect = UIBlurEffect(style: .light)
         let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
         blurVisualEffectView.frame = view.bounds
        self.view.addSubview(blurVisualEffectView)

     let message = NSLocalizedString("How many passengers will join the trip?", comment: "")

        let alert = UIAlertController(title: trip.to + "  " + getReadableDate(time: trip.time)!, message: message, preferredStyle: .alert)
     let justLooking = NSLocalizedString("Cancel", comment: "")
     alert.addAction(UIAlertAction(title: justLooking, style: .default, handler: { action in
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               self.dismiss(animated: true, completion: nil)
               }
     }))
     alert.addAction(UIAlertAction(title: "1", style: .destructive, handler: { action in
         
        for id in self.trip.PassID {
            
            self.usertobeRatedId = chatUserReference.document(id)
            self.usertobeRatedId!.getDocument { (document, error) in
                         if let document = document, document.exists {
                           self.usertobeRated = chatUser(document: document)
                            self.usertobeRated?.ratedBy![cUser!.id!] = self.trip.time
    
                            self.uptadeTobeRated(id: id)
                    }
                }
            }
        
        self.trip.Passengers.append(currentUser!.displayName)
        self.trip.PassID.append(self.passID!)
        self.updatePassengers(documentId, self.trip)
        self.navigationController?.popViewController(animated: true)
        
        let passenger_doc_ref =  self.referencePassengers!.addDocument(data: cUser!.representation)
        cUser?.passengerUserId![documentId] = passenger_doc_ref.documentID
        self.updatePassengerUserId()
        
        let chat_doc_ref =  self.referenceChat!.addDocument(data: cUser!.representation)
        cUser?.chatUserId![documentId] = chat_doc_ref.documentID
        self.updateChatUserId()
        
        blurVisualEffectView.removeFromSuperview()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.dismiss(animated: true, completion: nil)
        }
        
     }))
             
        if trip.Passengers.count < 3 {
     alert.addAction(UIAlertAction(title: "2", style: .default, handler: { action in
        
        for id in self.trip.PassID {
                 
                 self.usertobeRatedId = chatUserReference.document(id)
                 self.usertobeRatedId!.getDocument { (document, error) in
                              if let document = document, document.exists {
                                self.usertobeRated = chatUser(document: document)
                                 self.usertobeRated?.ratedBy![cUser!.id!] = self.trip.time
         
                                 self.uptadeTobeRated(id: id)
                         }
                     }
                 }
        
         self.trip.Passengers.append(currentUser!.displayName)
         self.trip.Passengers.append(currentUser!.displayName + "+1")
        self.trip.PassID.append(self.passID!)

        self.updatePassengers(documentId, self.trip)
        self.navigationController?.popViewController(animated: true)

        let passenger_doc_ref =  self.referencePassengers!.addDocument(data: cUser!.representation)
        cUser?.passengerUserId![documentId] = passenger_doc_ref.documentID
        self.updatePassengerUserId()
       
        let chat_doc_ref =  self.referenceChat!.addDocument(data: cUser!.representation)
        cUser?.chatUserId![documentId] = chat_doc_ref.documentID
        self.updateChatUserId()
       
        blurVisualEffectView.removeFromSuperview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.dismiss(animated: true, completion: nil)
        }
     }))
     }
         
        if trip.Passengers.count < 2 {
     alert.addAction(UIAlertAction(title: "3", style: .default, handler: { action in
        
        for id in self.trip.PassID {
                 
                 self.usertobeRatedId = chatUserReference.document(id)
                 self.usertobeRatedId!.getDocument { (document, error) in
                      if let document = document, document.exists {
                        self.usertobeRated = chatUser(document: document)
                         self.usertobeRated?.ratedBy![cUser!.id!] = self.trip.time
 
                         self.uptadeTobeRated(id: id)
                 }
            }
        }
        
         self.trip.Passengers.append(currentUser!.displayName)
         self.trip.Passengers.append(currentUser!.displayName + "+1")
         self.trip.Passengers.append(currentUser!.displayName + "+2")
        self.trip.PassID.append(self.passID!)

        self.updatePassengers(documentId, self.trip)
        self.navigationController?.popViewController(animated: true)

        let passenger_doc_ref =  self.referencePassengers!.addDocument(data: cUser!.representation)
        cUser?.passengerUserId![documentId] = passenger_doc_ref.documentID
        self.updatePassengerUserId()
        
        let chat_doc_ref =  self.referenceChat!.addDocument(data: cUser!.representation)
        cUser?.chatUserId![documentId] = chat_doc_ref.documentID
        self.updateChatUserId()
       
        blurVisualEffectView.removeFromSuperview()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.dismiss(animated: true, completion: nil)
        }
        
     }))
        }
           self.present(alert, animated: true)
 
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return 50
      }
   
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       let footerView = UIView()
       footerView.frame = CGRect(x: 50, y: 50, width: self.view.frame.width/2, height:
       10)
        
       let button = UIButton()
       button.frame = CGRect(x: 80, y: 15, width: 40, height: 15)
       if (trip.Passengers.contains(currentUser!.displayName)) {
       button.setTitle("exit", for: .normal)
       footerView.backgroundColor = UIColor.red
 
       button.addTarget(self, action: #selector(exitRoom), for:.touchUpInside)
       } else {
       button.setTitle("join", for: .normal)
 
       footerView.backgroundColor = UIColor.blue
       button.addTarget(self, action: #selector(joinRoom), for:.touchUpInside)
       }
       footerView.addSubview(button)
       return footerView
    }
    }
    
 

