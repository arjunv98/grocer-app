//
//  StoreMapViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class StoreMapViewController: UIViewController {

    /*
    * IB Outlets
    */
    @IBOutlet weak var mapView: MKMapView!
    
    /*
    * Variables
    */
    var currentLocation: CLLocation! // updated from parent
    var locationManager = CLLocationManager()
    var stores = try! Realm().objects(Store.self) // access to Store DB
    private var annotations = [MKAnnotation]()
    
    /*
     * viewDidLoad - Initial view load
     */
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
     * updateView - Update mapView to center on current location, and load in annotations
     */
    func updateView() {
        print("*** UPDATE MAP VIEW ***")
        print("*(\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude))*")
        stores = try! Realm().objects(Store.self)
        for name in stores {
            print(name.name)
        }
        updateAnnotations()
        let span = MKCoordinateSpan(latitudeDelta: 0.050, longitudeDelta: 0.050)
        let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    /*
     * updateAnnotations - Update store markers on map
     */
    func updateAnnotations() {
        print("** UPDATE MAP ANNOTATIONS **")
        mapView.removeAnnotations(annotations)
        annotations = stores.map { store in
            let annotation = MKPointAnnotation()
            let storeCoordinate = CLLocationCoordinate2D(latitude: store.location!.latitude, longitude: store.location!.longitude)
            annotation.coordinate = storeCoordinate
            annotation.title = store.name
            return annotation
        }
        mapView.addAnnotations(annotations)
        mapView.showAnnotations(annotations, animated: true)
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

extension StoreMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // todo
        return nil
    }
}
