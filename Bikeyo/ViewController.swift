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



/*
 var detailItem: AnyObject? {
 didSet {
 // Update the view.
 self.configureView()
 }
 }*/

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
   
    // Outlets
    
    @IBOutlet weak var Map: MKMapView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var RefreshButton: UIButton!
    @IBOutlet weak var LocateButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // View Data
    
    let locationManager = CLLocationManager()
    var location = CLLocationCoordinate2D(latitude: 48.855324, longitude: 2.345074)
    let realm = try! Realm()
    let requestURL = "https://api.jcdecaux.com/vls/v1/stations?contract=Paris&apiKey=a8fe986f0dc47defeccdb202251be114363e20c1"
    
    // Pins
    
  //  var pointAnnotation: StationPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupMap()
        getLocation()
        updateStations(APIRequestURL: requestURL)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Data Functions
    
    func updateStations(APIRequestURL url: String) {
        
        self.RefreshButton.isHidden = true
        self.ActivityIndicator.isHidden = false
        
        Alamofire.request(url).responseJSON { response in
            print(response.request)  // original URL request
            print(response.response) // HTTP URL response
            print(response.data)     // server data
            print(response.result)   // result of response serialization
            
            
            if let JSON = response.result.value as? [Dictionary<String,Any>] {
                print("JSONBEGINS ---- \(JSON)")
                
                self.setupStations(data: JSON)
                
                //Caching
                
                let jsonObject = JSONObject()
                jsonObject.data = response.data! as NSData
                
                try! self.realm.write {
                    self.realm.deleteAll()
                    self.realm.add(jsonObject)
                }
                
                
            } else {
                print("Request failed somewhere")
                self.showAlert(title: "Request failed!", message: "The app couldn't fetch current data, please try again later.")
                let jsonObject = self.realm.objects(JSONObject.self)
                
                if jsonObject.count > 0 {
                    for json in jsonObject {
                    let finalData = try! JSONSerialization.jsonObject(with: json.data as Data, options: []) as? [Dictionary<String,Any>]
                    self.setupStations(data: finalData!)
                    }
                } else {
                    self.ActivityIndicator.isHidden = true
                    self.RefreshButton.isHidden = false
                }
            }
        }
    }
    
    // View Functions
    
    
    func setupStations(data: [Dictionary<String,Any>]) {
        
        self.Map.removeAnnotations(self.Map.annotations)
        
       /* for station in data {
            
            if let position = station["position"] as? [String:AnyObject] {
                if let latitude = position["lat"] as? Double,
                    let longitude = position["lng"] as? Double {
                    
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let annotation = MKPointAnnotation()
                    
                    annotation.coordinate = location
                    
                    if let name = station["name"] as? String {
                        annotation.title = name
                    } else {
                        annotation.title = "Name unavailable"
                    }
                    
                    if let availableBikes = station["available_bikes"] as? Int,
                        let availableBikeStands = station["available_bike_stands"] as? Int {
                        annotation.subtitle = "Available Bikes: \(availableBikes) ; Available Stands: \(availableBikeStands)"
                    } else {
                        annotation.subtitle = "Data unvailable"
                    }
                    
                    self.Map.addAnnotation(annotation)
                    
                }
            
            }
            
        } */
        
        for station in data {
            
            if let position = station["position"] as? [String:AnyObject] {
                if let latitude = position["lat"] as? Double,
                    let longitude = position["lng"] as? Double {
                    
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    
                    guard let name = station["name"] as? String else { return }
                    guard let address = station["address"] as? String else { return }
                    guard let availableBikes = station["available_bikes"] as? Int else { return }
                    guard let availableStands = station["available_bike_stands"] as? Int else { return }
                    guard let isBonus = station["bonus"] as? Bool else { return }
                    
                    let stationPoint = StationPoint(title: name, coordinate: location, subtitle: address, availableBikes: availableBikes, availableStands: availableStands, isBonus: isBonus)
                    //stationPoint.pinLabel.text = "\(stationPoint.availableBikes)"
                    stationPoint.getPinLabel(segmentedControlSegmentIndex: self.segmentedControl.selectedSegmentIndex)
                    stationPoint.getPinImage(segmentedControlSegmentIndex: self.segmentedControl.selectedSegmentIndex)
                    self.Map.addAnnotation(stationPoint)
                
                }
                
            }
            
        }
        
        self.ActivityIndicator.isHidden = true
        self.RefreshButton.isHidden = false
        
    }
    
    func getLocation() {
       
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }
    
    func setupMap() {
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        Map.setRegion(region, animated: true)
      //  Map.showsUserLocation = true
        Map.delegate = self
        //Map.mapType = MKMapType.standard

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.location.latitude = locValue.latitude
        self.location.longitude = locValue.longitude
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationManager.stopUpdatingLocation()
        
        setupMap()
    }
    
  /* func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //if mapView.reuseIdentifier
        
        if annotation is StationPoint {
            let reuseIdentifier = "stationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            let stationPoint = annotation as! StationPoint
            //let numberLabel = UILabel()
            //numberLabel.text = String(stationPoint.availableBikes)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = true
                
                annotationView?.addSubview(stationPoint.numberLabel)
                
                stationPoint.numberLabel.textColor = UIColor.white
                stationPoint.numberLabel.font = UIFont.boldSystemFont(ofSize: 13)
                //numberLabel.text = "\(stationPoint.availableBikes)"
                
                stationPoint.numberLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stationPoint.numberLabel.topAnchor.constraint(equalTo: (annotationView?.topAnchor)!, constant: 12),
                    stationPoint.numberLabel.centerXAnchor.constraint(equalTo: (annotationView?.centerXAnchor)!)
                    ])

            } else {
                annotationView?.annotation = annotation
                //numberLabel.text = "\(stationPoint.availableBikes)"
            }
            
            //let stationPointAnnotation = annotation as! StationPointAnnotation
            if stationPoint.isBonus == true {
                annotationView?.image = UIImage(named: "yellowPinPlus")
            } else {
                annotationView?.image = UIImage(named: "yellowPin")
            }
            
            return annotationView
        }
        
        return nil
    } */
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //if mapView.reuseIdentifier
        
        if annotation is StationPoint {
            
            let stationPoint = annotation as! StationPoint
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.canShowCallout = true
            
            annotationView.addSubview(stationPoint.pinLabel)
                
            stationPoint.pinLabel.textColor = UIColor.white
            stationPoint.pinLabel.font = UIFont.boldSystemFont(ofSize: 13)
            
            stationPoint.pinLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                    stationPoint.pinLabel.topAnchor.constraint(equalTo: (annotationView.topAnchor), constant: 12),
                    stationPoint.pinLabel.centerXAnchor.constraint(equalTo: (annotationView.centerXAnchor))
                    ])
            
            //let stationPointAnnotation = annotation as! StationPointAnnotation
           /* if stationPoint.isBonus == true {
                annotationView.image = UIImage(named: "yellowPinPlus")
            } else {
                annotationView.image = UIImage(named: "yellowPin")
            } */
            
            annotationView.image = stationPoint.pinImage!
            return annotationView
        }
        
        return nil
    }
    
    
    
    
    
    func showAlert(title: String, message: String?) {
        let alertControler = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertControler.addAction(alertAction)
        present(alertControler, animated: true, completion: nil)
    }
    
    
    
    // IB Actions
    
    @IBAction func RefreshStations() {
        updateStations(APIRequestURL: requestURL)
    }
    
    @IBAction func RefreshLocation() {
        getLocation()
    }
    
    @IBAction func SegmentedControlIndexChanged(_ sender: AnyObject) {
        
        let jsonObject = self.realm.objects(JSONObject.self)
        
        for json in jsonObject {
                let finalData = try! JSONSerialization.jsonObject(with: json.data as Data, options: []) as? [Dictionary<String,Any>]
                self.setupStations(data: finalData!)
        }
        
        print("Segmented Control reloads stations")
    
    }
}




