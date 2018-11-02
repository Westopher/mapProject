//
//  DroppablePin.swift
//  mapsProject
//
//  Created by West Kraemer on 11/2/18.
//  Copyright © 2018 West Kraemer. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
