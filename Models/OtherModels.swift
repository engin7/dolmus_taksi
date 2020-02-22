//
//  otherModels.swift
//  Taxiz
//
//  Created by Engin KUK on 22.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import Firebase
import UIKit
 


protocol DatabaseRepresentation {
   var representation: [String: Any] { get }
 }

extension UIColor {
  
  static var primary: UIColor {
    return UIColor(red: 1 / 255, green: 93 / 255, blue: 48 / 255, alpha: 1)
  }
  
  static var incomingMessage: UIColor {
    return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
  }
  
}
