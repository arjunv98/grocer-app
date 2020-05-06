//
//  AddIngredientCell.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/6/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit

class AddIngredientCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientImageView: UIImageView!
    var ingredient: IngredientCodable?
}

