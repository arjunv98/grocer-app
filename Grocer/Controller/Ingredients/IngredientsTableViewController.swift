//
//  IngredientsTableViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class IngredientsTableViewController: UITableViewController {
    /*
     * IB OUTLETS
     */
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    /*
     * --- VARIABLES -----------------------------------------------------------
     */
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    var ingredientsList: Results<Ingredient>!
    var selection = "Unchecked"
    
    /*
     * viewDidLoad - Initial view load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow for checkmarks
        self.tableView.allowsMultipleSelection = true
        
        selection = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
        updateView()
    }
    
    
    /*
     * --- IB ACTIONS ----------------------------------------------------------
     */
    
    /*
     * didChangeSegmentedControl - Changes result scope and calls for result update
     */
    @IBAction func didChangeSegmentedControl(_ sender: Any) {
        selection = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
        updateView()
    }
    
    
    /*
     * --- HELPER FUNCTIONS ----------------------------------------------------
     */
    
    /*
     * updateView - Update table view to list either saved or nearby stores
     */
    func updateView() {
        print("*** UPDATE INGREDIENT LIST VIEW ***")
        let ingredients = try! Realm(configuration: configuration).objects(Ingredient.self)
        switch selection {
        case "Unchecked":
            ingredientsList = ingredients.sorted(byKeyPath: "isChecked")
        case "A - Z":
            ingredientsList = ingredients.sorted(byKeyPath: "name")
        default:
            ingredientsList = ingredients.sorted(byKeyPath: "isChecked")
        }
        
        print("** UPDATE LIST FOR \(selection.uppercased()) **")
        tableView.reloadData()
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
extension IngredientsTableViewController {
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
        return ingredientsList.count
    }
    
    /*
     * tableView(_:cellForRowAt:) - Configures table cells
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: IngredientCell.reuseIdentifier, for: indexPath) as? IngredientCell {
            let ingredient = ingredientsList[indexPath.row]
            
            cell.ingredient = ingredient
            cell.titleLabel.text = ingredient.name.capitalized
            
            // set isChecked status
            if ingredient.isChecked {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            
            let id = ingredient.id
            let image = ingredient.image
            // asynchronously load and cache images to prevent stuttering/lag
            if let cachedImage = SpoonacularAPIModel.shared.imageCache.object(forKey: NSString(string: "\(id)")) {
                cell.ingredientImageView.image = cachedImage
            } else {
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(image)")
                    let data = try? Data(contentsOf: url!)
                    let image: UIImage = UIImage(data: data!)!

                    DispatchQueue.main.async {
                        SpoonacularAPIModel.shared.imageCache.setObject(image, forKey: NSString(string: "\(id)"))
                        cell.ingredientImageView.image = image
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
    /*
     * tableView(_:didSelectRowAt:) - Check or uncheck ingredient and update realm
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? IngredientCell {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // write change to realm
            let realm = try! Realm(configuration: configuration)
            try! realm.write {
                cell.ingredient!.isChecked = !cell.ingredient!.isChecked
            }
            
            if cell.ingredient!.isChecked {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
        updateView()
    }
}


/*
 * --- DETAIL VIEW TRANSITION --------------------------------------------------
 */
extension IngredientsTableViewController: UIAdaptivePresentationControllerDelegate {
    /*
     * presentationControllerDidDismiss - Reloads map data when detail view is dismissed
     */
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("DISMISSED ADD VIEW TO LIST")
        updateView()
    }
}
