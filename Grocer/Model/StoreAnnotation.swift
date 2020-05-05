//
//  StoreAnnotation.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import MapKit

/*
 * StoreAnnotation - Class to store Store objects as MKAnnotation objects for display to map
 */
class StoreAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var distance: Double
    var store: Store?
    
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, name: String, distance: Double, store: Store? = nil) {
        self.coordinate = coordinate
        self.name = name
        self.distance = distance
        self.store = store
        super.init()
        self.title = name
        self.subtitle = distanceToString(distance)
    }
    
    private func distanceToString(_ distance: Double) -> String {
        // round distance to 1 and 0 decimal values
        let distance = distance / 1000
        let roundedTenth = distance.rounded(toPlaces: 1)
        let roundedFull = distance.rounded()
        
        // return distance as "* km" if decimal is 0, otherwise "*.* km"
        if roundedTenth == roundedFull && roundedFull != 0.0 {
            return "\(Int(roundedFull)) km"
        } else {
            return "\(roundedTenth) km"
        }
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
