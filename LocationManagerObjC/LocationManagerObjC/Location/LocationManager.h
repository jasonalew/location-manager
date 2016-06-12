//
//  LocationManager.h
//  LocationManagerObjC
//
//  Created by Jason Lew on 6/11/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol LocationManagerDelegate;
@interface LocationManager : NSObject
@property (weak, nonatomic) id<LocationManagerDelegate>delegate;

@end

@protocol LocationManagerDelegate <NSObject>

- (void)bestEffortLocationFound:(CLLocation *)location;
- (void)foundInitialLocation:(CLLocation *)location;

@end
