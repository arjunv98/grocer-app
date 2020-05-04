//
//  StoresParentViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import MapKit

class StoresParentViewController: UIViewController, CLLocationManagerDelegate {

    /*
     * IB Outlets
     */
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    @IBOutlet var mainView: UIView!
    
    /*
     * Variables
     */
    var currentLocation: CLLocation!
    var locationManager = CLLocationManager()
    
    private lazy var mapViewController: StoreMapViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(identifier: "StoreMapViewController") as! StoreMapViewController
        self.addView(asChildViewController: viewController)
        return viewController
    }()
    private lazy var tableViewController: StoreListTableViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(identifier: "StoreListTableViewController") as! StoreListTableViewController
        self.addView(asChildViewController: viewController)
        return viewController
    }()
    
    private var tableViewActive = true
//    var stores = try! Realm().objects(Store.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        print(Realm.Configuration.defaultConfiguration.fileURL!)
                
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                currentLocation = CLLocation(latitude: 34.0224, longitude: -118.2851)
                if let currentLocation = currentLocation {
                    print(currentLocation.coordinate.latitude)
                }
                
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                    print("THIS")
        //            locationManager.distanceFilter = 100
        //            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //            locationManager.startUpdatingLocation()
        //            currentLocation = locationManager.location
                } else {
                    print("THAT")
                }
                if let currentLocation = currentLocation {
                    print(currentLocation.coordinate.latitude)
                }
                
                updateView()
                
                searchForFoodMarket()
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        tableViewActive = !tableViewActive
        updateView()
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

/*
 * CHILD VIEW CONTROLLERS
 */
extension StoresParentViewController {
    /*
     * addView - Add child view controller to parent view controller
     */
    private func addView(asChildViewController viewController: UIViewController) {
        // add child view controller
        addChild(viewController)
        
        // add child view
        view.addSubview(viewController.view)
        
        // configure view
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
    }
    
    /*
     * removeView - Remove child view controller from parent view controller
     */
    private func removeView(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        
        // remove child view
        viewController.view.removeFromSuperview()
        
        // remove child view controller
        viewController.removeFromParent()
    }
    
    /*
     * updateView - Update parent view based on button toggle
     */
    private func updateView() {
        if tableViewActive {
            removeView(asChildViewController: mapViewController)
            addView(asChildViewController: tableViewController)
            toggleButton.title = "Map"
        } else {
            removeView(asChildViewController: tableViewController)
            addView(asChildViewController: mapViewController)
            toggleButton.title = "List"
        }
    }
}

/*
 * SEARCH
 */
extension StoresParentViewController {
    /*
     * searchForFoodMarket - Searches for food markets in 5km radius of current location
     */
    private func searchForFoodMarket() {
        let request = MKLocalSearch.Request()
        
        // only interested in food markets
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.foodMarket])
        
        // search in 5km radius of currently location
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        // address results are irrelevant
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self](response, error) in
            if let error = error {
                self?.handleSearchError(error)
            } else if let response = response {
//                self?.updateStores(mapItems: response.mapItems)
            }
        }
    }
    
    /*
     * handleSearchError - Presents error alert on search error
     */
    private func handleSearchError(_ error: Error) {
        let message = "\(error.localizedDescription)\n\nPlease try again later"
        let alert = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    /*
     * updateStores - Updates stores in Realm DB
     */
//    private func updateStores(mapItems: [MKMapItem]) {
//        print("GOT TO UPDATE")
//        let mapItems = mapItems
//        let realm = try! Realm()
//        let oldStores = realm.objects(Store.self).filter("isSaved == false")
//        try! realm.write {
//            for store in oldStores {
//                realm.delete(store)
//            }
//            for mapItem in mapItems {
//                let store = Store()
//                let location = Location()
//                location.latitude = mapItem.placemark.coordinate.latitude
//                location.longitude = mapItem.placemark.coordinate.longitude
//                location.address = mapItem.placemark.title ?? "N/A"
//
//                store.name = mapItem.placemark.name ?? "N/A"
//                store.location = location
//
//                realm.add(store)
//            }
//        }
//    }
}
