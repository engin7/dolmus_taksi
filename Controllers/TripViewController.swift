//
//  FirstViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import UIKit
import MapKit

class TripViewController: UIViewController {
    
 
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var currentlocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        
    }


}

 
    
extension TripViewController : CLLocationManagerDelegate {
     
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //  will zoom to the first location
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           
           print(error.localizedDescription)
       }
       
}
   
 

