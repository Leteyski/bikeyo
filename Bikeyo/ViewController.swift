//
//  ViewController.swift
//  Bikeyo
//
//  Created by Ruslan Leteyski on 05/10/2016.
//  Copyright © 2016 Leteyski. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

//48.869809, 2.395010
//JCD api key a8fe986f0dc47defeccdb202251be114363e20c1
// Stations request: https://api.jcdecaux.com/vls/v1/stations?contract=Paris&apiKey=a8fe986f0dc47defeccdb202251be114363e20c1

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var Map: MKMapView!
    let locationManager = CLLocationManager()
    var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // var location = CLLocationCoordinate2D(latitude: 48.870333, longitude: 2.346769)
        
  //      let stationData: [Dictionary<String,Any>] = []
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        
        setupMap()
        
        
       getStations(url: "https://api.jcdecaux.com/vls/v1/stations?contract=Paris&apiKey=a8fe986f0dc47defeccdb202251be114363e20c1")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getStations(url: String) {
        Alamofire.request(url).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.result.value as? [Dictionary<String,Any>] {
                print("JSONBEGINS ---- \(JSON)")
                self.setupStations(data: JSON)
        
            } else {
                print("Request failed somewhere")
            }
        }
    }
    
    
    func setupStations(data: [Dictionary<String,Any>]) {
        
        for station in data {
            
            guard let position = station["position"] as? [String:AnyObject] else {
                    print("Invalid poosition")
                    return
            }
            
            if let latitude = position["lat"] as? Double,
            let longitude = position["lng"] as? Double {
                
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = location
                
                if let name = station["name"] as? String {
                    annotation.title = name
                } else {
                    annotation.title = "Unknown name"
                }
                
                if let availableBikes = station["available_bikes"] as? Int,
                    let availableStands = station["available_bike_stands"] as? Int {
                    annotation.subtitle = "Available Bikes: \(availableBikes) ; Available Stands: \(availableStands)"
                } else {
                    annotation.subtitle = "Unknown availability"
                }
                
                self.Map.addAnnotation(annotation)
                
            } else {
                
                if let stationNumber = station["number"] as? Int {
                    print("Station Nº\(stationNumber) returned invalid coordinates")
                } else {
                    print("Unknown station returned both Invalid coordinates && Invalid Station number")
                }
                }
            }
        }
    
    func setupMap() {
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        Map.setRegion(region, animated: true)
        Map.showsUserLocation = true
        
        

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.location.latitude = locValue.latitude
        self.location.longitude = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationManager.stopUpdatingLocation()
        setupMap()
    }
        
}




