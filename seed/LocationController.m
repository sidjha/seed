//
//  LocationController.m
//  seed
//
//  Created by Sid Jha on 2016-09-24.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "LocationController.h"

static LocationController *sharedCLDelegate;

@implementation LocationController
@synthesize locationManager, location, delegate;

- (id) init {
    self = [super init];

    // Configure LocationManager if we do not exist yet
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 20;

        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];

        // Only start updating location if app has permission
        if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {

            [self.locationManager startUpdatingLocation];
        } else {
            [self askForPermission];
        }
    }

    return self;
}

- (void) askForPermission {
    [self.locationManager requestAlwaysAuthorization];
}

/*
- (void) showNoLocationAccessDialog {
    UIAlertController *noLocationAlert = [UIAlertController alertControllerWithTitle:@"App needs location access" message:@"We do not have permission to access your location. Please turn this ON to use the app." preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *askPermissionAction = [UIAlertAction actionWithTitle:@"Give Permission" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self askForPermission];
    }];

    UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"Quit" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // TODO: show error message view controller.
    }];

    [noLocationAlert addAction:askPermissionAction];
    [noLocationAlert addAction:quitAction];

    //[self presentViewController:noLocationAlert animated:YES completion:nil];
}
*/

#pragma mark - Singleton implementation in ARC
+ (LocationController *)sharedLocationController
{
    static LocationController *sharedLocationControllerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedLocationControllerInstance = [[self alloc] init];
    });
    return sharedLocationControllerInstance;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Changed authorization status: %d", status);

    // Update location once location access is granted
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }

    // Show dialog about location if status is changed, and it's
    // not "Authorized Always".
    // But don't show dialog if status hasn't been determined yet
    if (status != kCLAuthorizationStatusAuthorizedAlways && status != kCLAuthorizationStatusNotDetermined) {
       // [self showNoLocationAccessDialog];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *newLocation = locations.lastObject;
    self.location = newLocation;

    // Trigger delegate method to inform of new location
    [self.delegate locationUpdate:self.location];

}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"Monitoring started for region: %@", region.description);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Monitoring failed for region: %@, error: %@", region.description, error.description);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered region: %@", region.description);

    // TODO: change to in-circle view
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited region: %@", region.description);

    // TODO: change to off-circle view
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed. Error: %@", error.description);
}

@end
