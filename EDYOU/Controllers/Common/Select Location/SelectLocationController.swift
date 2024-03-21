//
//  SelectLocationController.swift
//  Carzly
//
//  Created by Zuhair Hussain on 23/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class SelectLocationController: BaseController {
    
    // MARK: - Outlers
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewActivityIndicator: UIView!
    @IBOutlet weak var aivSearch: UIActivityIndicatorView!
    @IBOutlet weak var btnSelectLocation: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    
    @IBOutlet weak var cstTableViewHeight: NSLayoutConstraint!
    
    var isPreviewLocation = false
    
    
    // MARK: - Properties
    var strTitle: String?
    var completion: ((_ location: LocationModel) -> Void)?
    
    var selectedLocation: LocationModel? = nil {
        didSet {
            btnSelectLocation?.isEnabled = selectedLocation != nil
        }
    }
    
    private var adapter: SelectLocationAdapter!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = SelectLocationAdapter(with: tableView)
        
        if isPreviewLocation {
            viewSearch.isHidden = true
            btnSelectLocation.isHidden = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        setupUI()
    }
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            adapter.tableViewMaxHeight = UIScreen.main.bounds.height - tableView.frame.origin.y - frame.height
        }
    }
    
    init(title: String, selectedLocation: LocationModel? = nil, completion: @escaping (_ location: LocationModel) -> Void) {
        super.init(nibName: SelectLocationController.name, bundle: nil)
        self.selectedLocation = selectedLocation
        self.strTitle = title
        self.completion = completion
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}


// MARK: - Tap Handlers
extension SelectLocationController {
    @IBAction func textDidChange(_ sender: UITextField) {
        let text = sender.text?.trimmed ?? ""
        if text == "" {
            adapter.tableData = []
            adapter.reloadTableData()
            return
        }
        adapter.getLocations(text: text)
    }
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapSelectLocation(_ sender: UIButton) {
        view.endEditing(true)
        
        if let location = selectedLocation {
            completion?(location)
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
}

// MARK: - Utility Methdos
extension SelectLocationController {
    func setupUI() {
        lblTitle.text = strTitle
        mapView.isMyLocationEnabled = true
        txtSearch.text = selectedLocation?.formattAdaddress
        btnSelectLocation.isEnabled = selectedLocation != nil
        if selectedLocation == nil || selectedLocation?.latitude == 0 || selectedLocation?.longitude == 0 {
            LocationManager.shared.getCurrentLocation { (location) in
                self.mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 10, bearing: 0, viewingAngle: 0)
                self.setupMarker(coordinate: location.coordinate)
                self.handleReverseGeocode(coordinate: location.coordinate)
            }
        } else {
            let coordinate = CLLocationCoordinate2D(latitude: selectedLocation?.latitude ?? 0, longitude: selectedLocation?.longitude ?? 0)
            self.mapView.camera = GMSCameraPosition(target: coordinate, zoom: 10, bearing: 0, viewingAngle: 0)
            self.setupMarker(coordinate: coordinate)
            self.handleReverseGeocode(coordinate: coordinate)
        }
    }
    
    
    func setLocation(_ location: LocationModel) {
        
        view.endEditing(true)
        selectedLocation = location
        txtSearch.text = location.formattAdaddress
        if location.latitude == 0 && location.longitude == 0 {
            viewActivityIndicator.isHidden = false
            
            aivSearch.startAnimating()
            location.getDetail {
                self.viewActivityIndicator.isHidden = true
                let zoom = self.mapView.camera.zoom
                let camera = GMSCameraPosition(latitude: location.latitude, longitude: location.longitude, zoom: zoom > 12 ? zoom : 12)
                self.mapView.camera = camera
                self.setupMarker(coordinate: CLLocationCoordinate2D.init(latitude: location.latitude, longitude: location.longitude))
            }
        } else {
            let zoom = self.mapView.camera.zoom
            let camera = GMSCameraPosition(latitude: location.latitude, longitude: location.longitude, zoom: zoom > 12 ? zoom : 12)
            self.mapView.camera = camera
        }
        
    }
    private func setupMarker(coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        let locationMarker = GMSMarker(position: coordinate)
        locationMarker.icon = R.image.location_picker_pin()
        locationMarker.map = mapView
    }
    
    private func handleReverseGeocode(coordinate: CLLocationCoordinate2D) {
        LocationManager.shared.reverseGeocodeCoordinate(coordinate) { (location, errorMessage) in
            self.selectedLocation = location
            self.txtSearch.text = location?.formattAdaddress
        }
    }
    
}

// MARK: - TextField Delegate
extension SelectLocationController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MapView Delegate
extension SelectLocationController: GMSMapViewDelegate {
    //    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    //        let center = mapView.center
    //        let p = mapView.projection.coordinate(for: center)
    //
    ////        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    ////            let center = mapView.center
    ////            let p2 = mapView.projection.coordinate(for: center)
    ////
    ////            if p.latitude == p2.latitude && p.longitude == p2.longitude {
    ////                LocationManager.shared.reverseGeocodeCoordinate(p) { (location, errorMessage) in
    ////                    self.selectedLocation = location
    ////                    self.txtSearch.text = location?.formattAdaddress
    ////                }
    ////            }
    ////
    ////        }
    //
    //    }
}
