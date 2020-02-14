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
    
    var matchingItems:[MKMapItem] = []  // put in search result
    var mapView: MKMapView? = nil  // search uses map region while querying
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
     let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
     let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
     let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
    let addressLine = String(
    format:"%@%@%@%@%@%@%@",
    // street number
    selectedItem.subThoroughfare ?? "",
    firstSpace,
    // street name
    selectedItem.thoroughfare ?? "",
    comma,
    // city
    selectedItem.locality ?? "",
    secondSpace,
    // state
    selectedItem.administrativeArea ?? ""
    )
    return addressLine
    }
}

extension LocationSearchTable : UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
     guard let mapView = mapView,
     let searchBarText = searchController.searchBar.text else { return }
     let request = MKLocalSearch.Request()
     request.naturalLanguageQuery = searchBarText
     request.region = mapView.region
     let search = MKLocalSearch(request: request)
     search.start { response, _ in
     guard let response = response else {
     return
     }
     self.matchingItems = response.mapItems
     self.tableView.reloadData()
     }
  }
}

//-   Tableview DataSource methods

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
return matchingItems.count
}

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    let selectedItem = matchingItems[indexPath.row].placemark
    cell.textLabel?.text = selectedItem.name
    cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
    return cell
  }
}
