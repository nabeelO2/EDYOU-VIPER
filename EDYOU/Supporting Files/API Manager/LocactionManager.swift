//
//  LocactionManager.swift
//  Carzly
//
//  Created by Zuhair Hussain on 24/06/2019.
//  Copyright © 2019 Zuhair Hussain. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
//    let manager = APIManagerBase()
    
    
    let placesGoogleURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=AIzaSyA_0u63uVi91MmmNohhRYPfy1udavnfEOM&input="
    let googlePlaceDetail = "https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyA_0u63uVi91MmmNohhRYPfy1udavnfEOM&placeid="
    
    let placeReverseGeocode = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyA_0u63uVi91MmmNohhRYPfy1udavnfEOM&latlng="
    
    private var locationManager = CLLocationManager()
    private var locationCallback: ((_ location: CLLocation) -> Void)?
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
    }
    
    let googleRouteURL = "https://maps.googleapis.com/maps/api/directions/json?mode=driving&key=AIzaSyA_0u63uVi91MmmNohhRYPfy1udavnfEOM"
    
    func routePointsURL(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> String? {
        let url = googleRouteURL + "&origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)"
        return url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    
    
    func getGooglePlaces(text: String, completion: @escaping (_ locations: [LocationModel], _ error: String?) -> Void) {
        
        let urlString = (placesGoogleURL + text + "&language=en").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: urlString ?? "") else { return }
        
        
        
        getRequest(url: url, header: [:]) { response, error in
            
            var locations = [LocationModel]()
        
            if let result = response as? NSDictionary {
                if let predictions = result["predictions"] as? [NSDictionary] {
                    for p in predictions {
                        locations.append(LocationModel(prediction: p))
                    }
                }
            }
            completion(locations, error)
            
        }
        
    }
    func getPlaceDetail(placeId: String, completion: @escaping (_ locations: LocationModel, _ status: String?) -> Void) {
        
        let urlString = (googlePlaceDetail + placeId + "&language=en").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: urlString ?? "") else { return }
        getRequest(url: url, header: [:]) { response, error in
            
            let location = LocationModel()
            
            if let result = response as? NSDictionary {
                if let r = result["result"] as? NSDictionary {
                    location.formattAdaddress = r.string(for: "formatted_address")
                    location.country = (r["address_components"] as? [NSDictionary])?.last?.string(for: "long_name") ?? ""
                    if let geometry = r["geometry"] as? NSDictionary {
                        location.latitude = (geometry["location"] as? NSDictionary)?.double(for: "lat") ?? 0
                        location.longitude = (geometry["location"] as? NSDictionary)?.double(for: "lng") ?? 0
                    }
                }
            }
            completion(location, error)
            
        }
        
    }
    
    
    func getRoutePoints(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion: @escaping (_ status: Bool, _ message: String, _ points: String) -> Void) {
        
        let urlString = routePointsURL(origin: origin, destination: destination)
        guard let url = URL(string: urlString ?? "") else {
            completion(false, "Invalid url", "")
            return
        }
        
        
        
        
        getRequest(url: url, header: [:]) { response, error in
            
            var points = ""
            
            if let result = response as? NSDictionary {
                if let r = (result["routes"] as? [NSDictionary])?.first {
                    if let polyline = r["overview_polyline"] as? NSDictionary {
                        points = (polyline["points"] as? String) ?? ""
                    }
                }
            }
            
            completion(true, "", points)
            
        }
    }
    
//    func reverseGeocodeCoordinate(_ coordinates:CLLocationCoordinate2D, completion: @escaping (_ location: LocationModel?, _ message: String) -> Void) {
//
//        GMSGeocoder().reverseGeocodeCoordinate(coordinates) { (response, error) in
//            DispatchQueue.main.async {
//                if error == nil {
//                    let location = LocationModel()
//                    var address:String = ""
//
//                    guard let response = response else {
//                        completion(nil, "")
//                        return
//                    }
//                    guard let result  = response.firstResult() else {
//                        completion(nil, "")
//                        return
//                    }
//                    guard let lines  = result.lines else {
//                        completion(nil, "")
//                        return
//                    }
//
//
//                    switch(lines.count) {
//                    case 1:
//                        address = lines[0]
//                        break;
//                    case 2:
//                        address = lines[0]
//                        address =  address + ", " + lines[1]
//                        break;
//                    default:
//                        break;
//                    }
//
//                    if let data  = result.country?.trimmed {
//                        if address.lowercased().contains(data.lowercased()) == false {
//                            address =  address + ", " + data
//                        }
//
//                    }
//                    location.formattAdaddress = address
//                    location.latitude = coordinates.latitude
//                    location.longitude = coordinates.longitude
//                    location.country = result.country ?? ""
//
//                    completion(location, "")
//                } else {
//                    completion(nil, error!.localizedDescription)
//                }
//            }
//        }
//    }
    
    func reverseGeocodeCoordinate(_ coordinates:CLLocationCoordinate2D, completion: @escaping (_ location: LocationModel?, _ message: String) -> Void) {
        let urlString = (placeReverseGeocode + coordinates.toString + "&language=en").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: urlString ?? "") else { return }
        getRequest(url: url, header: [:]) { response, error in
            let location = LocationModel()
            if let result = response as? NSDictionary {
                if let r = (result["results"] as? [NSDictionary])?.first {
                    location.formattAdaddress = r.string(for: "formatted_address")
                    if let geometry = r["geometry"] as? NSDictionary {
                        location.latitude = (geometry["location"] as? NSDictionary)?.double(for: "lat") ?? 0
                        location.longitude = (geometry["location"] as? NSDictionary)?.double(for: "lng") ?? 0
                    }
                    location.placeId = r["place_id"] as? String ?? ""
                    
                    if let addressComponents = r["address_components"] as? [NSDictionary] {
                        for component in addressComponents {
                            if let types =  component["types"] as? [String] {
                                if types.contains("country") {
                                    location.country = component["long_name"] as? String ?? ""
                                }
                            }
                        }
                    }
                }
            }
            completion(location, error ?? "")
        }
    }
    
}


extension LocationManager: CLLocationManagerDelegate {
    func getCurrentLocation(_ completion: @escaping (_ location: CLLocation) -> Void) {
        locationCallback = completion
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() ==  .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        
        locationCallback?(location)
    }
}


extension LocationManager {
    
    
    
    func getRequest(url: URL, header: [String: String], completion: @escaping(_ result: Any?, _ error: String?) -> Void) {

        
        var request = URLRequest(url: url)
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
                
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        print("[Location Manager] url: \(url.absoluteString)")
                        print(jsonResponse)
                        completion(jsonResponse, nil)
                    } else if  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [NSDictionary] {
                        print("[Location Manager] url: \(url.absoluteString)")
                        print(jsonResponse)
                        completion(jsonResponse, nil)
                    } else {
                        completion(nil, "Invalid response")
                    }
                    
                    
                } else {
                    completion(nil, "Empty response")
                }
            }
            
        }

        task.resume()
    }
    
    
}


extension CLLocationCoordinate2D {
    var toString : String {
        return "\(self.latitude),\(self.longitude)"
    }
}
