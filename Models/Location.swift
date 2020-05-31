//
//  Location.swift
//  Taxiz
//
//  Created by Engin KUK on 16.05.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import MapKit
  
let SharedUserLocation = myLocation()
let myUserLocation = SharedUserLocation.userLocation
var myCity = SharedUserLocation.city
var count = true
 
class myLocation : NSObject, CLLocationManagerDelegate {

var locationManager = CLLocationManager()
var userLocation: CLLocation?
let geoCoder = CLGeocoder()
var city : String?

    
   class var manager: myLocation {
        return SharedUserLocation
    }
    
    override init () {
        super.init()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.startUpdatingLocation()
    }
    
    
       private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
           if status == .authorizedWhenInUse {
               locationManager.requestLocation()
             
           }
       }

       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            //  will zoom to the first location
           if let location = locations.first {
                 userLocation = location
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
                                  placemarks?.forEach { (placemark) in
                                    self.city =   " \(placemark.subLocality ?? "unkown"), \(placemark.locality ?? "unkown")"
                                }
                           
                                if myCity != nil {

                                     sortLocation()
                                    if cUser != nil {
                               NotificationCenter.default.post(name: Notification.Name("userOnline"), object: nil)
                             }
                                     
                                 }
                
                            })

                        }

                    }
 
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
              print(error.localizedDescription)
          }
  }

   
