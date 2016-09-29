//
//  LocationController.h
//  seed
//
//  Created by Sid Jha on 2016-09-24.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;


@protocol LocationControllerDelegate
@required
- (void) locationUpdate:(CLLocation *) location;
@end

@interface LocationController : NSObject <CLLocationManagerDelegate> {

    CLLocationManager *locationManager;
    CLLocation *location;
    __weak id delegate;
}

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id  delegate;

+ (LocationController *) sharedLocationController;

@end
