//
//  SeedsTableViewController.m
//  seed
//
//  Created by Sid Jha on 2016-09-12.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "SeedsTableViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"
#import "SeedTableViewCell.h"
#import "SeedWebViewController.h"

@interface SeedsTableViewController ()

@end

@implementation SeedsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.locationManager.delegate = self;

    [self startStandardLocationUpdates];

    NSMutableDictionary *d1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"@sidjha", @"seeder_id", @"6h ago", @"timestamp", @"How to observe meteor shower tonight", @"title", @"http://nytimes.com", @"link", nil];
    NSMutableDictionary *d2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"@bunny", @"seeder_id", @"8h ago", @"timestamp", @"Any tennis players?", @"title", @"http://nytimes.com", @"link", nil];

    self.seeds = [[NSMutableArray alloc] initWithArray:@[d1, d2]];

    self.seedsTableView = self.tableView;

    // Search for new seeds every 30 seconds.
    [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(triggerNewSeedsSearch:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startStandardLocationUpdates {
    // Create the location manager if it doesn't exist
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }

    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = 20;

    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];

    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {

        [self.locationManager startUpdatingLocation];
        [self getNearbyContent];
    } else {
        [self askForPermission];
    }
    
}

- (void) getNearbyContent {

    NSString *lat = [[NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude] stringValue];
    NSString *lng = [[NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude] stringValue];

    NSString *URLString = [NSString stringWithFormat:@"http://0.0.0.0:5000/seeds?lat=%@&lng=%@", lat, lng];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        NSLog(@"Response: %@", responseObject);

        self.seeds = [responseObject objectForKey:@"seeds"];
        [self.tableView reloadData];

    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
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

- (void) triggerNewSeedsSearch:(NSTimer *)timer {
    // TODO: some logic to ensure we are searching only if
    // location has changed by at least 20m.
    [self getNearbyContent];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.seeds count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"seedCell" forIndexPath:indexPath];

    cell.seederLabel.text = [self.seeds objectAtIndex:indexPath.row][@"seeder_name"];
    cell.timestampLabel.text = [self.seeds objectAtIndex:indexPath.row][@"timestamp"];
    cell.captionLabel.text = [self.seeds objectAtIndex:indexPath.row][@"title"];
    cell.linkLabel.text = [self.seeds objectAtIndex:indexPath.row][@"link"];

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
 
*/


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
        [self showNoLocationAccessDialog];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    /*
     CLLocation *newLocation = locations.lastObject;

     NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
     if (locationAge > 5.0) return;

     if (newLocation.horizontalAccuracy < 0) return;

     if (self.currentLocation == nil) {
     [self getNearbyCircles];
     }
     // Needed to filter cached and too old locations
     //NSLog(@"Location updated to = %@", newLocation);
     CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
     CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
     double distance = [loc1 distanceFromLocation:loc2];

     self.currentLocation = newLocation;
     NSLog(@"Location has changed: %f", distance);
     */
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"openSeedSegue"]) {
        NSIndexPath *indexPath = [self.seedsTableView indexPathForCell:sender];

        SeedWebViewController *webViewController = (SeedWebViewController *) segue.destinationViewController;

        webViewController.urlToLoad = [NSURL URLWithString:[self.seeds objectAtIndex:indexPath.row][@"link"]];

       // webViewController.delegate = self;
    }
}



@end
