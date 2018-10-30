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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self as! MKMapViewDelegate
    }

    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }
    
//    extension MapVC: MKMapViewDelegate {
//
//    }
    
}

