//
//  ViewController.m
//  seed
//
//  Created by Sid Jha on 2016-08-07.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure map
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setDelegate:self];
    [self.view addSubview:self.mapView];
    
    // Configure location manager
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [self getNearbyCircles];
    
    [self askForPermission];
    
}

- (void) askForPermission {
    [self.locationManager requestAlwaysAuthorization];
}

- (void) getNearbyCircles {
    // TODO: Get nearby circles from web API
    self.nearbyCircles = @[];
}

- (void) setUpFences {
    NSLog(@"Setting up %lu fences..", (unsigned long)[self.nearbyCircles count]);

    // for each nearby circle, set up fence, annotation and overlay
    for(NSInteger i = 0; i <= [self.nearbyCircles count]; i++) {
        CLLocationDegrees lat; // = [self.nearbyCircles objectAtIndex:i].center_lat;
        CLLocationDegrees lng;
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
        
        NSInteger radius; // = [self.nearbyCircles objectAtIndex:i].radius;
        NSString *name; // = [self.nearbyCircles objectAtIndex:i].name
        
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

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {

}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {

}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Changed authorization status: %d", status);
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.mapView setShowsUserLocation:YES];
        [self setUpFences];
    }
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
