//
//  StoreAnnotation.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import MapKit

class SpecimenAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var distance: Double
    var store: Store?
    
    init(coordinate: CLLocationCoordinate2D, name: String, distance: Double, store: Store? = nil) {
        self.coordinate = coordinate
        self.name = name
        self.distance = distance
        self.store = store
    }
}
