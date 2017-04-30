//
//  CurrentLocationView.swift
//  Taxi
//
//  Created by mohamed hassan on 4/25/17.
//  Copyright © 2017 mohamed hassan. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class CurrentLocationView: UIViewController {
    
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    
    var currentPlaceButton: UIButton!
    var add : String!
    
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
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        
        // Adding current button to the mapView
        self.currentPlaceButton = UIButton(frame: CGRect(x: 0, y: (self.mapView.frame.height/2)-15, width: self.mapView.frame.width, height: 30))
        self.currentPlaceButton.backgroundColor = .gray
        self.currentPlaceButton.titleLabel?.minimumScaleFactor = 0.5
        self.currentPlaceButton.titleLabel?.numberOfLines = 1
        self.currentPlaceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.currentPlaceButton.setTitle("Updating location .....", for: .normal)
        self.currentPlaceButton.addTarget(self, action: #selector(goToNextPage), for: .touchUpInside)
        self.mapView.addSubview(self.currentPlaceButton)
        
        // Move the camera to current user location
        self.getCurrentAddress()
        
    }
    
    
  
    // Get current address by google places api
    func getCurrentAddress () {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.currentPlaceButton.setTitle("No current place", for: .normal)
            self.currentPlaceButton.setTitle(" ", for: .normal)

            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    //self.nameLabel.text = place.name
                    self.add = place.formattedAddress?.components(separatedBy: " ")
                        .joined(separator: " ")
                    print("=========\(self.add)")
                    self.currentPlaceButton.setTitle(self.add, for: .normal)
                }
            }
        })
    }
    
    
    
    
    // If user tap current location button it will redirect to the next page (Destination page)
     func goToNextPage() {
        print("kkkk\(self.add)")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadSubViews"), object: self.add);
    }
    
    
    
}

extension CurrentLocationView : CLLocationManagerDelegate {
    
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
