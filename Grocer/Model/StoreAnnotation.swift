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
final class StoreAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var store: Store?
    var isSaved: Bool
    
    var title: String?
    var subtitle: String?
    var markerTintColor: UIColor {
        if isSaved {
            return .yellow
        } else {
            return .red
        }
    }
    
    /*
     * init(store:) - Initializes annotation values using store parameter
     */
    init(store: Store? = nil) {
        self.store = store
        self.coordinate = CLLocationCoordinate2D(latitude: store!.location!.latitude, longitude: store!.location!.longitude)
        self.isSaved = store!.isSaved
        
        super.init()
        
        self.title = store!.name
        self.subtitle = store!.distanceToKmString() + " km"
    }
}
