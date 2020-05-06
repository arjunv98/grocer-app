//
//  ReuseIdentifying.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/5/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit

/*
 * ReuseIdentifying - Protocol to automatically define custom cell reuse identifiers
 */
protocol ReuseIdentifying {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

/*
 * Apply protocol to all UITableViewCell types in project
 */
extension UITableViewCell: ReuseIdentifying {}
