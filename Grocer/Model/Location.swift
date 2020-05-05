//
//  Location.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import RealmSwift

/*
 * Location - Class to store Location objects, which each contain coordinate and address for a single Store oject
 */
class Location: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    @objc dynamic var address = ""
}
