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
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let subtitle: String?
    
    let availableBikes: Int
    let availableStands: Int
    let isBonus: Bool
    
    let pinLabel = UILabel()
    var pinImage: UIImage?
    
    init(title: String, coordinate: CLLocationCoordinate2D, subtitle: String, availableBikes: Int, availableStands: Int, isBonus: Bool) {
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        self.availableBikes = availableBikes
        self.availableStands = availableStands
        self.isBonus = isBonus
    }
    
    func getPinLabel(segmentedControlSegmentIndex segmentIndex: Int) {
        if segmentIndex == 0 {
            pinLabel.text = "\(availableBikes)"
        } else if segmentIndex == 1 {
            pinLabel.text = "\(availableStands)"
        }
    }
    
    func getPinImage(segmentedControlSegmentIndex segmentIndex: Int) {
        
        
        if segmentIndex == 0 {
            
            if availableBikes > 0 {
                if isBonus == false {
                    pinImage = UIImage(named: "yellowPin")
                } else {
                    pinImage = UIImage(named: "yellowPinPlus")
                }
            } else if availableBikes == 0 {
                if isBonus == false {
                    pinImage = UIImage(named: "greyPin")
                } else {
                    pinImage = UIImage(named: "greyPinPlus")
                }
            }
            
        } else if segmentIndex == 1 {
            
            if availableStands > 0 {
                if isBonus == false {
                    pinImage = UIImage(named: "purplePin")
                } else {
                    pinImage = UIImage(named: "purplePinPlus")
                }
            } else {
                if isBonus == false {
                    pinImage = UIImage(named: "greyPin")
                } else {
                    pinImage = UIImage(named: "greyPinPlus")
                }
            }
            
        }
        
    }
    
}
