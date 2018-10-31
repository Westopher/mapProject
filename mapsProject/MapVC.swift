//
//  ViewController.swift
//  mapsProject
//
//  Created by West Kraemer on 10/25/18.
//  Copyright © 2018 West Kraemer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
    
}


    extension MapVC: MKMapViewDelegate {
        func centerMapOnUserLocation() {
            guard let coordinate = locationManager.location?.coordinate else {return}
            _ = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 1, longitudinalMeters: 1)
        }
    }


    extension MapVC: CLLocationManagerDelegate {
        func configureLocationServices() {
            if authorizationStatus == .notDetermined {
                locationManager.requestAlwaysAuthorization()
            } else {
                return
        }
    }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            centerMapOnUserLocation()
        }
}
