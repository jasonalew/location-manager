//
//  MapViewController.swift
//  LocationManagerSwift
//
//  Created by Jason Lew on 6/11/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let locationManager = LocationManager()

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateLocationLabels(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        latitudeLabel.text = "\(latitude)"
        longitudeLabel.text = "\(longitude)"
    }

}

extension MapViewController: LocationManagerDelegate {
    func foundInitialLocation(location: CLLocation) {
        updateLocationLabels(location)
        DLog.print("Initial location: \(location)")
    }
    
    func bestEffortLocationFound(location: CLLocation) {
        updateLocationLabels(location)
    }
}