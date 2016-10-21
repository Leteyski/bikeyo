//
//  CustomPointAnnotation.swift
//  Bikeyo
//
//  Created by Ruslan Leteyski on 10/15/16.
//  Copyright © 2016 Leteyski. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class StationPoint: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    var availableBikes: Int
    var availableStands: Int
    var isBonus: Bool
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String, availableBikes: Int, availableStands: Int, isBonus: Bool) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.availableBikes = availableBikes
        self.availableStands = availableStands
        self.isBonus = isBonus
    }
}
