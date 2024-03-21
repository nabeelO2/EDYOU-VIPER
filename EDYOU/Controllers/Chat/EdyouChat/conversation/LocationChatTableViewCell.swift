//
// LocationChatTableViewCell.swift
//
// EdYou
// Copyright (C) 2016 "O2Geeks." <admin@o2geeks.com>
//
 
//


import Foundation
import UIKit
import MapKit
import CoreLocation

class LocationChatTableViewCell: BaseChatTableViewCell {
    
    @IBOutlet var mapView: MKMapView! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)));
            gestureRecognizer.numberOfTapsRequired = 2;
            mapView.addGestureRecognizer(gestureRecognizer);
        }
    }
    
    private let annotation = MKPointAnnotation();
    
    func set(item: ConversationEntry, location: CLLocationCoordinate2D) {
        super.set(item: item);
        mapView.layer.cornerRadius = 5;
        mapView.removeAnnotation(annotation);
        annotation.coordinate = location;
        mapView.addAnnotation(annotation);
        mapView.setRegion(MKCoordinateRegion(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000), animated: true);
    }
    
    @objc func mapTapped(_ sender: Any) {
        let placemark = MKPlacemark(coordinate: annotation.coordinate);
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000);
        let item = MKMapItem(placemark: placemark);
        item.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
        ])
    }
    
}
