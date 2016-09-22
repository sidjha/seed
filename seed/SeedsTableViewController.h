//
//  SeedsTableViewController.h
//  seed
//
//  Created by Sid Jha on 2016-09-12.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface SeedsTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *seeds;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UITableView *seedsTableView;

@end
