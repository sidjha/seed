//
//  CircleMapViewController.m
//  seed
//
//  Created by Sid Jha on 2016-10-18.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "CircleMapViewController.h"
#import "LocationController.h"

@interface CircleMapViewController ()

@end

@implementation CircleMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    [doneButton setTintColor:[UIColor blackColor]];

    self.navigationItem.rightBarButtonItem = doneButton;

    self.navigationItem.title = @"Discovery Radius: 500m";

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44)];

    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setDelegate:self];
    [self.view addSubview:self.mapView];

    self.locationController = [LocationController sharedLocationController];

    CLLocationDegrees lat = self.locationController.location.coordinate.latitude;
    CLLocationDegrees lng = self.locationController.location.coordinate.longitude;

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);

    NSInteger radius = 500;

    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    [pointAnnotation setCoordinate:center];
    [self.mapView addAnnotation:pointAnnotation];

    MKCircle *circle = [MKCircle circleWithCenterCoordinate:center radius:radius];
    [self.mapView addOverlay:circle];
    //self.mapView.showsUserLocation = YES;

    [self panAndZoomMap:center];

}

- (void) doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) panAndZoomMap:(CLLocationCoordinate2D)center {
    CLLocationCoordinate2D curLocation = CLLocationCoordinate2DMake(center.latitude, center.longitude);

    MKCoordinateRegion zoomRegion = MKCoordinateRegionMakeWithDistance(curLocation, 1200, 1200);

    [self.mapView setRegion:zoomRegion animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
