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

class MapViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var myTripView: UIView!
 
    @IBOutlet weak var myFrom: UIView!
    @IBOutlet weak var myTo: UIView!
 
    @IBOutlet weak var pickerView: UIPickerView!  //bug in storyboard 
    
    @IBOutlet weak var picker: UIDatePicker!
    
    
    let passengersArray = ["1","2","3"]
    var passenger: Int?
    var pickerTime: Date?
    var trip : Trips?
    var toCity: String?
    var fromCity: String?
    var fromSearchController = UISearchController(searchResultsController: nil)
    var toSearchController = UISearchController(searchResultsController: nil)
    var toAnnotation: MKAnnotation?
    var fromLocation_searchBar: String?
    var pinView :  MKPinAnnotationView?
    private var referenceUsers: CollectionReference?
 
    @IBAction func switchTrip(_ sender: Any) {
        if toSearchController.searchBar.text != "" {
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
    }
    
    @IBAction func createTripButton(_ sender: Any) {
        
     if (toSearchController.searchBar.text != "") && (fromSearchController.searchBar.text != "")
        {
            zoomRoute()
         if  currentUser?.previousTrip ?? Date().addingTimeInterval(TimeInterval(-5.0 * 60.0)) <= Date().addingTimeInterval(TimeInterval( tSpam * -5.0)) {
            tSpam = tSpam + 1.0
            
            self.getDirections()
            
        if picker.date <= Date() {
            
            let calendar = Calendar.current
            let date = picker.date
 
            let components = calendar.dateComponents(
                [.hour, .minute, .second, .nanosecond],
                from: date
            )

            let tomorrow = calendar.nextDate(
                after: date,
                matching: components,
                matchingPolicy: .nextTime
            )
            
            trip =  Trips(time: tomorrow!, to: toSearchController.searchBar.text!, toCity: toCity!, from: fromSearchController.searchBar.text!, fromLocation: [(fromLocation?.coordinate.latitude)!, (fromLocation?.coordinate.longitude)! ] , fromCity: fromCity!, passengers: currentUser!.displayName, host: cUser!.uid!, hostID: cUser!.id!)
            currentUser?.previousTrip = Date()
         } else {
            trip =  Trips(time: picker.date, to: toSearchController.searchBar.text!, toCity: toCity!, from: fromSearchController.searchBar.text!, fromLocation: [(fromLocation?.coordinate.latitude)!, (fromLocation?.coordinate.longitude)! ], fromCity: fromCity!, passengers: currentUser!.displayName, host: cUser!.uid!, hostID: cUser!.id!)
                currentUser?.previousTrip = Date()
       }
            var n : Int
           func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                 n = row + 1
            
            for i in 1..<n {
            trip!.Passengers.append(currentUser!.displayName + "+" + String(i))
        }
          }
            // add to firestore database:
        let doc_ref = tripReference.addDocument(data: trip!.representation) { error in
        if let e = error {
          print("Error saving channel: \(e.localizedDescription)")
         }
            
      }

        self.referenceUsers = db.collection(["Trips", doc_ref.documentID, "users"].joined(separator: "/"))
            
         let host_doc_ref = self.referenceUsers?.addDocument(data: cUser!.representation)
            cUser?.chatUserId![doc_ref.documentID] = host_doc_ref?.documentID
            
            let documentId = userId?.documentID
               
               chatUserReference.document(documentId!).updateData([
                   "chatUserId": cUser!.chatUserId!
                         ]) { err in
                             if let err = err {
                                 print("Error updating document: \(err)")
                             } else {
                                 print("Document successfully updated")
                             }
                                      
                               }
          

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            self.tabBarController?.selectedIndex = 0
            self.pinView = nil
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.removeOverlay()
            self.toSearchController.searchBar.text = ""

         }
         
       } else {
            
            let alert = UIAlertController(title: "Trip Creating Limit", message: "To prevent spamming, we have user limits for creating a trip channel. Please leave the trip channel you previously created if it is not legitimate and wait for a few minutes.", preferredStyle: .alert)
                             
                  alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.cancelTrip()
                  }))
                  self.present(alert, animated: true, completion: nil)

      }
        }
            }
 
 func cancelTrip() {
      
        selectedPin = nil
        mapView.removeAnnotations(mapView.annotations)
        removeOverlay()
        fromSearchController.searchBar.text = ""
        toSearchController.searchBar.text = ""
        
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
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        mapView.delegate = self
        self.arrangeSearchBars()
         
        let calendar = Calendar.current
        var components = DateComponents()
        if calendar.component(.minute, from: Date()) < 30 {
            components.hour = calendar.component(.hour, from: Date()) + 1
        } else {
        components.hour = calendar.component(.hour, from: Date()) + 2
        }
        components.minute = 30
        components.day = calendar.component(.day, from: Date())
        components.month = calendar.component(.month, from: Date())
        components.year = calendar.component(.year, from: Date())
        
        picker.setDate(calendar.date(from: components)!, animated: false)
        
     }
    
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }
         
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return passengersArray.count
     }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return passengersArray[row]
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
        self.fromSearchController.searchBar.text = fromLocation_searchBar ?? currentCity ?? ""

      }
    
      func getDirections(){
      
 
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
 
        }
  
