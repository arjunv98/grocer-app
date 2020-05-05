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
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    private var annotations = [StoreAnnotation]()
    
    /*
     * viewDidLoad - Initial view load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MAP VIEW DID LOAD")
        
        mapView.delegate = self
        mapView.register(StoreMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        updateView()
        mapView.showsUserLocation = true
    }
    
    /*
     * updateView - Update mapView to center on current location, and load in annotations
     */
    func updateView() {
        print("*** UPDATE MAP VIEW ***")
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
        
        let stores = try! Realm(configuration: configuration).objects(Store.self)
        // create list of custom storeAnnotation objects
        annotations = stores.map { store in
            let coordinate = CLLocationCoordinate2D(latitude: store.location!.latitude, longitude: store.location!.longitude)
            let name = store.name
            let distance = currentLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            let annotation = StoreAnnotation(coordinate: coordinate, name: name, distance: distance, store: store)
            
            return annotation
        }
        
        mapView.addAnnotations(annotations)
//        mapView.showAnnotations(annotations, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapStoreDetailSegue" {
            let controller = segue.destination as! StoreDetailViewController
            let storeAnnotation = sender as! StoreAnnotation
            controller.selectedAnnotation = storeAnnotation
        }
    }

}

extension StoreMapViewController: MKMapViewDelegate {    
    /*
     * mapView(_:annotationView:calloutAccessoryControlTapped:)
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let storeAnnotation = view.annotation as? StoreAnnotation {
            performSegue(withIdentifier: "MapStoreDetailSegue", sender: storeAnnotation)
        }
    }
}
