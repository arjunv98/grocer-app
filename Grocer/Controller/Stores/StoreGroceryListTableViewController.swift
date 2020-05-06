//
//  StoreGroceryListTableViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/5/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import RealmSwift

class StoreGroceryListTableViewController: UITableViewController {
    /*
     * --- IB OUTLETS ----------------------------------------------------------
     */
    
    
    /*
     * --- VARIABLES -----------------------------------------------------------
     */
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    var ingredientsList: Results<Ingredient>!
    var selectedStore: Store!
    
    
    /*
     * viewDidLoad - Initial view load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow for checkmarks
        self.tableView.allowsMultipleSelection = true
        
        updateView()
    }
    
    /*
     * IB ACTIONS
     */
    @IBAction func didTapSaveButton(_ sender: Any) {
        print("UPDATING GROCERY LIST")
        let cells = self.tableView.visibleCells as! Array<ExpandedGroceryListCell>
        
        // write to realm
        let realm = try! Realm(configuration: configuration)
        try! realm.write {
            selectedStore.groceryList.removeAll()
            for cell in cells {
                if cell.accessoryType == UITableViewCell.AccessoryType.checkmark {
                    selectedStore.groceryList.append(cell.ingredient!)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
     * --- HELPER FUNCTIONS ----------------------------------------------------
     */
    
    /*
     * updateView - Update table view to list either saved or nearby stores
     */
    func updateView() {
        print("** UPDATE GROCERY LIST VIEW **")
        ingredientsList = try! Realm(configuration: configuration).objects(Ingredient.self).sorted(byKeyPath: "name")
        print(ingredientsList.count)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
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
extension StoreGroceryListTableViewController {
    /*
     * numberOfSections - Return number of sections in table view
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     * tableView(_:numberOfRowsInSection:) - Return number of ingredients
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ingredientsList = self.ingredientsList {
            return ingredientsList.count
        } else {
            return 0
        }
    }
    
    /*
     * tableView(_:cellForRowAt:) - Configures table cells
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ExpandedGroceryListCell.reuseIdentifier, for: indexPath) as? ExpandedGroceryListCell{
            let ingredient = ingredientsList[indexPath.row]
            
            cell.ingredient = ingredient
            cell.titleLabel.text = ingredient.name.capitalized
            
            if selectedStore.groceryList.contains(ingredient) {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    /*
     * tableView(_:didSelectRowAt:) - Check or uncheck ingredient and update realm
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandedGroceryListCell {
            tableView.deselectRow(at: indexPath, animated: true)
            if cell.accessoryType == UITableViewCell.AccessoryType.checkmark {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
    }
}
