//
//  Recipe.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import RealmSwift

/*
 * Recipe - Class to store recipe objects containing multiple Ingredients
 */
class Recipe: Object {
    @objc dynamic var name = ""
    @objc dynamic var image: Data? = nil
    let ingredients = List<Ingredient>()
    @objc dynamic var isSaved = false
}

