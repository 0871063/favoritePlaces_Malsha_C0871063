//
//  PlaceObject.swift
//  favoritePlaces_Malsha_C0871063
//
//  Created by Malsha Lambton on 2023-01-24.
//

import Foundation
import MapKit

class PlaceObject: NSObject, MKAnnotation {
    var title: String?
    var address: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, address: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.address = address
        self.coordinate = coordinate
    }
}
