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
    
    
    // Observe changes to user's location on map
    [self.mapView.userLocation addObserver:self forKeyPath:@"location"
                               options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                               context:NULL];
    
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

- (void) getNearbyCircles {
    
    self.nearbyCircles = @[];
    
    NSString *URLString = [NSString stringWithFormat:@"http://0.0.0.0:5000/circles?lat=%@&lng=%@", @"37.774095", @"-122.416830"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSLog(@"Response: %@", responseObject);
        
        if ([[responseObject objectForKey:@"in_circle"]boolValue] == NO) {
            NSLog(@"Not in circle, here's some nearby ones..");
            
            self.nearbyCircles = [responseObject objectForKey:@"circles"];
            
            [self setUpFences];
            
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
