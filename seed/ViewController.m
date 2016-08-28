//
//  ViewController.m
//  seed
//
//  Created by Sid Jha on 2016-08-07.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "ViewController.h"

#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure location manager
    [self startStandardLocationUpdates];
    
    // Configure map
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setDelegate:self];
    [self.view addSubview:self.mapView];
    
    // Observe changes to user's location on map
    [self.mapView.userLocation addObserver:self forKeyPath:@"location"
                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                               context:NULL];
    
    //[self getNearbyCircles];
    
}

- (void) startStandardLocationUpdates {
    // Create the location manager if it doesn't exist
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = 5;
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    } else {
        //[self showNoLocationAccessDialog];
        [self askForPermission];
    }
}

// Pan and zoom map based on current location:
// (from http://stackoverflow.com/questions/2473706/how-do-i-zoom-an-mkmapview-to-the-users-current-location-without-cllocationmanag)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([self.mapView showsUserLocation]) {
        [self panAndZoomMap];
        
    }
}

- (void) panAndZoomMap {
    CLLocationCoordinate2D curLocation = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
    
    MKCoordinateRegion zoomRegion = MKCoordinateRegionMakeWithDistance(curLocation, 400, 400);
    
    [self.mapView setRegion:zoomRegion animated:YES];
}

- (void) askForPermission {
    [self.locationManager requestAlwaysAuthorization];
}

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
    
    [self presentViewController:noLocationAlert animated:YES completion:nil];
}


- (void) getNearbyCircles {
    
    self.nearbyCircles = @[];
    
    NSString *lat = [[NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude] stringValue];
    NSString *lng = [[NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude] stringValue];
    
    NSString *URLString = [NSString stringWithFormat:@"http://0.0.0.0:5000/circles?lat=%@&lng=%@", lat, lng];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
        
        if ([[responseObject objectForKey:@"in_circle"]boolValue] == NO) {
            NSLog(@"Not in circle, here's some nearby ones..");
            
            if ([[responseObject objectForKey:@"circles"] count] == 0) {
                NSLog(@"Sorry, no nearby circles.");
            } else {
                self.nearbyCircles = [responseObject objectForKey:@"circles"];
                [self setUpFences];
            }
            
        } else {
            // TODO: change to in-circle view
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    /*
     // Don't know how much of this code from AFNetworking 2.x is required.
     
     manager.securityPolicy.allowInvalidCertificates = YES;
     
     manager.requestSerializer = [AFJSONRequestSerializer serializer];
     
     [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authToken password:@"something"];
     
     manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
     */
    
}

- (void) setUpFences {
    NSLog(@"Setting up %lu fences..", (unsigned long)[self.nearbyCircles count]);
    
    // for each nearby circle, set up fence, annotation and overlay
    for(NSInteger i = 0; i < [self.nearbyCircles count]; i++) {
        
        CLLocationDegrees lat = [[self.nearbyCircles objectAtIndex:i][@"center_lat"] floatValue];
        CLLocationDegrees lng = [[self.nearbyCircles objectAtIndex:i][@"center_lng"] floatValue];
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
        
        NSInteger radius = [[self.nearbyCircles objectAtIndex:i][@"radius"] intValue];
        NSString *name = [self.nearbyCircles objectAtIndex:i][@"name"];
        
        CLRegion *region = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:name];
        
        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        [pointAnnotation setCoordinate:center];
        [self.mapView addAnnotation:pointAnnotation];
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:center radius:radius];
        [self.mapView addOverlay:circle];
        
        [self.locationManager startMonitoringForRegion:region];
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Changed authorization status: %d", status);
    
    // Update location once location access is granted
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    }
    
    // Show dialog about location if status is changed, and it's
    // not "Authorized Always".
    // But don't show dialog if status hasn't been determined yet
    if (status != kCLAuthorizationStatusAuthorizedAlways && status != kCLAuthorizationStatusNotDetermined) {
        [self showNoLocationAccessDialog];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
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

#pragma mark - MKMapViewDelegate methods

- (MKCircleRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    
    circleRenderer.fillColor = [UIColor blueColor];
    circleRenderer.alpha = 0.25;
    
    return circleRenderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *annotationID = @"annotationID";
    MKPinAnnotationView *newAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
    
    if (newAnnotation == nil) {
        newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
    }
    
    newAnnotation.animatesDrop = YES;
    newAnnotation.canShowCallout = YES;
    
    return newAnnotation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
