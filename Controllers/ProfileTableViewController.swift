//
//  ProfileTableViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 24.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import MessageUI
import MobileCoreServices


class ProfileTableViewController:  UITableViewController, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
 {

     @IBOutlet weak var nickName: UILabel!
    
    @IBOutlet weak var rating: UILabel!
    
    
    @IBOutlet weak var userProfileImageView: UIImageView!
     
    @IBAction func contactUs(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["kuk.engin@icloud.com"])
        mailVC.setSubject("Subject for email")
        mailVC.setMessageBody("email message ...", isHTML: false)

        present(mailVC, animated: true, completion: nil)
        } else {
            
            let alert = UIAlertController(title: "e-mail not connected", message: "Please enable your email account in your device.", preferredStyle: .alert)
                    
                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil);
                 }))
                 self.present(alert, animated: true, completion: nil)
          }
    }
    
 @IBAction func setProfileImageButtonTapped(_ sender: UILongPressGestureRecognizer) {
     let profileImagePicker = UIImagePickerController()
    profileImagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
     profileImagePicker.mediaTypes = [kUTTypeImage as String]
     profileImagePicker.delegate = self
     present(profileImagePicker, animated: true, completion: nil)
 }
 
    
    override func viewDidLoad() {
           super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        let nick = NSLocalizedString("nickName: ", comment: "")

        nickName.text = nick + currentUser!.displayName
        if let userImage =  UserDefaults.standard.object(forKey: "image") as? Data
        {
        userProfileImageView.image = UIImage(data: userImage)
        }
        if cUser != nil {
        if (cUser?.rating.count)! < 5 {
        rating.text = "no ratings"
        } else {
            
        let text1 = "\(Double(round(10 * Double((cUser?.rating.reduce(0, +))!)/Double((cUser?.rating.count)!))/10))"
       
        let count = cUser?.rating.count
            let text2 = "/5 - \(count ?? 0)" + " ratings"
            
        rating.text = text1 + text2
            
        }
        }
    }
 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

   //MARK: - MFMail compose method
   func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
       controller.dismiss(animated: true, completion: nil)
   }
    
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let profileImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let optimizedImageData = profileImage.jpegData(compressionQuality: 0.4)
        {
            // upload image from here
            uploadProfileImage(imageData: optimizedImageData)
        }
        picker.dismiss(animated: true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadProfileImage(imageData: Data)
    {
        let activityIndicator = UIActivityIndicatorView.init(style: .medium)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
         
        let storageReference = Storage.storage().reference()
        let currentUser = Auth.auth().currentUser
        let profileImageRef = storageReference.child("users").child(currentUser!.uid).child("\(currentUser!.uid)-profileImage.jpg")
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
           
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
              
                self.userProfileImageView.image = UIImage(data: imageData)
               
                UserDefaults().set(imageData, forKey: "image")

                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
            }
        }
    }
    
  
}
