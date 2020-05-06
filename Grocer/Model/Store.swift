//
//  Store.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import RealmSwift

/*
 * Store - Class to store Store objects, with Ingredient lists and a Location object
 */
class Store: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var distance = 0.0
    let shoppingList = List<Ingredient>()
    @objc dynamic var location: Location?
    @objc dynamic var isNearby = false
    @objc dynamic var isSaved = false
    
    override static func primaryKey() -> String? {
        return "id"
    }

}

/*
 * FUNCTION EXTENSIONS
 */
extension Store {
    /*
     * createID - Creates unique id based on location name and address
     */
    func createID(name: String, location: Location) {
        let key = name + location.address
        self.id = key.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\'", with: "").replacingOccurrences(of: ".", with: "")
    }
    
    /*
    * distanceToKmString - Formats distance measurement into km and String type
    */
    func distanceToKmString() -> String {
        // round distance to 1 and 0 decimal values
        let distance = self.distance / 1000
        let roundedTenth = distance.rounded(toPlaces: 1)
        let roundedFull = distance.rounded()
        
        // return distance as "* km" if decimal is 0, otherwise "*.* km"
        if roundedTenth == roundedFull && roundedFull != 0.0 {
            return "\(Int(roundedFull))"
        } else if roundedTenth > 100 {
            return "\(Int(roundedFull))"
        } else {
            return "\(roundedTenth)"
        }
    }
}

/*
 * --- DISTANCE CONVERSION HELPER ----------------------------------------------
 */
extension Double {
    /*
     * rounded - Rounds distance to toPlaces decimal places
     */
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
