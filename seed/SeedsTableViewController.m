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
#import "CreateSeedViewController.h"
#import "LocationController.h"

@interface SeedsTableViewController ()

@end

@implementation SeedsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationController = [LocationController sharedLocationController];
    // TODO: Do we need to do anything else w.r.t. LocationController initialization?
    self.locationController.delegate = self;

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

- (void) getNearbyContent {

    NSString *lat = [[NSNumber numberWithDouble:self.locationController.location.coordinate.latitude] stringValue];
    NSString *lng = [[NSNumber numberWithDouble:self.locationController.location.coordinate.longitude] stringValue];

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

- (void) triggerNewSeedsSearch:(NSTimer *)timer {
    [self getNearbyContent];
}

#pragma mark - LocationController delegate methods
- (void) locationUpdate:(CLLocation *) location {
    // Load nearby content as soon as we get a new location fix
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
