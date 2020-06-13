//
//  RatingsViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 9.06.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase

class RatingsViewController: UIViewController {

    var usertobeRated: chatUser?
    var  usertobeRatedId: DocumentReference?
    var tobeRated = ""
 
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet var starButtons: [UIButton]!
    @IBAction func starButtonPressed(_ sender: UIButton) {
        
        let tag = sender.tag
        for button in starButtons {
            
            if button.tag <= tag {
                button.setTitle("★", for: .normal)
            } else {
                button.setTitle("☆", for: .normal)
            }
        }
        
        usertobeRated?.rating.append(tag+1)
        
        chatUserReference.document(tobeRated).updateData([
            "rating": usertobeRated?.rating
         ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
         
           cUser?.ratedBy!.removeValue(forKey: tobeRated)
         
        chatUserReference.document(cUser!.id!).updateData([
             "ratedBy": cUser?.ratedBy
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        removeAnimate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        usertobeRatedId = chatUserReference.document(tobeRated)
                    usertobeRatedId!.getDocument { (document, error) in
                 if let document = document, document.exists {
                   self.usertobeRated = chatUser(document: document)
                   self.downloadImage()

                }   }
         }
     
        func downloadImage() {
            let storageReference = Storage.storage().reference()
            let profileImageRef = storageReference.child("users").child(((usertobeRated?.uid)!)).child("\(   (usertobeRated?.uid)!)-profileImage.jpg")
            _ = profileImageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
              if let error = error {
                //  an error occurred!
                print(error)
              } else {
                let image = UIImage(data: data!)
                self.userImage.image = image
              }
          }
     }
    
     func showAnimate()
     {
         self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
         self.view.alpha = 0.0
         UIView.animate(withDuration: 1.25, animations: {
             self.view.alpha = 1.0
             self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
         })
     }
    
    func removeAnimate()
       {
           UIView.animate(withDuration: 0.8, animations: {
               self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
               self.view.alpha = 0.0
           }, completion: {(finished : Bool) in
               if(finished)
               {
                   self.willMove(toParent: nil)
                   self.view.removeFromSuperview()
                   self.removeFromParent()
               }
           })
       }
  }
