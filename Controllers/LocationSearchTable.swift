//
//  LocationSearchTable.swift
//  Taxiz
//
//  Created by Engin KUK on 14.02.2020.
//  Copyright © 2020 Silverback Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationSearchTable : UITableViewController {

    var handleMapSearchDelegate: HandleMapSearch? = nil
    var mapView: MKMapView? = nil
    var searchResults = [MKLocalSearchCompletion]()
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)

    lazy var searchCompleter: MKLocalSearchCompleter = {
          let sC = MKLocalSearchCompleter()
          sC.delegate = self
          sC.resultTypes = .pointOfInterest
          sC.region = boundingRegion
          return sC
      }()
    
    private var places: [MKMapItem]? {
          didSet {
              tableView.reloadData()
           }
      }
    
    private var localSearch: MKLocalSearch? {
          willSet {
              // Clear the results and cancel the currently running local search before starting a new search.
              places = nil
              localSearch?.cancel()
          }
      }
    
    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
      private func search(for suggestedCompletion: MKLocalSearchCompletion) {
          let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
            search(using: searchRequest)
      }
    
    /// - Tag: SearchRequest
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        searchRequest.region = boundingRegion
        
        // Include only point of interest results. This excludes results based on address matches.
        searchRequest.resultTypes = .pointOfInterest
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                self.displaySearchError(error)
                return
            }
            
            self.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            if let updatedRegion = response?.boundingRegion {
                self.boundingRegion = updatedRegion
            }
        }
    }
        
        private func displaySearchError(_ error: Error?) {
            if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
                let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
  
    }
  

  extension LocationSearchTable: UISearchResultsUpdating {

     func updateSearchResults(for searchController: UISearchController) {
               
      searchCompleter.queryFragment =  searchController.searchBar.text ?? ""

          self.tableView.reloadData()
          
      }
  }


extension LocationSearchTable: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
         self.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
        print("error loading MKLocalSearchCompleter")
    }
}
 

//-   Tableview DataSource methods

extension LocationSearchTable {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return searchResults.count
       }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let searchResult = searchResults[indexPath.row]
           let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
           cell.textLabel?.text = searchResult.title
           cell.detailTextLabel?.text = searchResult.subtitle

        return cell
       }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt  indexPath: IndexPath) {
         
        let selectedItem = searchResults[indexPath.row]
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = selectedItem.title

        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
        guard let response = response else {return}
        guard let item = response.mapItems.first else {return}

        self.handleMapSearchDelegate?.dropPinZoomIn(placemark: item.placemark)
        self.dismiss(animated: true, completion: nil)

    }
  }
}

