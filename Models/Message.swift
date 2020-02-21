 
import Firebase
import MessageKit
 
 struct Message: MessageType {
   
  var sender: SenderType
  let id: String?
  let content: String
  let sentDate: Date
  var kind: MessageKind { .text(content) }

  var data: MessageKind {
      return .text(content)
  }
  
  var messageId: String {
    return id ?? UUID().uuidString
  }
  
   var downloadURL: URL? = nil
  
  init(user: User, content: String) {
    sender = Sender(id: user.uid, displayName: "AppSettings.displayName")
    self.content = content
    sentDate = Date()
    id = nil
  }
  
 
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()
    
    guard let sentDate = data["created"] as? Date else {
      return nil
    }
    guard let senderID = data["senderID"] as? String else {
      return nil
    }
    guard let senderName = data["senderName"] as? String else {
      return nil
    }
    
    id = document.documentID
    
    self.sentDate = sentDate
    sender = Sender(id: senderID, displayName: senderName)
    
    if let content = data["content"] as? String {
      self.content = content
      downloadURL = nil
    } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
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
