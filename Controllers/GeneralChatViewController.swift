//
//  GeneralChatViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 10.05.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView
import UserNotifications


// TODO: Notifications via firebase
// TODO: Terminal messages red color
// TODO: kick leave etc commands.

  class GeneralChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate  {
     
     private var messages: [Message] = []
     private var messageListener: ListenerRegistration?
     private var userListener: ListenerRegistration?
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
    
    init(){
    self.terminal = User()
    super.init(nibName: nil, bundle: nil)
    }
    
   
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
         overrideUserInterfaceStyle = .light
        self.definesPresentationContext = true
        
 
//        // 1
//        usersRef.observe(.childAdded, with: { snap in
//          // 2
//          guard let email = snap.value as? String else { return }
//          self.currentUsers.append(email)
//          // 3
//          let row = self.currentUsers.count - 1
//          // 4
//          let indexPath = IndexPath(row: row, section: 0)
//          // 5
//          self.tableView.insertRows(at: [indexPath], with: .top)
//        })
//
//
//        usersRef.observe(.childRemoved, with: { snap in
//          guard let emailToFind = snap.value as? String else { return }
//          for (index, email) in self.currentUsers.enumerated() {
//            if email == emailToFind {
//              let indexPath = IndexPath(row: index, section: 0)
//              self.currentUsers.remove(at: index)
//              self.tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//          }
//        })
        // https://www.raywenderlich.com/3-firebase-tutorial-getting-started#toc-anchor-020
        
         reference = db.collection(["Console", "J5OY4jZbFZRPuVPQSzwu", "thread"].joined(separator: "/"))

         docRef = reference!.document("J5OY4jZbFZRPuVPQSzwu")

        
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
       
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
                  
                  guard let snapshot = querySnapshot else {
                    print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                  }
                    snapshot.documentChanges.forEach { change in
                    self.handleDocumentChange(change)
                  }

                }
        
             let dateFormatter = DateFormatter()
 
                     dateFormatter.dateStyle = .full

                       dateFormatter.timeStyle = .full
 
        let dateString =  dateFormatter.string(from: Date())
 
               DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
 
       docRefOnline!.observe(.value, with: { snapshot in
              
           if snapshot.exists() {
                                      
              let online = " "+(cUser!.nickName)+" is online @ " +  dateString
                   
           let message = Message(user: currentUser!, content: online)
            
                self.save(message)
                
               }
                  })
             
               }
            
        
            NotificationCenter.default.addObserver(self, selector: #selector(away), name: Notification.Name("away"), object: nil)
        
            NotificationCenter.default.addObserver(self, selector: #selector(foreground), name: Notification.Name("foreground"), object: nil)
        
        }
       
    
     @objc func away (notification: NSNotification){
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .full

          dateFormatter.timeStyle = .full

          let dateString =  dateFormatter.string(from: Date())
        
        let away = " "+(cUser!.nickName)+" is away @ " +  dateString

        let message = Message(user: currentUser!, content: away)
                   
          self.save(message)
        
    }

     @objc func foreground (notification: NSNotification){
           
           let dateFormatter = DateFormatter()
           
           dateFormatter.dateStyle = .full

             dateFormatter.timeStyle = .full

             let dateString =  dateFormatter.string(from: Date())
           
           let away = " "+(cUser!.nickName)+" is back online @ " +  dateString

           let message = Message(user: currentUser!, content: away)
                      
             self.save(message)
           
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
             //will update
            let sender = message.sender.senderId
             for user in chatRoomUsers {
                 if user.nickName == blockedUser {
               
                   let blockedUserId = user.uid
                  if !(host?.blocked.contains(blockedUserId))!{
                  host!.blocked.append(blockedUserId)
                  cUser!.blocked.append(host!.uid)
                  }
                   // if blocking person trip creator kick blocked one
                  if (trip?.Passengers.contains(blockedUser))! {
                       let indexOfUser = (trip?.Passengers.firstIndex(of: blockedUser))!
                       trip?.Passengers.remove(at: indexOfUser)
                  }
 
                  chatUserReference.document(cUser!.id!).updateData([
                   "blocked": cUser!.blocked
                  ]) { err in
                      if let err = err {
                          print("Error updating document: \(err)")
                      } else {
                          print("Document successfully updated")
                      }
                               
                        }
                  
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
             
                   }
          
        default:
        break
        }
      }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
     
    
     func terminalWelcome() {
                        
     
             
 
           }
    
     
 
    // MARK: - Helpers
 
     
     public func save(_ message: Message) {
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
    

    func reportUser(_ user: rUser) {
                      self.documentId = reportedReference.addDocument(data: user.representation) { error in
                      if let e = error {
                        print("Error sending message: \(e.localizedDescription)")
                        return
                          }

                         }
                    }
    

    

// MARK: - MessagesDataSource

  // initializa sender
 
  func currentSender() -> SenderType {
    return Sender(senderId: currentUser!.uid, displayName: currentUser!.displayName)
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

extension GeneralChatViewController: MessagesDisplayDelegate {
  
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
 
extension GeneralChatViewController: MessageInputBarDelegate {
   
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    
    let message = Message(user: currentUser!, content: "<"+(currentUser!.displayName)+"> " + text)
    save(message)
    inputBar.inputTextView.text = ""
    
  }
  
}
