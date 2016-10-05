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

class ViewController: UIViewController {
    @IBOutlet weak var Map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let location = CLLocationCoordinate2D(latitude: 48.870333, longitude: 2.346769)
       // let annotation = MKPointAnnotation() */
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        
      /*  annotation.coordinate = location
        annotation.title = "Tech Sentier"
        annotation.subtitle = "Where tech happens" */
        
        Map.setRegion(region, animated: true)
      //  Map.addAnnotation(annotation)
        
        setupStations(data: staticData)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupStations(data: [Dictionary<String,Any>]) {
        
        for station in data {
            if let latitude = station["latitude"] as? Double,
            let longitude = station["longitude"] as? Double {
                
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = location
                annotation.title = "Unknown name"
                annotation.subtitle = "Unknown adress"
                
                self.Map.addAnnotation(annotation)
                
                
                
                print("Yey iy worked! latitude: \(latitude) longitude: \(longitude)")
                
            } else {
                print("Pfff... not working man")
            }
                
            }
        }
        
}




