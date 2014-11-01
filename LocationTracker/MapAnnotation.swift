//
//  MapAnnotation.swift
//  LocationTracker
//
//  Created by Aditya Bansod on 10/23/14.
//  Copyright (c) 2014 Aditya Bansod. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String
    
    init(coordinate:CLLocationCoordinate2D, title:String) {
        self.coordinate = coordinate
        self.title = title
    }
    
    
}
