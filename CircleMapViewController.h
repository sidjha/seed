//
//  CircleMapViewController.h
//  seed
//
//  Created by Sid Jha on 2016-10-18.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationController.h"
@import MapKit;


@interface CircleMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) LocationController* locationController;

@end
