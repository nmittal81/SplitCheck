//
//  MapAnnotations.swift
//  SplitCheck
//
//  Created by Neha Mittal on 3/15/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//

import UIKit
import MapKit

class MapAnnotations: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return title
    }
}
