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
func dropPinZoomInTo(placemark:MKPlacemark)
func dropPinZoomInFrom(placemark:MKPlacemark)
}

// different pin color for origin and destination
class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor

    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}


class MapViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var myTripView: UIView!
 
    @IBOutlet weak var myFrom: UIView!
    @IBOutlet weak var myTo: UIView!
    
    @IBOutlet weak var myPersons: UILabel!
    @IBOutlet weak var picker: UIDatePicker!

    var pickerTime: Date?
    var trip : Trips?
    var toCity: String?
    var fromCity: String?
    var resultSearchController = UISearchController(searchResultsController: nil)
    var fromSearchController = UISearchController(searchResultsController: nil)
    var toSearchController = UISearchController(searchResultsController: nil)
    var toAnnotation: MKAnnotation?
    var fromLocation_searchBar: String?
    var pinView :  MKPinAnnotationView?
    
    @IBAction func switchTrip(_ sender: Any) {
        swap(&toSearchController.searchBar.text, &fromSearchController.searchBar.text)
        swap(&toCity, &fromCity)
        swap(&toLocation, &fromLocation)
        mapView.removeAnnotations(mapView.annotations)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        let annotationFrom = ColorPointAnnotation(pinColor: UIColor.green)
            annotationFrom.coordinate = self.fromLocation!.coordinate
        let annotationTo = ColorPointAnnotation(pinColor: UIColor.red)
        annotationTo.coordinate = self.toLocation!.coordinate
        
        self.mapView.addAnnotation(annotationFrom)
        self.mapView.addAnnotation(annotationTo)

        }
    }
    
    @IBAction func createTripButton(_ sender: Any) {
        
        if (toSearchController.searchBar.text != "") && (fromSearchController.searchBar.text != "")
        {
        if picker.date <= Date() {
            
            pickerTime = picker.date.addingTimeInterval(86400)
            trip =  Trips(time: pickerTime!, to: toSearchController.searchBar.text!, toCity: toCity!, from: fromSearchController.searchBar.text!, fromLocation: [(fromLocation?.coordinate.latitude)!, (fromLocation?.coordinate.longitude)! ] , fromCity: fromCity!, passengers: currentUser!.displayName, id: "nil")
         } else {
            trip =  Trips(time: picker.date, to: toSearchController.searchBar.text!, toCity: toCity!, from: fromSearchController.searchBar.text!, fromLocation: [(fromLocation?.coordinate.latitude)!, (fromLocation?.coordinate.longitude)! ], fromCity: fromCity!, passengers: currentUser!.displayName, id: "nil")
        }
      
        let n = Int(myPersons.text!)!
        
        for i in 1..<n {
            trip!.Passengers.append(currentUser!.displayName + "+" + String(i))
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        mapView.removeAnnotations(mapView.annotations)
  
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
        
        mapView.removeAnnotations(mapView.annotations)
        removeOverlay()
        fromSearchController.searchBar.text = ""
        toSearchController.searchBar.text = ""
        navigationController?.setNavigationBarHidden(false, animated: true)

        setNavigationSearchBar()
        
    }
     
    @IBOutlet weak var mapView: MKMapView!
    
    private var locationManager: CLLocationManager?
//    private var currentlocation: CLLocation?
    private var fromLocation: CLLocation?
    private var toLocation: CLLocation?
    private var selectedPin:MKPlacemark? = nil
    private var currentCity: String?
    private let geoCoder = CLGeocoder()
    private var foregroundRestorationObserver: NSObjectProtocol?

    override func viewDidLoad() {
        overrideUserInterfaceStyle = .light

        super.viewDidLoad()
        myTripView.isHidden = true
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        setNavigationSearchBar()
        arrangeSearchBars()

     }
    
    func setNavigationSearchBar() {
        
         let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
               resultSearchController.searchResultsUpdater = locationSearchTable
               let searchBar = resultSearchController.searchBar

               searchBar.setImage(UIImage(), for: .clear, state: .normal)
               searchBar.sizeToFit()
               searchBar.placeholder = "Search for places"

               navigationItem.titleView = resultSearchController.searchBar
               resultSearchController.searchBar.delegate = self
               resultSearchController.hidesNavigationBarDuringPresentation = false
               resultSearchController.obscuresBackgroundDuringPresentation = true
               
               definesPresentationContext = true
        
               locationSearchTable.handleMapSearchDelegate = self
   
    }
     
     func arrangeSearchBars(){
        
        // Search Table display recommendations
       let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
       let PopupLocationSearchTable = storyboard!.instantiateViewController(withIdentifier: "PopupLocationSearchTable") as! PopupLocationSearchTable
        
        locationSearchTable.handleMapSearchDelegate = self
               locationSearchTable.additionalSafeAreaInsets = UIEdgeInsets(top: 50 , left: 0, bottom: 0, right: 0)

        PopupLocationSearchTable.handleMapSearchDelegate = self
        fromSearchController = UISearchController(searchResultsController: PopupLocationSearchTable)
        PopupLocationSearchTable.additionalSafeAreaInsets = UIEdgeInsets(top: 50 , left: 0, bottom: 0, right: 0)
        
        fromSearchController.searchResultsUpdater = PopupLocationSearchTable
         let fromSearchBar = fromSearchController.searchBar
        fromSearchBar.sizeToFit()
        
        fromSearchBar.setImage(UIImage(), for: .clear, state: .normal)
        fromSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        fromSearchBar.placeholder = "Origin"
 
        myFrom.addSubview(fromSearchController.searchBar)
        
        fromSearchController.searchBar.delegate = self

        
        toSearchController = UISearchController(searchResultsController: locationSearchTable)
 
        toSearchController.searchResultsUpdater = locationSearchTable
        let toSearchBar = toSearchController.searchBar
        toSearchBar.sizeToFit()
         
        toSearchBar.setImage(UIImage(), for: .clear, state: .normal)
        toSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)

        toSearchBar.placeholder = "Destination"
        
        myTo.addSubview(toSearchController.searchBar)
        toSearchController.searchBar.delegate = self

        var searchBarFrame = fromSearchController.searchBar.frame
         searchBarFrame.size.width = myFrom.frame.size.width - 15
         fromSearchController.searchBar.frame = searchBarFrame
         toSearchController.searchBar.frame = searchBarFrame
        
         self.fromSearchController.hidesNavigationBarDuringPresentation = false
         self.toSearchController.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = true

      }
    
    @objc public func getDirections(){
        
        guard let start = fromLocation, let end = selectedPin else {   return }
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
            
             toSearchController.searchBar.text = self.selectedPin?.subLocality  ?? self.selectedPin?.name
            self.toCity = "\(self.selectedPin?.locality ?? "unknown"), \(self.selectedPin?.administrativeArea ?? "unknown")"
        
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
            self.fromLocation = location
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
                placemarks?.forEach { (placemark) in
                    self.currentCity = placemark.subLocality ?? placemark.name
                    self.fromCity =   " \(placemark.locality ?? "unkown")  , \(placemark.administrativeArea ?? "unkown")"
                }
            })
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           
           print(error.localizedDescription)
       }
}
                    
    extension MapViewController: HandleMapSearch {
        func dropPinZoomInTo(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
//         clear destination pins and Overlays
            for annotation in mapView.annotations where annotation === toAnnotation   {
              mapView.removeAnnotation(annotation)
          }
//        mapView.removeAnnotations(mapView.annotations)
        self.removeOverlay()
        let annotation = ColorPointAnnotation(pinColor: UIColor.red)
         annotation.coordinate = placemark.coordinate
            if let place = placemark.name {
        annotation.title = "\(place)"
        }
        toAnnotation = annotation
        mapView.addAnnotation(annotation)
        toLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            let region = MKCoordinateRegion(center:   CLLocationCoordinate2D(latitude: annotation.coordinate.latitude + 0.02, longitude: annotation.coordinate.longitude - 0.02)  , span: span)
         mapView.setRegion(region, animated: true)
         myTripView.isHidden = true
         fromSearchController.searchBar.text = fromLocation_searchBar ?? currentCity
 
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

                var searchBarFrame = self.fromSearchController.searchBar.frame
                searchBarFrame.size.width = self.myFrom.frame.size.width - 15
                self.fromSearchController.searchBar.frame = searchBarFrame
                self.toSearchController.searchBar.frame = searchBarFrame
            }
        }
        
        func dropPinZoomInFrom(placemark:MKPlacemark){
               
               // cache the pin
                fromLocation = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
                fromLocation_searchBar =  placemark.subLocality ?? placemark.name
                self.fromCity  = " \(placemark.locality ?? "unkown")  , \(placemark.administrativeArea ?? "unkown")"
                self.fromSearchController.searchBar.text = fromLocation_searchBar
                 
              // clear existing pins
               mapView.removeAnnotations(mapView.annotations)
               self.removeOverlay()
              let annotation = ColorPointAnnotation(pinColor: UIColor.green)
               annotation.coordinate = placemark.coordinate
             
                   if let place = placemark.name {
               annotation.title = "\(place)"

              }
               mapView.addAnnotation(annotation)
               let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            let region = MKCoordinateRegion(center:   CLLocationCoordinate2D(latitude: annotation.coordinate.latitude + 0.04, longitude: annotation.coordinate.longitude)  , span: span)
                mapView.setRegion(region, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

            var searchBarFrame = self.fromSearchController.searchBar.frame
            searchBarFrame.size.width = self.myFrom.frame.size.width - 15
            self.fromSearchController.searchBar.frame = searchBarFrame
            self.toSearchController.searchBar.frame = searchBarFrame
            }
               }
    }

  extension MapViewController : MKMapViewDelegate {
    
  
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
         
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        let colorPointAnnotation = annotation as! ColorPointAnnotation
        pinView?.pinTintColor = colorPointAnnotation.pinColor
        if  colorPointAnnotation.pinColor == UIColor.red {
        let smallSquare = CGSize(width: 50, height: 50)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "taxi"), for: [])
        pinView?.leftCalloutAccessoryView = button
        pinView?.canShowCallout = true
         pinView?.calloutOffset = CGPoint(x: -5, y: 5)
         
        button.addTarget(self, action:  #selector(getDirections),  for: .touchUpInside)
              
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.pinView?.isSelected = true
        }
        } else {
            pinView?.canShowCallout = true
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        return pinView
    }
     
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            let polyLine = MKPolylineRenderer(overlay: overlay)
               polyLine.strokeColor = UIColor.blue
        let destination = CLLocation(latitude: selectedPin!.coordinate.latitude, longitude: selectedPin!.coordinate.longitude)
        let distance = fromLocation!.distance(from: destination)/20000
        let distanceLat = abs(fromLocation!.coordinate.latitude.distance(to: destination.coordinate.latitude))
        let spanRoute = MKCoordinateSpan(latitudeDelta: distance, longitudeDelta: distance)

        let midPointLat = ((fromLocation!.coordinate.latitude + selectedPin!.coordinate.latitude) / (2-(distanceLat/10))) + 0.01
        let midPointLong = (fromLocation!.coordinate.longitude + selectedPin!.coordinate.longitude) / 2
        let center = CLLocation(latitude: midPointLat, longitude: midPointLong)
        let region = MKCoordinateRegion(center: center.coordinate, span: spanRoute)
        mapView.setRegion(region, animated: true)
        pinView?.isSelected = false
        return polyLine
          }
      }
     
 
 
