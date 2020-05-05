//
//  StoreMarkerView.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import MapKit

/*
 * StoreMarkerView - Class to define custom MKAnnotation overlay
 */
class StoreMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? StoreAnnotation else {
                return
            }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            if let letter = annotation.name?.first {
                glyphText = String(letter)
            }
        }
    }
}
