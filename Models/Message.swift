 
import Firebase
import MessageKit
 
 
 struct Message: MessageType {
    
  var sender: SenderType
  let id: String?
  let content: String
  let sentDate: Date
  var kind: MessageKind { return .text(content) }

 
  var messageId: String {
    return id ?? UUID().uuidString
  }
  
 
    init(user: User, content: String) {
    sender = Sender (senderId: user.uid, displayName: user.email)
    self.content = content
    sentDate = Date()
    id = nil
  }
  
    
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    
    guard let date = data["created"]  as? Timestamp else {
      return nil
    }
    let sentDate = date.dateValue()
    guard let senderID = data["senderID"] as? String else {
      return nil
    }
    guard let senderName = data["senderName"] as? String else {
      return nil
    }
    
    id = document.documentID
    
    self.sentDate = sentDate
    sender = Sender(senderId: senderID, displayName: senderName)
    
    if let content = data["content"] as? String {
      self.content = content
     }  else {
      return nil
    }
  }
  
}

extension Message: DatabaseRepresentation {
  
  var representation: [String : Any] {
    [
      "created": sentDate,
      "senderID": sender.senderId,
      "senderName": sender.displayName,
      "content"  : content
    ]
   }
}

extension Message: Comparable {
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Message, rhs: Message) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }
    
}

 
 extension UIScrollView {
   
   var isAtBottom: Bool {
     return contentOffset.y >= verticalOffsetForBottom
   }
   
   var verticalOffsetForBottom: CGFloat {
     let scrollViewHeight = bounds.height
     let scrollContentSizeHeight = contentSize.height
     let bottomInset = contentInset.bottom
     let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
     return scrollViewBottomOffset
   }
   
 }
