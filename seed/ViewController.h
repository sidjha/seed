//
//  ViewController.h
//  seed
//
//  Created by Sid Jha on 2016-08-07.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import MapKit;

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *nearbyCircles;


@end

