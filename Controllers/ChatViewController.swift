//
//  SecondViewController.swift
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

// TODO: Notifications via firebase
// TODO: Terminal messages red color
// TODO: kick leave etc commands. 

  class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate {
     
     private var messages: [Message] = []
     private var messageListener: ListenerRegistration?
     private var userListener: ListenerRegistration?
     private let currentUser: User
     private let terminal: User
     private var reference: CollectionReference?
    private var docRef: DocumentReference?
     private var referenceUsers: CollectionReference?
     private var trip: Trips?
     let paragraph = NSMutableParagraphStyle()
     private var chatRoomUsers: [String] = []
     var documentId: DocumentReference?
     private var tripListener: ListenerRegistration?

     deinit {
         messageListener?.remove()
      }
    
    init(currentUser: User, trip: Trips) {
      self.currentUser = currentUser
      self.terminal = User()
      self.trip = trip
      super.init(nibName: nil, bundle: nil)
        title =  "#" + String(trip.from.first!) + String(trip.to.first!) + getReadableDate(time: trip.time)!
    }
 
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         overrideUserInterfaceStyle = .light

        guard let id = trip?.id else {
                navigationController?.popViewController(animated: true)
                return
               }
        
        //   new collection inside Trips
        reference = db.collection(["Trips", id, "thread"].joined(separator: "/"))
        
        referenceUsers = db.collection(["Trips", id, "users"].joined(separator: "/"))
 
        docRef = db.collection("Trips").document(id)
        
    // Firestore calls this snapshot listener whenever there is a change to the database.
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
          
          guard let snapshot = querySnapshot else {
            print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
            return
          }
 
            snapshot.documentChanges.forEach { change in
            self.handleDocumentChange(change)
          }

        }

         userListener = referenceUsers?.addSnapshotListener { querySnapshot, error in
  
                 guard let snapshot = querySnapshot else {
                   print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                   return
                 }
             
            snapshot.documentChanges.forEach { change in
              self.handleUserChange(change)
                
            }
      }
  
       let chatUsers = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showUsers))

         navigationItem.rightBarButtonItems = [chatUsers]
         
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
           layout.setMessageIncomingAvatarSize(.zero)
           layout.setMessageOutgoingAvatarSize(.zero)
           layout.sectionInset = UIEdgeInsets(top: -15, left: -4, bottom: -5, right: -4)

         }
        navigationItem.largeTitleDisplayMode = .never

        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
        
        // implement 4 protocols:
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        self.messagesCollectionView.scrollToBottom(animated: true)
        
        if !self.trip!.welcomed  {
                 self.terminalWelcome()
                 self.trip!.welcomed = true
                 documentId = docRef
                 self.updateWelcome(self.documentId!.documentID, self.trip!)

                }

            terminalAdd()
       }
       
    fileprivate func updateWelcome(_ documentId: String, _ trip: Trips) {
            tripReference.document(documentId).updateData([
                "welcomed": trip.welcomed
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            let id = self.documentId?.documentID

        if self.isMovingFromParent {
            terminalRemove(id!)        }
         
    }
    
    
     func terminalWelcome() {
                        
           // TODO:  ASCIIart will be added in next version
            
    //                / _---------_ \
    //               / /           \ \
    //               | |           | |
    //               |_|___________|_|
    //           /-\|                 |/-\
    //          | _ |\       0       /| _ |
    //          |(_)| \      !      / |(_)|
    //          |___|__\_____!_____/__|___|
    //          [_______|#AS13:45|________]
    //           ||||    ~~~~~~~~     ||||
    //           `--'                 `--'
    // channel name in plate ^  will use smaller car design
                
                let messageW = Message(user: terminal, content:   " Welcome to #"  + String(trip!.from.first!) + String(trip!.to.first!) + getReadableDate(time: trip!.time)! + "\nThis channel is created to gather people travelling in similar directions. \nYou will arrange possible routes, meeting point and sharing taxi costs yourself. It's possible that another user can offer ride with his/her vehicle.  \n All users are anonymous and have auto-generated nick name. Trip channel will be deleted after the trip. \nPlease be respectful and polite.   You can report a user by command: \n/report nickName \nIf you violate our Terms of Use your account will be suspended from our services. "     )
                       
                 save(messageW)
               
           }
    
    
    func terminalAdd() {
        
        let user = chatUser(nickName: currentUser.displayName, passenger: true)
           if !chatRoomUsers.contains(currentUser.displayName){
           addUser(user)
              
            let messageT = Message(user: terminal, content: " \(currentUser.displayName)  has joined   #"  + String(trip!.from.first!) + String(trip!.to.first!) + getReadableDate(time: trip!.time)!)
            
                save(messageT)
 
           }
         
    }
    
    func terminalRemove(_ id: String) {
        
        let user = chatUser(nickName: currentUser.displayName, passenger: true)
         
         removeUser(user)
              
            let messageT = Message(user: terminal, content: " \(currentUser.displayName)  has left   #"  + String(trip!.from.first!) + String(trip!.to.first!) + getReadableDate(time: trip!.time)!)
                save(messageT)
   
    }
    
   
    @objc func showUsers(sender: UIButton!) {
           
      
        docRef!.getDocument { (document, error) in
            if let trip0 = Trips(document: document!) {
                self.trip = trip0
            }  else {
                print("Document does not exist")
           
            }
            

            let vcl = ChatUsersTableViewController(trip: self.trip!)
            
            self.navigationController?.pushViewController(vcl, animated: true)
               
            
        }
          
       }
    
    // MARK: - Helpers

    private func addUser(_ user: chatUser) {
        self.documentId = referenceUsers?.addDocument(data: user.representation) { error in
        if let e = error {
          print("Error sending message: \(e.localizedDescription)")
          return
            }

           }
      }
    
    
    private func removeUser(_ user: chatUser) {
        let id = (documentId?.documentID)!
        referenceUsers?.document(id).delete()   { error in
        if let e = error {
          print("Error sending message: \(e.localizedDescription)")
          return
            }
          }
    }
    
    
 
   private func save(_ message: Message) {
       reference?.addDocument(data: message.representation) { error in
       if let e = error {
         print("Error sending message: \(e.localizedDescription)")
         return
       }
        self.messagesCollectionView.scrollToBottom()
     }
   }
    
    private func insertNewMessage(_ message: Message) {
      guard !messages.contains(message) else {
        return
      }
      
      messages.append(message)
      messages.sort()
         
      let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
      let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
      
       messagesCollectionView.reloadData()

      if shouldScrollToBottom {
        DispatchQueue.main.async {
          self.messagesCollectionView.scrollToBottom(animated: true)
        }
      }
    }
    
    // observe new data change
    private func handleDocumentChange(_ change: DocumentChange) {
      guard let message = Message(document: change.document) else {
         
        return
      }
       switch change.type {
      case .added:
      insertNewMessage(message)
      default:
      break
      }
    }

    private func handleUserChange(_ change: DocumentChange) {
      
        switch change.type {
        case .added:
        
        chatRoomUsers.append(currentUser.displayName)
  
          
        case .removed:
        
        let index = chatRoomUsers.firstIndex(of: currentUser.displayName)!
        chatRoomUsers.remove(at: index)
 
        default:
        break
        }
      }


// MARK: - MessagesDataSource

  // initializa sender
 
  func currentSender() -> SenderType {
    return Sender(senderId: currentUser.uid, displayName: currentUser.displayName)
  }
    
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       return messages.count
  }

  // return the message for the given indexpath
  func messageForItem(at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageType {
    return messages[indexPath.section]
  }
 
// MARK: - MessagesLayoutDelegate
 
  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {
   
    return CGSize(width: 0, height: 2)
  }

  func heightForLocation(message: MessageType, at indexPath: IndexPath,
    with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //hide location
    return 0
  }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 14
    }
 
 }

extension ChatViewController: MessagesDisplayDelegate {
  
    func isFromCurrentSender(message: MessageType) -> Bool {
        false
    }
    
     private func customIsFromCurrentSender(message: MessageType) -> Bool {
         return message.sender.senderId == currentSender().senderId
     }
   
  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> Bool {
    // remove header
    return false
   }
   
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if message.sender.senderId ==  terminal.displayName {
            return .blue
        }
        
        return customIsFromCurrentSender(message: message) ? .gray : .black
    }
     
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // change color according to  sender
      return isFromCurrentSender(message: message) ? .white : .white
    }
     
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
 
      return .none
    }
        
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
      avatarView.isHidden = true
    }
}

// MARK: - MessageInputBarDelegate
 
extension ChatViewController: MessageInputBarDelegate {
   
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    
    let message = Message(user: currentUser, content: "<"+(currentUser.displayName)+"> " + text)
    save(message)
    inputBar.inputTextView.text = ""
    
    
  }
  
}
