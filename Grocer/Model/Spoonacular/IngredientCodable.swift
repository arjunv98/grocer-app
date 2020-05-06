//
//  IngredientCodable.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/6/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import Foundation

struct IngredientCodable: Decodable {
    let id: Int
    let name: String
    let image: String
}
