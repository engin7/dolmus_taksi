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

  class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate {
    
     private var messages: [Message] = []
     private var messageListener: ListenerRegistration?
     private let currentUser: User
     private var reference: CollectionReference?
     private var trip: Trips?
     let paragraph = NSMutableParagraphStyle()
    
     deinit {
        messageListener?.remove()
      }
    
     private var terminal: User {
        .init(uid: title!, nick: "terminal")
     }
    
     public var chatRoomUsers: [String]
    
 
    init(currentUser: User, trip: Trips) {
      self.currentUser = currentUser
      self.trip = trip
      self.chatRoomUsers = trip.Passengers
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

      }
  
    
    @objc func showUsers(sender: UIButton!) {
         
           let vcl = ChatUsersTableViewController(trip: trip!)
          navigationController?.pushViewController(vcl, animated: true)

       }
    
    
    // MARK: - Helpers

 
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
  
