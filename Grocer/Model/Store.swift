//
//  Store.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import RealmSwift

class Store: Object {
    @objc dynamic var name = ""
    let shoppingList = List<Ingredient>()
    @objc dynamic var location: Location?
    @objc dynamic var isSaved = false
}

