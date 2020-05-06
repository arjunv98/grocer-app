//
//  StoresParentViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class StoresParentViewController: UIViewController {
    
    /*
     * IB OUTLETS
     */
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    
    /*
     * VARIABLES
     */
    var currentLocation: CLLocation = CLLocation(latitude: 34.0224, longitude: -118.2851) // default location is USC
    var locationManager = CLLocationManager()
    // exposed view controller variables
    private lazy var mapViewController: StoreMapViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(identifier: "StoreMapViewController") as! StoreMapViewController
        viewController.currentLocation = currentLocation
        self.addView(asChildViewController: viewController)
        return viewController
    }()
    private lazy var tableViewController: StoreListTableViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewController = storyboard.instantiateViewController(identifier: "StoreListTableViewController") as! StoreListTableViewController
        viewController.currentLocation = currentLocation
        self.addView(asChildViewController: viewController)
        return viewController
    }()
    private var tableViewActive = true // used to toggle between table and map views
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    
    /*
     * viewDidLoad - Initial view load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("--- PARENT VIEW DID LOAD ---")
        
        // get realm file address
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // initialize location
        locationManager.delegate = self
        // request location access
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("* LOCATION AUTHORIZED *")
            requestCurrentLocation() // begin receiving current location
        }
        
        // load view
        updateView()
    }
    
    /*
     * IB ACTIONS
     */
    /*
     * didTapSaveButton - Toggle between table view and map view of stores
     */
    @IBAction func didTapButton(_ sender: Any) {
        print("* BUTTON TAPPED *")
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
        print("*** UPDATE PARENT VIEW ***")
        
        // update current location in child view controllers
        updateChildLocations()
        
        // Search for nearby food markets and update Store DB
        searchForFoodMarket()
        
        if tableViewActive {
            print("** SWITCH TO LIST **")
            removeView(asChildViewController: mapViewController)
            addView(asChildViewController: tableViewController)
            tableViewController.updateView()
            toggleButton.title = "Map"
        } else {
            print("** SWITCH TO MAP **")
            removeView(asChildViewController: tableViewController)
            addView(asChildViewController: mapViewController)
            mapViewController.updateView()
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
        print("** SEARCH FOR FOOD MARKETS **")
        let request = MKLocalSearch.Request()
        
        // only interested in food markets
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.foodMarket])
        
        // search in 8km radius of currently location
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 16000, longitudinalMeters: 16000)
        
        // address results are irrelevant
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self](response, error) in
            if let error = error {
                self?.handleSearchError(error)
            } else if let response = response {
                self?.updateStores(mapItems: response.mapItems)
            }
        }
    }
    
    /*
     * handleSearchError - Presents error alert on search error
     */
    private func handleSearchError(_ error: Error) {
        print("!!! SEARCH ERROR !!!")
        let message = "\(error.localizedDescription)\n\nPlease try again later"
        let alert = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    /*
     * updateStores - Updates stores in Realm DB
     */
    private func updateStores(mapItems: [MKMapItem]) {
        print("*** UPDATE STORE LIST ***")
        let mapItems = mapItems
        let realm = try! Realm(configuration: configuration)
        let stores = realm.objects(Store.self)
        let oldStores = stores.filter("isSaved == false")
        try! realm.write {
            // remove unsaved stores
            for store in oldStores {
                if let location = store.location {
                    realm.delete(location)
                }
                realm.delete(store)
            }
            // update distance on remaining stores and remove from 'nearby' region
            for store in stores {
                if let location = store.location {
                    store.distance = currentLocation.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
                }
                store.isNearby = false
            }
            // get and set results
            for mapItem in mapItems {
                let store = Store()
                let location = Location()
                
                // set location and distance
                location.latitude = mapItem.placemark.coordinate.latitude
                location.longitude = mapItem.placemark.coordinate.longitude
                location.address = mapItem.placemark.title ?? "N/A"
                let distance = currentLocation.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
                
                // set store details
                store.name = mapItem.placemark.name ?? "N/A"
                store.distance = distance
                store.location = location
                store.isNearby = true
                
                // create unique store id and check if store exists
                store.createID(name: store.name, location: store.location!)
                let match = stores.filter("id == '\(store.id)'").count > 0
                if match {
                    store.isSaved = true
                }
                
                realm.add(store, update: .modified)
            }
        }
        // update child controller view data
        mapViewController.updateView()
        tableViewController.updateView()
    }
}

/*
 * LOCATION
 */
extension StoresParentViewController: CLLocationManagerDelegate {
    /*
     * locationManager(_:didChangeAuthorization:) - Called when location authorization has changed
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("*** AUTHORIZATION STATUS CHANGE ***")
        
        switch status {
        case .authorizedAlways:
            print("** ALWAYS AUTH **")
        case .authorizedWhenInUse:
            print("** IN USE AUTH **")
        case .denied:
            print("** DENIED AUTH **")
        case .restricted:
            print("** RESTRICTED AUTH **")
        case .notDetermined:
            print("** UNDETERMINED AUTH **")
        @unknown default:
            print("** UNDETERMINED AUTH **")
        }
        
        // Request location if authorization given
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("** REQUESTING NEW LOCATION **")
            manager.requestLocation()
        }
    }
    
    /*
     * locationManager(_:didUpdateLocations:) - Called when current location is requested and updated
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("** LOCATION MANAGER UPDATE CALLED **")
        let location = locations.last! as CLLocation
        
        // Set current location
        currentLocation = location
        
        // Update view
        updateView()
    }
    
    /*
     * locationManager(_:didFailWithError:) - Called when failure to retrieve location data
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("!!! LOCATION ERROR !!!")
        currentLocation = CLLocation(latitude: 34.0224, longitude: -118.2851) // USC
        updateView()
        let message = "\(error.localizedDescription)\n\nUnable to retrieve location"
        let alert = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    /*
     * requestCurrentLocation - Begins location requests, or sets currentLocation to default
     */
    func requestCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
            print("* SET TO DEFAULT LOCATION *")
            currentLocation = CLLocation(latitude: 34.0224, longitude: -118.2851) // USC
        } else if status == .notDetermined {
            // Request authorization if undetermined
            print("* UNDETERMINED LOCATION *")
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("* REQUESTING CURRENT LOCATION *")
            locationManager.startUpdatingLocation()
        }
    }
    
    /*
     * updateChildLocations - Updates currentLocation in both child view controllers
     */
    func updateChildLocations() {
        print("** UPDATE CHILD LOCATIONS TO (\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)) **")
        mapViewController.currentLocation = currentLocation
        tableViewController.currentLocation = currentLocation
    }
}