// MARK: - Actions

    func  removeOverlay() {
      // check this bug later as you might switch to google maps in future!
        // Get the all overlays from map view
         self.mapView.overlays.forEach {
                       if !($0 is MKUserLocation) {
                           self.mapView.removeOverlay($0)
                       }
              }
          }
    func zoomRoute() {
        
        let destination = CLLocation(latitude: selectedPin!.coordinate.latitude, longitude: selectedPin!.coordinate.longitude)
        let distance = fromLocation!.distance(from: destination)/20000
        let distanceLat = abs(fromLocation!.coordinate.latitude.distance(to: destination.coordinate.latitude))
        let spanRoute = MKCoordinateSpan(latitudeDelta: distance, longitudeDelta: distance)

        let midPointLat = ((fromLocation!.coordinate.latitude + selectedPin!.coordinate.latitude) / (2-(distanceLat/10))) + 0.01
        let midPointLong = (fromLocation!.coordinate.longitude + selectedPin!.coordinate.longitude) / 2
        let center = CLLocation(latitude: midPointLat, longitude: midPointLong)
        let region = MKCoordinateRegion(center: center.coordinate, span: spanRoute)
        mapView.setRegion(region, animated: true)
        
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
                    self.fromSearchController.searchBar.text = self.fromLocation_searchBar ?? self.currentCity
 
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
          fromSearchController.searchBar.text = fromLocation_searchBar ?? currentCity
            toSearchController.searchBar.text = self.selectedPin?.subLocality  ?? self.selectedPin?.name
                self.toCity = "\(self.selectedPin?.locality ?? "unknown"), \(self.selectedPin?.administrativeArea ?? "unknown")"
            
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
                self.fromSearchController.searchBar.text = fromLocation_searchBar ?? currentCity
                 
              // clear existing pins
               mapView.removeAnnotations(mapView.annotations)

            let annotation = ColorPointAnnotation(pinColor: UIColor.green)
               annotation.coordinate = placemark.coordinate
             
                   if let place = placemark.name {
               annotation.title = "\(place)"

              }
               mapView.addAnnotation(annotation)
               let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
            let region = MKCoordinateRegion(center:   CLLocationCoordinate2D(latitude: annotation.coordinate.latitude + 0.04, longitude: annotation.coordinate.longitude)  , span: span)
                mapView.setRegion(region, animated: true)
             
                 if self.selectedPin != nil {
 
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
         
        pinView?.canShowCallout = true
         pinView?.calloutOffset = CGPoint(x: -5, y: 5)
         
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.pinView?.isSelected = true
        }
        } else {
            pinView?.canShowCallout = true
        }
        return pinView
    }
 
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
             
                pinView?.isSelected = false

                guard(overlay is MKPolyline) else { return MKOverlayRenderer() }
                  let pLine = MKPolylineRenderer(overlay: overlay)
                pLine.strokeColor = UIColor.blue
                 
                return pLine
        
           }
      }
     
 
 
