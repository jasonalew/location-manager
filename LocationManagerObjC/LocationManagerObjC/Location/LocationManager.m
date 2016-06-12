//
//  LocationManager.m
//  LocationManagerObjC
//
//  Created by Jason Lew on 6/11/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import "LocationManager.h"
#import "JALLog.h"

@interface LocationManager()<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *bestEffortLocation;

@end
@implementation LocationManager

- (instancetype)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _locationManager.activityType = CLActivityTypeOther;
        [self checkLocationAuthorizationStatus];
        return self;
    }
    return nil;
}

- (void)dealloc
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
    }
    
    self.bestEffortLocation = nil;
}

#pragma mark - Actions

- (void)startLocationServices {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

// Be sure to add NSLocationWhenInUseUsageDescription and a string message in info.plist
- (void)checkLocationAuthorizationStatus {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            [self startLocationServices];
            DLog(@"Starting location services.");
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            DLog(@"Location services not available.");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager startUpdatingLocation];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [self.locationManager stopUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [self startLocationServices];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!locations.lastObject) { return; };
    CLLocation *location = locations.lastObject;
    // Test that this isn't an invalid measurement
    if (location.horizontalAccuracy < 0) {
        self.bestEffortLocation = nil;
        return;
    };
    
    // Test if the location is cached
    NSTimeInterval locationAge = -(location.timestamp.timeIntervalSinceNow);
    if (locationAge > 5.0) {
        self.bestEffortLocation = nil;
        return;
    }
    
    // Test if the new location is more accurate
    if (!self.bestEffortLocation || self.bestEffortLocation.horizontalAccuracy > location.horizontalAccuracy) {
        self.bestEffortLocation = location;
        
        [self.delegate foundInitialLocation:location];
        
        // Test if it meets the desired accuracy
        if (location.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            // The measurement staisfies the requirement.
            [self.delegate bestEffortLocationFound:location];
        }
        DLog(@"Best effort location: %@", self.bestEffortLocation);
    }
}

@end
