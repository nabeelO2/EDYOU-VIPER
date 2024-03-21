//
// ShareLocationSearchResultsController.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import Foundation
import UIKit
import MapKit

class ShareLocationSearchResultsController: UITableViewController, UISearchResultsUpdating {
    
    var mapView: MKMapView!;
    weak var mapController: ShareLocationController!;
    
    private var matchingItems: [MKMapItem] = [];
    private var id = UUID();
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else {
            return;
        }
        
        let id = UUID();
        self.id = id;
        
        let request = MKLocalSearch.Request();
        request.naturalLanguageQuery = query;
        request.region = mapView.region;
        
        let search = MKLocalSearch(request: request);
        search.start(completionHandler: { (response, _) in
            guard let response = response, self.id == id else {
                return;
            }
            self.matchingItems = response.mapItems;
            self.tableView.reloadData();
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil);
        let item = matchingItems[indexPath.row].placemark;
        cell.textLabel?.text = item.name;
        let address = [item.thoroughfare, item.locality, item.subLocality, item.administrativeArea, item.postalCode, item.country];
        cell.detailTextLabel?.text = address.compactMap({ $0 }).joined(separator: ", ");
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = matchingItems[indexPath.row].placemark;
        mapController.setCurrentLocation(placemark: item, coordinate: item.coordinate, zoomIn: true);
        self.dismiss(animated: true, completion: nil);
    }
}
