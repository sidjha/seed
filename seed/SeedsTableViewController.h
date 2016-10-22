//
//  SeedsTableViewController.h
//  seed
//
//  Created by Sid Jha on 2016-09-12.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationController.h"
#import "EAIntroView.h"

@interface SeedsTableViewController : UITableViewController <LocationControllerDelegate, EAIntroDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *seeds;
@property (nonatomic, strong) UITableView *seedsTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createSeedButton;
@property (nonatomic, strong) LocationController *locationController;


@end
