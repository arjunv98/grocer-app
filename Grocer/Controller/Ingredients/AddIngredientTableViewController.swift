//
//  AddIngredientTableViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/6/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AddIngredientTableViewController: UITableViewController {
    
    /*
     * --- VARIABLES -----------------------------------------------------------
     */
    var searchController = UISearchController(searchResultsController: nil)
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    /*
     * viewDidLoad - Initial view load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ADD INGREDIENT VIEW DID LOAD")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for ingredients"
        definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
        
        self.tableView.keyboardDismissMode = .onDrag
    }
    
    /*
     * viewDidAppear - Called on view appearance, sets search bar as first responder
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    
    /*
     * --- HELPER FUNCTIONS ----------------------------------------------------
     */
    
    /*
     * getAutocomplete - Asynchronously grabs ingredient autocomplete information from Spoonacular API
     */
    func getAutocomplete(for query: String) {
        SpoonacularAPIModel.shared.getAutocompleteIngredients(query: query, onSuccess: {
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        })
    }
}


/*
 * --- TABLE VIEW --------------------------------------------------------------
 */
extension AddIngredientTableViewController {
    /*
     * numberOfSections - Return number of sections in table view
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     * tableView(_:numberOfRowsInSection:) - Return number of autocomplete items
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SpoonacularAPIModel.shared.ingredients.count
    }
    
    /*
     * tableView(_:cellForRowAt:) - Configures table cells
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: AddIngredientCell.reuseIdentifier, for: indexPath) as? AddIngredientCell {
            let ingredient = SpoonacularAPIModel.shared.ingredients[indexPath.row]
            
            cell.ingredient = ingredient
            cell.titleLabel.text = ingredient.name.capitalized
            
            // asynchronously load and cache images to prevent stuttering/lag
            if let cachedImage = SpoonacularAPIModel.shared.imageCache.object(forKey: NSString(string: "\(ingredient.id)")) {
                cell.ingredientImageView.image = cachedImage
            } else {
                DispatchQueue.global(qos: .background).async {
                    let url = URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(ingredient.image)")
                    let data = try? Data(contentsOf: url!)
                    let image: UIImage = UIImage(data: data!)!
                    
                    DispatchQueue.main.async {
                        SpoonacularAPIModel.shared.imageCache.setObject(image, forKey: NSString(string: "\(ingredient.id)"))
                        cell.ingredientImageView.image = image
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    /*
     * tableView(_:didSelectRowAt:) - Select correct cell, add ingreedient to realm, and dismiss self to previous view
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AddIngredientCell {
            tableView.deselectRow(at: indexPath, animated: true)
            
            // create Ingredient object from IngredientCodable
            let ingredient = Ingredient()
            ingredient.id = cell.ingredient!.id
            ingredient.name = cell.ingredient!.name
            ingredient.image = cell.ingredient!.image
            print(ingredient.id)
            
            // check if ingredient exists
            let realm = try! Realm(configuration: configuration)
            let match = realm.objects(Ingredient.self).filter("id == \(ingredient.id)")
            if match.count > 0 {
                ingredient.isChecked = match.first!.isChecked
            }
            
            // write value to realm
            print("ADD TO REALM")
            try! realm.write {
                realm.add(ingredient, update: .modified)
            }
            
        }
        self.dismiss(animated: true, completion: { self.dismiss(animated: true, completion: {
            self.presentationController?.delegate?.presentationControllerDidDismiss?(self.presentationController!)
        }) })
    }
}


/*
 * --- SEARCH ------------------------------------------------------------------
 */
extension AddIngredientTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        getAutocomplete(for: searchBar.text!)
    }
}
