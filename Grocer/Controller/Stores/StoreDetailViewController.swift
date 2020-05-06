//
//  StoreDetailViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI
import RealmSwift

class StoreDetailViewController: UIViewController {
    /*
     * --- IB OUTLETS ----------------------------------------------------------
     */
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeAddress: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var defaultLabel: UILabel!
    @IBOutlet weak var shoppingListLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    /*
     * --- VARIABLES ----------------------------------------------------------
     */
    var selectedStore: Store! // Set in list/map item segue
    var shoppingList: List<Ingredient>!
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    var eventStore: EKEventStore!
    
    /*
     * viewDidLoad
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DETAIL VIEW DID LOAD")
        
        eventStore = EKEventStore.init()
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            print("** PREVIOUS GRANTED AUTH **")
        case .denied:
            print("** DENIED AUTH **")
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if granted {
                    print("** GRANTED AUTH **")
                } else {
                    print("** ERROR: \(error!) **")
                }
            })
        default:
            print("** DEFAULT CASE **")
        }
        
        // Set values for labels in view
        storeName.text = selectedStore.name
        storeAddress.text = selectedStore.location?.address
        distanceLabel.text = selectedStore.distanceToKmString() + " kilometers away"
        saveButton.isSelected = selectedStore.isSaved
        shoppingList = selectedStore.shoppingList
        
        editButton.setTitle("Add", for: .normal)
        if !shoppingList.isEmpty {
            editButton.setTitle("Edit", for: .normal)
        }
        
        updateView()
    }
    
    
    /*
     * --- IB ACTIONS ----------------------------------------------------------
     */
    /*
     * didTapSaveButton - Toggles store save state, and updates view based on state
     */
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        // change values of isSaved state
        saveButton.isSelected = !saveButton.isSelected
        let realm = try! Realm(configuration: configuration)
        try! realm.write {
            selectedStore.isSaved = saveButton.isSelected
        }
        
        updateView()
    }
    
    /*
     * didTapCalendarButton - Directs to add calendar event modal
     */
    @IBAction func didTapCalendarButton(_ sender: UIButton) {
        if EKEventStore.authorizationStatus(for: .event) == .authorized {
            let eventViewController = EKEventEditViewController.init()
            let event = EKEvent.init(eventStore: self.eventStore)
            
            event.title = "Go grocery shopping"
            event.startDate = Date()
            event.endDate = Date()
            event.location = selectedStore.location?.address
            
            eventViewController.event = event
            eventViewController.eventStore = self.eventStore
            eventViewController.editViewDelegate = self
            
            present(eventViewController, animated: true, completion: nil)
            
        } else {
            let message = "Calendar access unauthorized"
            let alert = UIAlertController(title: "An Error Occurred", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func updateView() {
        if saveButton.isSelected {
            calendarButton.isHidden = false
            shoppingListLabel.isHidden = false
            tableView.isHidden = false
            editButton.isHidden = false
            
            defaultLabel.isHidden = true
            
            tableView.reloadData()
        } else {
            calendarButton.isHidden = true
            shoppingListLabel.isHidden = true
            tableView.isHidden = true
            editButton.isHidden = true
            
            defaultLabel.isHidden = false
        }
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
 * --- TABLE VIEW --------------------------------------------------------------
 */
extension StoreDetailViewController: UITableViewDelegate, UITableViewDataSource {
    /*
     * numberOfSections - Return number of sections in table view
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     * tableView(_:numberOfRowsInSection:) - Return number of shopping list items for table view
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    /*
     * tableView(_:cellForRowAt:) - Configures table cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicIngredientCell", for: indexPath)
        let ingredient = shoppingList[indexPath.row]
        cell.textLabel?.text = ingredient.name
        
        return cell
    }
}

extension StoreDetailViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        print("DISMISS CALENDAR")
        controller.dismiss(animated: true, completion: nil)
    }
}
