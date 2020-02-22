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

class TripsTableViewCell: UITableViewCell  {
  

    @IBOutlet weak var fromTextLabel: UILabel!
        
    @IBOutlet weak var toTextLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
 }


class TripsTableViewController: UITableViewController {

    var trips : [Trips] = []
    private let TripsCellIdentifier = "TripsCell"
    private var currentTripsAlertController: UIAlertController?
    
    private let db = Firestore.firestore()
    private var tripReference: CollectionReference {
    return db.collection("Trips")
    }
    
    private var Trip = [Trips]()
    private var tripListener: ListenerRegistration?
 
    deinit {
      tripListener?.remove()
    }
     
//      init(currentUser: User) {
//      self.currentUser = currentUser
//      super.init(style: .grouped)
//      title = "Trips"
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//    }
   
  override func viewDidLoad() {
    super.viewDidLoad()
 
    tripListener = tripReference.addSnapshotListener { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
        return
      }
      
      snapshot.documentChanges.forEach { change in
        self.handleDocumentChange(change)
      }
    }

    
     }
    
   
    
    // MARK: - Actions
    
    @objc private func signOut() {
      let ac = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
        do {
          try Auth.auth().signOut()
        } catch {
          print("Error signing out: \(error.localizedDescription)")
        }
      }))
      present(ac, animated: true, completion: nil)
    }
    
    @objc private func addButtonPressed() {
      let ac = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      ac.addTextField { field in
        field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        field.enablesReturnKeyAutomatically = true
        field.autocapitalizationType = .words
        field.clearButtonMode = .whileEditing
        field.placeholder = "Channel name"
        field.returnKeyType = .done
        field.tintColor = .primary
      }
      
      let createAction = UIAlertAction(title: "Create", style: .default, handler: { _ in
        self.createChannel()
      })
      createAction.isEnabled = false
      ac.addAction(createAction)
      ac.preferredAction = createAction
      
      present(ac, animated: true) {
        ac.textFields?.first?.becomeFirstResponder()
      }
      currentTripsAlertController = ac
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
      guard let ac = currentTripsAlertController else {
        return
      }
      
      ac.preferredAction?.isEnabled = field.hasText
    }
    
    // MARK: - Helpers
    
      func createChannel() {
      guard let ac = currentTripsAlertController else {
        return
      }
      
      guard let channelName = ac.textFields?.first?.text else {
        return
      }
      
      let trip = Trips(time: Date(), to: channelName, from: "rr", persons:
        3)
      tripReference.addDocument(data: trip.representation) { error in
        if let e = error {
          print("Error saving channel: \(e.localizedDescription)")
        }
      }
    }
    
    private func addChannelToTable(_ channel: Trips) {
      guard !trips.contains(channel) else {
        return
      }
      
      trips.append(channel)
      trips.sort()
      
      guard let index = trips.firstIndex(of: channel) else {
      return
      }
      tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
     
    private func updateChannelInTable(_ channel: Trips) {
        guard let index = trips.firstIndex(of: channel) else {
        return
      }
      
      trips[index] = channel
      tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func removeChannelFromTable(_ channel: Trips) {
        guard let index = trips.firstIndex(of: channel) else {
        return
      }
      
      trips.remove(at: index)
      tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
      guard let channel = Trips(document: change.document) else {
        return
      }
      
      switch change.type {
      case .added:
        addChannelToTable(channel)
        
      case .modified:
        updateChannelInTable(channel)
        
      case .removed:
        removeChannelFromTable(channel)
      }
    }
    
    
    // MARK: UITableView Delegate methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
     }
     
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

                 let cell = tableView.dequeueReusableCell(withIdentifier: "TripsTableViewCell", for: indexPath) as! TripsTableViewCell
                let trip = trips[indexPath.row]
                 
        cell.fromTextLabel.text = trip.from
        cell.toTextLabel.text = trip.to

         return cell
      }
   
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
     }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        
        let selectedTrip = trips[indexPath.row]
        let vc = ChatViewController(currentUser: currentUser!, trip: selectedTrip)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
  
}


 
