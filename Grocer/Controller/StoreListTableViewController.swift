//
//  StoreListTableViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import CoreLocation
import RealmSwift

class StoreListTableViewController: UITableViewController {
    
    /*
     * --- IB OUTLETS ----------------------------------------------------------
     */
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    /*
     * --- VARIABLES -----------------------------------------------------------
     */
    var currentLocation: CLLocation! // updated from parent
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    var storesList: Results<Store>!
    var selection = "All"
    
    /*
     * viewDidLoad - Initial view load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LIST VIEW DID LOAD")
        
        selection = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
        updateView()
    }
    
    
    /*
     * --- IB ACTIONS ----------------------------------------------------------
     */
    
    /*
     * didChangeSegmentedControl - Changes result scope and calls for result update
     */
    @IBAction func didChangeSegmentedControl(_ sender: UISegmentedControl) {
        selection = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        updateView()
    }
    
    
    /*
     * --- HELPER FUNCTIONS ----------------------------------------------------
     */
    
    /*
     * updateView - Update table view to list either saved or nearby stores
     */
    func updateView() {
        print("*** UPDATE LIST VIEW ***")
        let stores = try! Realm(configuration: configuration).objects(Store.self).sorted(byKeyPath: "distance")
        switch selection {
        case "Saved":
            storesList = stores.filter("isSaved == true")
        case "All":
            storesList = stores
        case "Nearby":
            storesList = stores.filter("isNearby == true")
        default:
            storesList = stores
        }
        
        print("** UPDATE LIST FOR \(selection.uppercased()) **")
        tableView.reloadData()
    }
    
     /*
     * prepare(for:sender:) - Prepares segue to detail view controller
     */
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListStoreDetailSegue" {
            let controller = segue.destination as! StoreDetailViewController
            let cell = sender as! StoreCell
            controller.selectedStore = cell.store
            controller.presentationController?.delegate = self
        }
     }
}


/*
 * --- TABLE VIEW --------------------------------------------------------------
 */
extension StoreListTableViewController {
    /*
     * numberOfSections - Return number of sections in table view
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     * tableView(_:numberOfRowsInSection:) - Return number of store items for table view
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storesList.count
    }
    
    /*
     * tableView(_:cellForRowAt:) - Configures table cells
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: StoreCell.reuseIdentifier) as? StoreCell {
            cell.initializeCell(with: storesList[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    /*
     * tableView(_:didSelectRowAt:) - Select correct cell and segue to detail view
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ListStoreDetailSegue", sender: cell)
    }
}


/*
 * --- DETAIL VIEW TRANSITION --------------------------------------------------
 */
extension StoreListTableViewController: UIAdaptivePresentationControllerDelegate {
    /*
     * presentationControllerDidDismiss - Reloads map data when detail view is dismissed
     */
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("DISMISSED DETAIL VIEW TO LIST")
        updateView()
    }
}
