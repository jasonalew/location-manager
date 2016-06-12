//
//  MapViewController.m
//  LocationManagerObjC
//
//  Created by Jason Lew on 6/11/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import "MapViewController.h"
#import "LocationManager.h"
#import "JALLog.h"
@import MapKit;

@interface MapViewController ()<LocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) LocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[LocationManager alloc]init];
    self.locationManager.delegate = self;
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)updateUI:(CLLocation *)location {
    [self updateLocationLabels:location];
    [self updateMapLocation:location];
}

- (void)updateLocationLabels:(CLLocation *)location {
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", longitude];
}

- (void)updateMapLocation:(CLLocation *)location {
    CLLocationDistance regionRadius = 1000;
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0);
    [self.mapView setRegion:coordinateRegion animated:YES];
}

- (void)bestEffortLocationFound:(CLLocation *)location {
    [self updateUI:location];
    DLog(@"Initial location: %@", location);
}

- (void)foundInitialLocation:(CLLocation *)location {
    [self updateUI:location];
}

@end
