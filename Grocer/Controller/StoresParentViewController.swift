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
     * IB Outlets
     */
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    
    /*
     * Variables
     */
    var currentLocation: CLLocation = CLLocation(latitude: 34.0224, longitude: -118.2851)
    var locationManager = CLLocationManager()
    
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
    
    private var tableViewActive = true
    var stores = try! Realm().objects(Store.self)
    
    
    /*
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PARENT VIEW DID LOAD")
        
        // get realm file address
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // initialize location
        locationManager.delegate = self
        // request location access
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("** REQUESTING NEW LOCATION **")
            locationManager.requestLocation()
        }
        
        // load view
        updateView()
    }
    
    /*
     * IB Actions
     */
    /*
     * didTapButton - Toggle between table view and map view of stores
     */
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
        // update current location in parent and child view controllers
        getCurrentLocation()
        updateChildLocations()
        
        // Search for nearby food markets and update Store DB
        searchForFoodMarket()
        
        if tableViewActive {
            removeView(asChildViewController: mapViewController)
            addView(asChildViewController: tableViewController)
            toggleButton.title = "Map"
        } else {
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
                self?.updateStores(mapItems: response.mapItems)
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
    private func updateStores(mapItems: [MKMapItem]) {
        print("*** UPDATE STORE LIST ***")
        let mapItems = mapItems
        let realm = try! Realm()
        let oldStores = realm.objects(Store.self).filter("isSaved == false")
        try! realm.write {
            for store in oldStores {
                realm.delete(store.location!)
                realm.delete(store)
            }
            for mapItem in mapItems {
                let store = Store()
                let location = Location()
                location.latitude = mapItem.placemark.coordinate.latitude
                location.longitude = mapItem.placemark.coordinate.longitude
                location.address = mapItem.placemark.title ?? "N/A"
                
                store.name = mapItem.placemark.name ?? "N/A"
                store.location = location
                
                realm.add(store)
            }
        }
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
        let location = locations.last! as CLLocation
        
        // Set current location on parent and child view controllers
        currentLocation = location
        updateChildLocations()
        
        // Set latitude, longitude, and zoom
//        let latitude = location.coordinate.latitude
//        let longitude = location.coordinate.longitude
//        let span = MKCoordinateSpan(latitudeDelta: 0.050, longitudeDelta: 0.050)
//        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
    }
    
    /*
     * locationManager(_:didFailWithError:) - Called when failure to retrieve location data
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let message = "\(error.localizedDescription)\n\nUnable to retrieve location"
        let alert = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    /*
     * getCurrentLocation - Retrieves current location from locationManager and updates currentLocation
     */
    func getCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled() {
            print("*** SET TO DEFAULT LOCATION ***")
            currentLocation = CLLocation(latitude: 34.0224, longitude: -118.2851) // USC
        } else if status == .notDetermined {
            // Request authorization if undetermined
            locationManager.requestWhenInUseAuthorization()
        } else {
            print("** REQUESTING NEW LOCATION **")
            locationManager.requestLocation()
        }
    }
    
    /*
     * updateChildLocations - Updates currentLocation in both child view controllers
     */
    func updateChildLocations() {
        print("** UPDATE LOCATION TO (\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)) **")
        mapViewController.currentLocation = currentLocation
        tableViewController.currentLocation = currentLocation
    }
}
