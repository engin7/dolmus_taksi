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
    
}

extension LocationSearchTable : UISearchResultsUpdating {
      func updateSearchResults(for searchController: UISearchController) {
         
    }
 
}
