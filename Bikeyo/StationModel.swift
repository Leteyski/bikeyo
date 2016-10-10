//
//  StationModel.swift
//  Bikeyo
//
//  Created by Ruslan Leteyski on 10/10/16.
//  Copyright © 2016 Leteyski. All rights reserved.
//

import Foundation
import RealmSwift

class Station: Object {
    dynamic var number = 0
    dynamic var name = ""
    dynamic var address = ""
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var banking = false
    dynamic var bonus = false
    dynamic var statusIsOpen = false
    dynamic var contractName = ""
    dynamic var bikeStands = 0
    dynamic var availableBikes = 0
    dynamic var availableBikeStands = 0
}


/*
 {
 "number": 31705,
 "name": "31705 - CHAMPEAUX (BAGNOLET)",
 "address": "RUE DES CHAMPEAUX (PRES DE LA GARE ROUTIERE) - 93170 BAGNOLET",
 "position": {
 "lat": 48.8645278209514,
 "lng": 2.416170724425901
 },
 "banking": true,
 "bonus": true,
 "status": "OPEN",
 "contract_name": "Paris",
 "bike_stands": 50,
 "available_bike_stands": 50,
 "available_bikes": 0,
 "last_update": 1476129465000
 }*/
