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
import RealmSwift

//48.869809, 2.395010
//JCD api key a8fe986f0dc47defeccdb202251be114363e20c1
// Stations request: https://api.jcdecaux.com/vls/v1/stations?contract=Paris&apiKey=a8fe986f0dc47defeccdb202251be114363e20c1

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var Map: MKMapView!
    let locationManager = CLLocationManager()
    var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let realm = try! Realm()
    let requestURL = "https://api.jcdecaux.com/vls/v1/stations?contract=Paris&apiKey=a8fe986f0dc47defeccdb202251be114363e20c1"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // var location = CLLocationCoordinate2D(latitude: 48.870333, longitude: 2.346769)
        
        
  
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        setupMap()
        loadStations()
        
        
        // 262 Rue des pyrenees coords: lat = 48.88457006316311 lng = 2.360215572664323
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Data Functions
    
    
    func loadStations() {
        
        let savedStations = self.realm.objects(Station.self)
        
        if savedStations.count > 0 {
            print("loadStations(): Updating Stations")
            updateStations(APIRequestURL: self.requestURL)
        } else {
            print("loadStations(): Getting Stations")
            setupStations()
            getStations(APIRequestURL: self.requestURL)
        }
    }
    
    
    func getStations(APIRequestURL url: String) {
        Alamofire.request(url).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            
            if let JSON = response.result.value as? [Dictionary<String,Any>] {
                print("JSONBEGINS ---- \(JSON)")
                
                
                // Caching begins
                
                for JSONStation in JSON {
                    let station = Station()
                    
                    if let number = JSONStation["number"] as? Int {
                        station.number = number
                    } else {
                        station.number = 0
                    }
                    
                    if let name = JSONStation["name"] as? String {
                        station.name = name
                    } else {
                        station.name = ""
                    }
                    
                    if let address = JSONStation["address"] as? String {
                        station.address = address
                    } else {
                        station.address = ""
                    }
                    
                    //TODO: FIX THIS BOMB
                    
                    let position = JSONStation["position"] as! [String: AnyObject]
                    
                    if let latitude = position["lat"] as? Double {
                        station.latitude = latitude
                    } else {
                        station.latitude = 0.0
                    }
                    
                    if let longitude = position["lng"] as? Double {
                        station.longitude = longitude
                    } else {
                        station.longitude = 0.0
                    }
                    
                    
                    if let availableBikes = JSONStation["available_bikes"] as? Int {
                        station.availableBikes = availableBikes
                    } else {
                        station.availableBikes = 0
                    }
                    
                    if let availableBikeStands = JSONStation["available_bike_stands"] as? Int {
                        station.availableBikeStands = availableBikeStands
                    } else {
                        station.availableBikeStands = 0
                    }
                    
                    try! self.realm.write {
                        self.realm.add(station)
                    }
                    
                }
                
                self.setupStations()
        
            } else {
                print("Request failed somewhere")
                self.showAlert(title: "Request failed!", message: "The app couldn't fetch current data, try later!")
                self.setupStations()
            }
        }
    }
    
    func updateStations(APIRequestURL url: String) {
        Alamofire.request(url).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            
            if let JSON = response.result.value as? [Dictionary<String,Any>] {
                print("JSONBEGINS ---- \(JSON)")
                
                
                // Updating begins
                
                for JSONStation in JSON {
                    
                    if let number = JSONStation["number"] as? Int,
                        let availableBikes = JSONStation["available_bikes"] as? Int,
                        let availableBikeStands = JSONStation["available_bike_stands"] as? Int {
                        
                        try! self.realm.write {
                            self.realm.create(Station.self, value: ["number": number, "availableBikes": availableBikes, "availableBikeStands": availableBikeStands], update: true)
                        }
                        
                    } else {
                        break
                    }
                    
                }
                
                self.setupStations()
                
            } else {
                print("Request failed somewhere")
                self.showAlert(title: "Request failed!", message: "The app couldn't fetch current data, try later!")
                self.setupStations()
            }
        }
    }
    
    // View Functions
    
    func setupStations() {
        
        let data = self.realm.objects(Station.self)
        
        for station in data {
            
                let location = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = location
                annotation.title = station.name
                annotation.subtitle = "Available Bikes: \(station.availableBikes) ; Available Stands: \(station.availableBikeStands)"
                
                self.Map.addAnnotation(annotation)
        
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
    
    
    func showAlert(title: String, message: String?) {
        let alertControler = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertControler.addAction(alertAction)
        present(alertControler, animated: true, completion: nil)
    }
    
}




