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
    
    @IBOutlet weak var myFrom: UITextField!
    @IBOutlet weak var myTo: UITextField!
    @IBOutlet weak var myPrice: UILabel!
    @IBOutlet weak var myPersons: UILabel!
    @IBOutlet weak var addPerson: UIButton!
    @IBOutlet weak var removePerson: UIButton!
    
    @IBAction func createTripButton(_ sender: Any) {
        
        // add to firestore database:
        let trip =  Trips(time: Date(), to: myTo.text!, from: myFrom.text!, persons: Int(myPersons.text!)!, id: "nil")
         tripReference.addDocument(data: trip.representation) { error in
        if let e = error {
          print("Error saving channel: \(e.localizedDescription)")
        }
      }
       }

    
    @IBAction func cancelTripButton(_ sender: Any) {
        myTripView.isHidden = true
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
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.myTripView.isHidden = false
            self.myTo.text = self.selectedPin?.locality
            self.myFrom.text = self.currentCity
        }
  
    }
    
    func  removeOverlay() {
        self.mapView.overlays.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeOverlay($0)
            }
        }
    }
   
}

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
            let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
                placemarks?.forEach { (placemark) in
                    self.currentCity = placemark.locality
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
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
        annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
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
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 50, height: 50)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.addTarget(self, action:  #selector(getDirections),  for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "taxi"), for: [])
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
           let polyLine = MKPolylineRenderer(overlay: overlay)
               polyLine.strokeColor = UIColor.blue
        let destination = CLLocation(latitude: selectedPin!.coordinate.latitude, longitude: selectedPin!.coordinate.longitude)
        let distance = currentlocation!.distance(from: destination)/50000
        let spanRoute = MKCoordinateSpan(latitudeDelta: distance, longitudeDelta: distance)
        let midPointLat = (currentlocation!.coordinate.latitude + selectedPin!.coordinate.latitude) / 2
        let midPointLong = (currentlocation!.coordinate.longitude + selectedPin!.coordinate.longitude) / 2
        let center = CLLocation(latitude: midPointLat, longitude: midPointLong)
        let region = MKCoordinateRegion(center: center.coordinate, span: spanRoute)
        mapView.setRegion(region, animated: true)
        return polyLine
          }
      }
     
 
 
