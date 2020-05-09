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
import UserNotifications


// TODO: Notifications via firebase
// TODO: Terminal messages red color
// TODO: kick leave etc commands. 

  class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate {
     
     private var messages: [Message] = []
     private var messageListener: ListenerRegistration?
     private var userListener: ListenerRegistration?
     private var currentUser: User
     private let terminal: User
     private var reference: CollectionReference?
     private var docRef: DocumentReference?
     private var referenceUsers: CollectionReference?
     private var trip: Trips?
     let paragraph = NSMutableParagraphStyle()
     private var chatRoomUsers: [chatUser] = []
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
      title =  "Destination:" + String(trip.to)
    }
 
  
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
         overrideUserInterfaceStyle = .light
        if   host!.blocked.contains(currentUser.uid) {
                navigationController?.popViewController(animated: true)

        let title = NSLocalizedString("You have been blocked", comment: "")
           let message = NSLocalizedString("Creator of this trip channel decided to ban you. Make sure that your notification settings is on as some hosts may decide to ban travellers not responding. If you believe there is a mistake or host abused its power please report to Count Dracula", comment: "")
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "acknowledged", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

        }

         let w = NSLocalizedString("Welcome!", comment: "")
             
             let m = NSLocalizedString(" You will arrange possible routes, meeting point and sharing taxi costs yourself. When you're sure please click button on the right top then join. Trip creators can ban a user by command: \n/b nickname\nYou can report a user by command: \n/r nickName ", comment: "")

             let messageW =  w + m
                    
         let alert = UIAlertController(title: trip!.from + "\n⇣\n" + trip!.to + " @" + getReadableDate(time: trip!.time)!, message: messageW, preferredStyle: .alert)
          let acknowledged = NSLocalizedString("acknowledged", comment: "")
          alert.addAction(UIAlertAction(title: acknowledged, style: .default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        
        guard let id = trip?.id else {
                navigationController?.popViewController(animated: true)
                return
               }
        
        //   new collection inside Trips
        reference = db.collection(["Trips", id, "thread"].joined(separator: "/"))
        
        referenceUsers = db.collection(["Trips", id, "users"].joined(separator: "/"))
 
        docRef = db.collection("Trips").document(id)
        
          userListener = referenceUsers?.addSnapshotListener { querySnapshot, error in
        
           guard let snapshot = querySnapshot else {
             print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
             return
           }
       
      snapshot.documentChanges.forEach { change in
        self.handleUserChange(change)
          
         }
      }
        
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            let id = self.documentId?.documentID

        if self.isMovingFromParent {
            terminalRemove(id!)        }
         
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
     func terminalWelcome() {
                        
           // TODO:  ASCIIart keyboard stickers in next version
     
    let channelName = String(trip!.from.first!) + String(trip!.to.first!) + getReadableDate(time: trip!.time)!
               
             
  let asciiArt = Message(user: terminal, content:
     "                   __------__\n" +
    #"                 / _--------_\  "# + "\n" +
     #"               /  /                \  \  "# +
     "\n               |  |                |  |" +
    " \n               |_|__________|_|" + "\n" +
    #"        /-\ |                          | /-\  "# + "\n" +
   #"       |     |\           0           /|    | "# + "\n" +
   #"       |(  )| \           !          / |(  )| "# + "\n" +
   #"       |___|__\_____!_____/__|___| "# + "\n" +
    "       [______|#"+channelName+"|______] " +
   "\n         ||||    ~~~~~~~~     |||| " +
    "\n        `--'                           `--' "
     )
     
              save(asciiArt)
 
           }
    
    
    func terminalAdd() {
        
        let user = cUser!
           if !chatRoomUsers.contains(user){
           addUser(user)
              
            let messageT = Message(user: terminal, content: " \(currentUser.displayName)  has joined   #"  + String(trip!.from.first!) + String(trip!.to.first!) + getReadableDate(time: trip!.time)!)
            
                save(messageT)
 
           }
         
    }
    
    func terminalRemove(_ id: String) {
        
        let user = cUser!
         
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
      
      if message.content.contains("/b")  {
     
        let blockedUser = message.content.replacingOccurrences(of: "<\(message.sender.displayName)> /b ",with: "")
           
           for user in chatRoomUsers {
               if user.nickName == blockedUser {
             
                 let blockedUserId = user.uid
                
                host!.blocked.append(blockedUserId)
                 // if blocking person trip creator kick blocked one
                if (trip?.Passengers.contains(blockedUser))! {
                     let indexOfUser = (trip?.Passengers.firstIndex(of: blockedUser))!
                     trip?.Passengers.remove(at: indexOfUser)
                }
                     navigationController?.popViewController(animated: true)
                chatUserReference.document(trip!.hostID).updateData([
                    "blocked": host!.blocked
                   ]) { err in
                       if let err = err {
                           print("Error updating document: \(err)")
                       } else {
                           print("Document successfully updated")
                       }
                                
                         }
                         
                     }
                      
                         }
                    
          
                       }
          
          
          if message.content.contains("/r")  {
                 
                 let reportedUser = message.content.replacingOccurrences(of: "<\(message.sender.displayName)> /r ",with: "")
          
                 for user in chatRoomUsers {

                  if user.nickName == reportedUser {
                         
                       let reportedUserId = user.uid
                         documentId = docRef
                         
                      let reported = rUser(uid: reportedUserId, docName: documentId!.documentID)
                       
                       reportUser(reported)
                         
                     }
                 }
                 
               // TODO: more channel moderation by ops
               // Trip creators will be (@)op and other passengers will be (+)voiced users automatically. Other users could also join chat but ops can change channel mode to moderated if they want to. Some IRC commands will be added. /kick /ban etc.
                 
              // about Moderation Guidelines: i will check by filtering reported field in firebase daily, there is no blocking option now because sending private messages is not allowed. User can report and leave the channel. Inappropriate messages will be deleted automatically as channels are autodelted (deleted only from frontend Database for messages stays) after few hours of the trip. More channel moderation will be added in the next version.
                 
                 }
        
      default:
      break
      }
    }

    func reportUser(_ user: rUser) {
                      self.documentId = reportedReference.addDocument(data: user.representation) { error in
                      if let e = error {
                        print("Error sending message: \(e.localizedDescription)")
                        return
                          }

                         }
                    }
    
    private func handleUserChange(_ change: DocumentChange) {
      
        
        switch change.type {
        case .added:
        let user = cUser!
        chatRoomUsers.append(user)
  
          
        case .removed:
        let user = cUser!
        let index = chatRoomUsers.firstIndex(of: user)!
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
            return .black
        }
        
        return customIsFromCurrentSender(message: message) ? .gray : .blue
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
