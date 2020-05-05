//
//  Ingredient.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import RealmSwift

/*
 * Ingredient - Class to store grocery ingredient objects
 */
class Ingredient: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var image: Data? = nil
    @objc dynamic var isChecked = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
