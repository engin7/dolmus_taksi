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

//
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
       
//             terminalAdd()
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
