//
//  FirstViewController.swift
//  Taxiz
//
//  Created by Engin KUK on 12.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Firebase
 
protocol HandleMapSearch {
func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var myTripView: UIView!
    @IBOutlet weak var myFrom: UISearchBar!
    @IBOutlet weak var myTo: UISearchBar!
    @IBOutlet weak var myPersons: UILabel!
    @IBOutlet weak var picker: UIDatePicker!

    var pickerTime: Date?
    var trip : Trips?
    
    @IBAction func switchTrip(_ sender: Any) {
        swap(&myTo.text, &myFrom.text)
    }
    
    @IBAction func createTripButton(_ sender: Any) {
        
        if picker.date < Date() {
            
            pickerTime = Calendar.current.date(byAdding: .day, value: 1, to: picker.date)!
              trip =  Trips(time: pickerTime!, to: myTo.text!, from: myFrom.text!, passengers: currentUser!.email, id: "nil")
         } else {
              trip =  Trips(time: picker.date, to: myTo.text!, from: myFrom.text!, passengers: currentUser!.email, id: "nil")
        }
      
        let n = Int(myPersons.text!)!
        
        for i in 1..<n {
            trip!.Passengers.append(currentUser!.email + "+" + String(i))
        }
            // add to firestore database:
        tripReference.addDocument(data: trip!.representation) { error in
        if let e = error {
          print("Error saving channel: \(e.localizedDescription)")
         }
      }
 
         UIView.animate(withDuration: 0.2, animations: {
                   self.myTripView.alpha = 0
                }) { (finished) in
                   self.myTripView.isHidden = finished
                }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tabBarController?.selectedIndex = 0
            self.removeOverlay()
         }
       }

    @IBAction func addPerson(_ sender: Any) {
        
        var myPersonsInt = Int(myPersons.text!)!
        if myPersonsInt<3 {
        myPersonsInt += 1
        myPersons.text = String(myPersonsInt)
        }
    }
    
    @IBAction func removePerson(_ sender: Any) {
        var myPersonsInt = Int(myPersons.text!)!
        if myPersonsInt>1 {
        myPersonsInt -= 1
        myPersons.text = String(myPersonsInt)
      }
    }
       
    
    @IBAction func cancelTripButton(_ sender: Any) {
      
         UIView.animate(withDuration: 0.3, animations: {
            self.myTripView.alpha = 0
         }) { (finished) in
            self.myTripView.isHidden = finished
         }
        
        removeOverlay()
    }
     
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager?
    var currentlocation: CLLocation?
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var currentCity: String?
    let geoCoder = CLGeocoder()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTripView.isHidden = true
        myFrom.isUserInteractionEnabled = false
        myFrom.setImage(UIImage(), for: .clear, state: .normal)

        myTo.isUserInteractionEnabled = false
        myTo.setImage(UIImage(), for: .clear, state: .normal)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
                // Search Table display recommendations
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable

        let searchBar = resultSearchController!.searchBar
 
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        locationSearchTable.mapView = mapView
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.handleMapSearchDelegate = self

//        self.myFrom = searchBarTrip
//        self.myTo = searchBarTrip

     }
 
    @objc public func getDirections(){
            
        guard let start = currentlocation, let end = selectedPin else {   return }
        let request = MKDirections.Request()
        let startMapItem = MKMapItem(placemark: MKPlacemark(coordinate: start.coordinate))
        let endMapItem = MKMapItem(placemark: MKPlacemark(coordinate: end.coordinate))
        request.source = startMapItem
        request.destination = endMapItem
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        directions.calculate() {
          [weak self] (response, error) in
          if let error = error {
            print(error.localizedDescription)
            return
          }
          if let route = response?.routes.first {
             self?.mapView.addOverlay(route.polyline)
      }

    }
            // fade in view
            self.myTripView.alpha = 0
            self.myTripView.isHidden = false
            UIView.animate(withDuration: 0.3) {
             self.myTripView.alpha = 1
            }
            
            self.myTo.text = self.selectedPin?.subLocality
         
            self.myFrom.text = self.currentCity
            
        }
  
// MARK: - Actions

    func  removeOverlay() {
        self.mapView.overlays.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeOverlay($0)
            }
        }
    }
  
    
}
// MARK: - Extensions

extension MapViewController : CLLocationManagerDelegate {
     
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //  will zoom to the first location
        if let location = locations.first {
            self.currentlocation = location
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
                placemarks?.forEach { (placemark) in
                    self.currentCity = placemark.subLocality
                }
            })

        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           
           print(error.localizedDescription)
       }
       
}
    
    extension MapViewController: HandleMapSearch {
        func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        if let city = placemark.subLocality {
        annotation.title = "\(city)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            let region = MKCoordinateRegion(center:   CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude - 0.02)  , span: span)
         mapView.setRegion(region, animated: true)
        }
    }

  extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        let smallSquare = CGSize(width: 50, height: 50)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "taxi"), for: [])
        pinView?.leftCalloutAccessoryView = button
         
        pinView?.canShowCallout = true
        button.addTarget(self, action:  #selector(getDirections),  for: .touchUpInside)
        pinView?.isSelected = true
        return pinView
    }
     
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let polyLine = MKPolylineRenderer(overlay: overlay)
               polyLine.strokeColor = UIColor.blue
        let destination = CLLocation(latitude: selectedPin!.coordinate.latitude, longitude: selectedPin!.coordinate.longitude)
        let distance = currentlocation!.distance(from: destination)/50000
        let spanRoute = MKCoordinateSpan(latitudeDelta: distance, longitudeDelta: distance)
        let midPointLat = (currentlocation!.coordinate.latitude + selectedPin!.coordinate.latitude + 0.05) / 2
        let midPointLong = (currentlocation!.coordinate.longitude + selectedPin!.coordinate.longitude) / 2
        let center = CLLocation(latitude: midPointLat, longitude: midPointLong)
        let region = MKCoordinateRegion(center: center.coordinate, span: spanRoute)
        mapView.setRegion(region, animated: true)
        return polyLine
          }
      }
     
 
 
