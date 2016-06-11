//
//  LocationManager.swift
//  Vimli
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
    
    struct LocationTimeInterval {
        static let timeout = NSTimeInterval(30)
        static let restartAfter = NSTimeInterval(60)
    }
    
    // MARK: - Properties
    weak var delegate: LocationManagerDelegate?
    
    lazy var locationManager = CLLocationManager()
    var bestEffortAtLocation: CLLocation?
    var timer: NSTimer?
    
    init(locationAccuracy: CLLocationAccuracy? = nil) {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = locationAccuracy != nil ? locationAccuracy! : kCLLocationAccuracyNearestTenMeters
        checkLocationAuthorizationStatus()
    }
    
    deinit {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
        
        if timer != nil {
            cancelTimer()
        }
        
        bestEffortAtLocation = nil
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func startLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation() {
        DLog.print("Updating location.")
        locationManager.startUpdatingLocation()
        
        // Stop the Core Location Manager after delay
        cancelTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(LocationTimeInterval.timeout, target: self, selector: #selector(LocationManager.startUpdatingLocation), userInfo: nil, repeats: false)
    }
    
    func stopUpdatingLocationWithDelayedRestart() {
        // The location update is suspended to limit power consumption
        locationManager.stopUpdatingLocation()
        cancelTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(LocationTimeInterval.restartAfter, target: self, selector: #selector(LocationManager.startUpdatingLocation), userInfo: nil, repeats: false)
    }
    
    func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            startLocationServices()
            DLog.print("Starting location services.")
        case .Denied, .Restricted:
            DLog.print("Location services not available.")
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        // Test that it isn't an invalid measurement
        if newLocation.horizontalAccuracy < 0 {
            bestEffortAtLocation = nil
            return
        }
        
        // Test if the location is cached
        let locationAge = -(newLocation.timestamp.timeIntervalSinceNow)
        if locationAge > 5.0 {
            bestEffortAtLocation = nil
            return
        }
        
        // Test is the new location is more accurate
        if bestEffortAtLocation == nil || bestEffortAtLocation?.horizontalAccuracy > newLocation.horizontalAccuracy {
            bestEffortAtLocation = newLocation
            
            delegate?.foundInitialLocation(newLocation)
            
            // Test if it meets the desired accuracy
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                // The measurement satisfies the requirement. Stop Core Location and cancel the previous timer.
                if let location = bestEffortAtLocation {
                    delegate?.bestEffortLocationFound(location)
                }
                DLog.print("Best effort location: \(bestEffortAtLocation)")
                stopUpdatingLocationWithDelayedRestart()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            startUpdatingLocation()
        case .Denied, .Restricted:
            locationManager.stopUpdatingLocation()
        case .NotDetermined:
            startLocationServices()
        }
    }
}

private extension Selector {
    static let startUpdatingLocation = #selector(LocationManager.startUpdatingLocation)
    static let stopUpdatingLocationWithDelayedRestart = #selector(LocationManager.stopUpdatingLocationWithDelayedRestart)
}
