//
//  DestinationView.swift
//  Taxi
//
//  Created by mohamed hassan on 4/29/17.
//  Copyright © 2017 mohamed hassan. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class DestinationView: UIViewController , GMSMapViewDelegate{
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    
    var currentPlaceButton: UIButton!
    var destinationPlaceButton: UIButton!
    
    
    var currentLocationFromOtherPage : String!
    
    var destinationAddress : String!
    var coordinate : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        
        // -----
        let camera = GMSCameraPosition.camera(withLatitude: 30.0,longitude: 30.0,zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        
        // adding cuurent button to the mapView
        self.currentPlaceButton = UIButton(frame: CGRect(x: 0, y: (self.mapView.frame.height/2)-40, width: self.mapView.frame.width, height: 30))
        self.currentPlaceButton.backgroundColor = .gray
        self.currentPlaceButton.titleLabel?.minimumScaleFactor = 0.5
        self.currentPlaceButton.titleLabel?.numberOfLines = 1
        self.currentPlaceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.mapView.addSubview(self.currentPlaceButton)
        
        
        
        // adding destination button to the mapView
        self.destinationPlaceButton = UIButton(frame: CGRect(x: 0, y: (self.mapView.frame.height/2)+40, width: self.mapView.frame.width, height: 30))
        self.destinationPlaceButton.backgroundColor = .gray
        self.destinationPlaceButton.titleLabel?.minimumScaleFactor = 0.5
        self.destinationPlaceButton.titleLabel?.numberOfLines = 1
        self.destinationPlaceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.destinationPlaceButton.addTarget(self, action: #selector(AddPinToDestination), for: .touchUpInside)
        self.mapView.addSubview(self.destinationPlaceButton)
        self.mapView.delegate = self
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        // Assign current address to current address button
        self.currentPlaceButton.setTitle(self.currentLocationFromOtherPage, for: .normal)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
        // Detect user tap (Destination location)
        let geocoder = GMSGeocoder()
        self.coordinate = CLLocationCoordinate2DMake(Double(coordinate.latitude), Double(coordinate.longitude))
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            if let address = response?.firstResult() {
                
                let lines = address.lines
                
                self.destinationAddress = (lines?.joined(separator: " "))!
                self.destinationPlaceButton.setTitle(self.destinationAddress, for: .normal)
            }
        }
        
    }
    
    // Adding marker to destination location
    func AddPinToDestination() {
        let marker = GMSMarker(position: self.coordinate)
        marker.title = self.destinationAddress
        marker.map = mapView
        
    }
    
    
    
}


extension DestinationView : CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        
    }
    
    
    
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
            
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
