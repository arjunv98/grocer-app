//
//  StoreMapViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import MapKit

class StoreMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation: CLLocation!
    var locationManager = CLLocationManager()
    
    convenience init(currentLocation: CLLocation) {
        self.init()
        self.currentLocation = currentLocation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MAP VIEW DID LOAD")

//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.distanceFilter = 100
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        locationManager.startUpdatingLocation()
        
//        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            currentLocation = locationManager.location
//        } else {
//            currentLocation = CLLocation(latitude: 34.0224, longitude: -118.2851)
//        }
        
        updateView()
        mapView.showsUserLocation = true
    }
    
    /*
     * updateLocation - Update mapView to center on current location
     */
    func updateView() {
        let span = MKCoordinateSpan(latitudeDelta: 0.050, longitudeDelta: 0.050)
        let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
