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
     * --- IB OUTLETS ----------------------------------------------------------
     */
    @IBOutlet weak var mapView: MKMapView!
    
    
    /*
     * --- VARIABLES -----------------------------------------------------------
     */
    var currentLocation: CLLocation! // updated from parent
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    private var annotations = [StoreAnnotation]()
    
    /*
     * viewDidLoad - Initial view load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MAP VIEW DID LOAD")
        
//        mapView.delegate = self
        mapView.register(StoreMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        updateView()
        mapView.showsUserLocation = true
    }
    
    
    /*
     * --- HELPER FUNCTIONS ----------------------------------------------------
     */
    
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
            let annotation = StoreAnnotation(store: store)
            return annotation
        }
        
        mapView.addAnnotations(annotations)
        //        mapView.showAnnotations(annotations, animated: true)
    }
    
    /*
     * prepare(for:sender:) - Prepares segue to detail view controller
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapStoreDetailSegue" {
            let controller = segue.destination as! StoreDetailViewController
            let storeAnnotation = sender as! StoreAnnotation
            controller.selectedStore = storeAnnotation.store
            controller.presentationController?.delegate = self
        }
    }
    
}


/*
 * MAP ANNOTATIONS
 */
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


/*
* --- DETAIL VIEW TRANSITION --------------------------------------------------
*/
extension StoreMapViewController: UIAdaptivePresentationControllerDelegate {
    /*
     * presentationControllerDidDismiss - Reloads map data when detail view is dismissed
     */
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("DISMISSED DETAIL VIEW TO MAP")
        updateView()
    }
}
