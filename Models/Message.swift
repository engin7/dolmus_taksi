 
import Firebase
import MessageKit
 
 
 struct Message: MessageType {
    
  var sender: SenderType
  let senderId: String?
  let content: String
  let sentDate: Date
  var kind: MessageKind { return .text(content) }

 
  var messageId: String {
    return senderId ?? UUID().uuidString
  }
  
    var downloadURL: URL? = nil
  
    init(user: User, content: String) {
    sender = Sender (senderId: user.uid, displayName: user.email)
    self.content = content
    sentDate = Date()
    senderId = nil
  }
  
    
  init?(document: QueryDocumentSnapshot) {
    let kind = document.data()
    
    guard let sentDate = kind["created"] as? Date else {
      return nil
    }
    guard let senderID = kind["senderID"] as? String else {
      return nil
    }
    guard let senderName = kind["senderName"] as? String else {
      return nil
    }
    
    senderId = document.documentID
    
    self.sentDate = sentDate
    sender = Sender(senderId: senderID, displayName: senderName)
    
    if let content = kind["content"] as? String {
      self.content = content
      downloadURL = nil
    } else if let urlString = kind["url"] as? String, let url = URL(string: urlString) {
      downloadURL = url
      content = ""
    } else {
      return nil
    }
  }
  
}

extension Message: DatabaseRepresentation {
  
  var representation: [String : Any] {
    var rep: [String : Any] = [
      "created": sentDate,
      "senderID": sender.senderId,
      "senderName": sender.displayName
    ]
    
    if let url = downloadURL {
      rep["url"] = url.absoluteString
    } else {
      rep["content"] = content
    }
    
    return rep
  }
  
}

extension Message: Comparable {
  
  static func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.senderId == rhs.senderId
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
