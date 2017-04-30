//
//  ViewController.swift
//  Taxi
//
//  Created by mohamed hassan on 4/25/17.
//  Copyright © 2017 mohamed hassan. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class MainView: UIViewController {

    // Other view controllers that will be show here in the main view
    var currentLocationV : CurrentLocationView!
    var destinationLocationV : DestinationView!
    
    // The main view
    @IBOutlet weak var mainView: UIView!
    
    // Flag to know who will be show (current or destination view)
    var isCurrentLocationViewShownFlag : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register a global func as a notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MainView.loadSubViews),
            name: NSNotification.Name(rawValue: "loadSubViews"),
            object: nil)
        
        // check availability onf internet connection
        if Reachability.isConnectedToNetwork() == false {
            
            // if there is no internet connection
            let alert = UIAlertView(title: "Error", message: "Please make sure of your internet connection", delegate: nil, cancelButtonTitle: "OK")
            alert.alertViewStyle = .default
            alert.show()
            return
            
        }
        
        
        
        // First time to call it , it will show the current view controller
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadSubViews"), object: nil);
        
        
    }

    
    func loadSubViews(notification : NSNotification) {
        
        if isCurrentLocationViewShownFlag {
            
            // It will show the destination view controller and pass the current location to it
            loadDestinationLocationView(currentLocationString: notification.object as! String)
            isCurrentLocationViewShownFlag = false
        }
        
        else {
            
            // It will show the current view controller
            loadCurrentLocationView()
            isCurrentLocationViewShownFlag = true
        }
    }
    
    
    func loadCurrentLocationView() {
        self.currentLocationV = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "currentLocationV") as! CurrentLocationView
        
        self.currentLocationV.view.frame = CGRect(x: 0, y: 0, width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
        self.mainView.addSubview(currentLocationV.view)
        self.addChildViewController(currentLocationV)
    }

    
    func loadDestinationLocationView(currentLocationString : String) {
        self.destinationLocationV = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "destinationView") as! DestinationView
        
        self.destinationLocationV.view.frame = CGRect(x: 0, y: 0, width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
        
        // Passing the current location to the destination view
        print("test kkkkkkk\(currentLocationString)")
        self.destinationLocationV.currentLocationFromOtherPage = currentLocationString
        
        self.mainView.addSubview(destinationLocationV.view)
        self.addChildViewController(destinationLocationV)
    }
    

}

