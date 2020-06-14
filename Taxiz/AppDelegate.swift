//
//  AppDelegate.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
 
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
   
   var ref: DatabaseReference!
   let gcmMessageIDKey = "gcm.message_id"

    
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
           // Use Firebase library to configure APIs
           FirebaseApp.configure()

           Database.database().isPersistenceEnabled = true

           ref = Database.database().reference()
            
        let listener = Auth.auth().addStateDidChangeListener() { auth, user in
                   // auto sign-in and move to next view:
               if user != nil {
                currentUser = User(authData: user!)
                docRefOnline = usersRef.child(currentUser!.uid)
               }
      //this was myKey will be used for promotions for the  first time users
            if  KeychainWrapper.standard.string(forKey: "Key98") == nil {
        // if user disabled from firestore consol it won't get a new uid
 
                Auth.auth().signInAnonymously() { (user, error) in
                           
                 if let user = user {
                   
                   currentUser = User(authData: user.user)
                }
           }
         }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if currentUser != nil {
                          // check user's online status
                          let currentUserRef = usersRef.child(currentUser!.uid)
                          currentUserRef.setValue(currentUser?.displayName)
                          currentUserRef.onDisconnectRemoveValue()
                          docRefOnline = usersRef.child(currentUser!.uid)
                          }
                  }
  
      }
        
        Auth.auth().removeStateDidChangeListener(listener)
 
        if #available(iOS 10.0, *) {
           // For iOS 10 display notification (sent via APNS)
           UNUserNotificationCenter.current().delegate = self

           let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
           UNUserNotificationCenter.current().requestAuthorization(
             options: authOptions,
             completionHandler: {_, _ in })
         } else {
           let settings: UIUserNotificationSettings =
           UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
           application.registerUserNotificationSettings(settings)
         }

         application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self

        return true

    }
 
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }
 
      // Print full message.
      print(userInfo)
        
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
            print("Firebase registration token: \(fcmToken)")
      
            let dataDict:[String: String] = ["token": fcmToken]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
            // TODO: If necessary send token to application server.
            // Note: This callback is fired at each app startup and whenever a new token is generated.
        }
         
        func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
            print("Received data message: \(remoteMessage.appData)")
        }
        
    }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.

    }

//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().subscribe(toTopic: "ALL")
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
//        processNotification(notification)
//        completionHandler(.badge)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
//        processNotification(response.notification)
//        completionHandler()
//    }
    
 }
     
extension AppDelegate : MessagingDelegate {

func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
  print("Firebase registration token: \(fcmToken)")
 
    if  KeychainWrapper.standard.string(forKey: "Key98") == nil {

        cUser = chatUser(fcmToken: fcmToken)
        _ =  SharedUserLocation
        
   userId = chatUserReference.addDocument(data: cUser!.representation) { error in
   if let e = error {
     print("Error sending message: \(e.localizedDescription)")

     return
  }
      }
        cUser?.id = userId!.documentID
        _ = KeychainWrapper.standard.set(userId!.documentID, forKey: "Key98")
 
        chatUserReference.document(userId!.documentID).updateData([
                      "id": cUser?.id
                  ]) { err in
                      if let err = err {
                          print("Error updating document: \(err)")
                      } else {
                          print("Document successfully updated")
                      }
                  }
        
    } else {
        
       let documentID = KeychainWrapper.standard.string(forKey: "Key98")
       
        // cUser'i cek firestore'dan
        userId = chatUserReference.document(documentID!)

           userId!.getDocument { (document, error) in
               if let document = document, document.exists {
               cUser = chatUser(document: document)
               _ =  SharedUserLocation
 
            } }
        
        
        
            // update the token if it has changed. install/uninstall etc.
        
        if cUser?.fcmToken != fcmToken {

            cUser?.fcmToken = fcmToken
            chatUserReference.document(userId!.documentID).updateData([
               "fcmToken": fcmToken
            ])
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
         

        if let lastOnline = UserDefaults.standard.object(forKey: "lastOnline") as? Date {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
            
            if lastOnline < yesterday! {
            
                // TODO: clear cUser old pass & chat Data then update it on backend
                
                ratingCount = false
            }        
        }
    }

  let dataDict:[String: String] = ["token": fcmToken]
  NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  // TODO: If necessary send token to application server.
  // Note: This callback is fired at each app startup and whenever a new token is generated.
    

    
}

// The callback to handle data message received via FCM for devices running iOS 10 or above.
func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
    print(remoteMessage.appData)
}

}

// TODO:
//user offline:
//NotificationCenter.default.post(name: Notification.Name("offline"), object: nil)

