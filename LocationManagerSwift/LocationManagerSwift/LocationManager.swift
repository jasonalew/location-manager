//
//  LocationManager.swift
//  LocationManagerSwift
//
//  Created by Jason Lew on 5/21/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func bestEffortLocationFound(location: CLLocation)
    func foundInitialLocation(location: CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    weak var delegate: LocationManagerDelegate?
    
    lazy var locationManager = CLLocationManager()
    var bestEffortAtLocation: CLLocation?
    
    // MARK: - Init
    init(locationAccuracy: CLLocationAccuracy? = nil) {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy =
            locationAccuracy != nil ? locationAccuracy! : kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .Other
        locationManager.pausesLocationUpdatesAutomatically = true
        checkLocationAuthorizationStatus()
    }
    
    deinit {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
        
        bestEffortAtLocation = nil
    }
    
    // MARK: - Actions
    
    func startLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            startLocationServices()
            DLog.print("Starting location services.")
        case .Denied, .Restricted:
            DLog.print("Location services not available.")
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            locationManager.startUpdatingLocation()
        case .Denied, .Restricted:
            locationManager.stopUpdatingLocation()
        case .NotDetermined:
            startLocationServices()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            DLog.print("No valid location")
            return
        }
        // Test that it isn't an invalid measurement
        if location.horizontalAccuracy < 0 {
            bestEffortAtLocation = nil
            return
        }
        
        // Test if the location is cached
        let locationAge = -(location.timestamp.timeIntervalSinceNow)
        if locationAge > 5.0 {
            bestEffortAtLocation = nil
            return
        }
        
        // Test if the new location is more accurate
        if bestEffortAtLocation == nil || bestEffortAtLocation?.horizontalAccuracy > location.horizontalAccuracy {
            bestEffortAtLocation = location
            
            delegate?.foundInitialLocation(location)
            
            // Test if it meets the desired accuracy
            if location.horizontalAccuracy <= locationManager.desiredAccuracy {
                // The measurement satisfies the requirement.
                if let bestEffortLocation = bestEffortAtLocation {
                    delegate?.bestEffortLocationFound(bestEffortLocation)
                }
                DLog.print("Best effort location: \(bestEffortAtLocation)")
            }
        }
    }
}
