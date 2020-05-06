//
//  StoreCell.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/5/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit

/*
 * Store
 */
final class StoreCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    var store: Store?
    
    /*
     * initializeCell - Initializes cell values
     */
    func initializeCell(with store: Store) {
        titleLabel.text = store.name
        detailLabel.text = "\(store.distanceToKmString()) km"
        self.store = store
    }
}
