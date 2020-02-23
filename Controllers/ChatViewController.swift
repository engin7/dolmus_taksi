//
//  SecondViewController.swift
//
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
 

final class ChatViewController: MessagesViewController, MessagesDataSource {
    
     private let db = Firestore.firestore()
     private var reference: CollectionReference?
      
     private var messages: [Message] = []
     private var messageListener: ListenerRegistration?
     private let trip: Trips
     private let currentUser: User

     deinit {
       messageListener?.remove()
     }

    init(currentUser: User, trip: Trips) {
      self.currentUser = currentUser
      self.trip = trip
      super.init(nibName: nil, bundle: nil)
      title = trip.to
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let key = trip.id else {
//          navigationController?.popViewController(animated: true)
          return
        }
        
        reference = db.collection(["trips", key, "thread"].joined(separator: "/"))
 
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

        navigationItem.largeTitleDisplayMode = .never
        
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
        
        // implement 4 protocols:
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
         messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
 
     }
    
    
    // MARK: - Helpers

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

// MARK: - MessagesDataSource

  // initializa sender
 
  func currentSender() -> SenderType {
    return Sender(id: currentUser.uid, displayName: currentUser.email)
  }
  
  func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       return messages.count
  }

  // return the message for the given indexpath
  func messageForItem(at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageType {

    return messages[indexPath.section]
  }

  // returns the attributed text for the name above each message bubble.
  func cellTopLabelAttributedText(for message: MessageType,
    at indexPath: IndexPath) -> NSAttributedString? {
     let name =  message.sender.displayName
    print(name)
    return NSAttributedString(
      string: name,
      attributes: [
        .font: UIFont.preferredFont(forTextStyle: .caption1),
        .foregroundColor: UIColor.black
      ]
    )
  }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
           
           return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
       }
    
    
       func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
           let name = message.sender.displayName
           return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
       }
    }

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {

        //no pic
  func avatarSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {
    
    return .zero
  }

  func footerViewSize(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> CGSize {
   
    return CGSize(width: 0, height: 8)
  }

  func heightForLocation(message: MessageType, at indexPath: IndexPath,
    with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //hide location
    return 0
  }
}

extension ChatViewController: MessagesDisplayDelegate {
  
  func backgroundColor(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> UIColor {
    // change color according to  sender
    return isFromCurrentSender(message: message) ? .primary : .incomingMessage
  }

  func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> Bool {
    // remove header
    return false
  }

  func messageStyle(for message: MessageType, at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

    let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    // choose a corner for the tail of the message bubble depending on sender
    return .bubbleTail(corner, .curved)
  }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
  
  func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
    let message = Message(user: currentUser, content: text)

    save(message)
    inputBar.inputTextView.text = ""
  }
  
}
 
 
