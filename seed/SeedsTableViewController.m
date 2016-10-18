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
#import "EAIntroView.h"
#import "CircleMapViewController.h"

@interface SeedsTableViewController ()

@end

@implementation SeedsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationController = [LocationController sharedLocationController];
    // TODO: Do we need to do anything else w.r.t. LocationController initialization?
    self.locationController.delegate = self;

    /*
     NSMutableDictionary *d1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"@sidjha", @"seeder_id", @"6h ago", @"timestamp", @"How to observe meteor shower tonight", @"title", @"http://nytimes.com", @"link", nil];
     NSMutableDictionary *d2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"@bunny", @"seeder_id", @"8h ago", @"timestamp", @"Any tennis players?", @"title", @"http://nytimes.com", @"link", nil];
     */

    self.seedsTableView = self.tableView;

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

    [self.navigationController.navigationBar setShadowImage:[UIImage new]];

    //[self.navigationController.navigationBar setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];

    UIEdgeInsets inset = UIEdgeInsetsMake(40.0, 0, 0, 0);
    self.tableView.contentInset = inset;

    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 54)];

    [titleView setBackgroundColor:[UIColor whiteColor]];

    UILabel *titleLabel = [[UILabel alloc] init];

    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont fontWithName:@"SourceSerifPro-Bold" size:20.0];

    //titleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = @"Nearby Seeds";
    [titleLabel sizeToFit];
    [titleLabel setCenter:CGPointMake(titleView.center.x, titleLabel.center.y)];

    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(0,22, 100, 22);
    [locationButton addTarget:self action:@selector(showLocationMap:) forControlEvents:UIControlEventTouchUpInside];
    [locationButton setTitle:@"within 500m" forState:UIControlStateNormal];
    [locationButton setTintColor:[UIColor blackColor]];
    [locationButton.titleLabel setFont:[UIFont systemFontOfSize:14.0 weight:UIFontWeightThin]];
    [locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    locationButton.center = CGPointMake(titleView.center.x, locationButton.center.y);

    // Underline "Within 500m" button
    NSMutableAttributedString *mat = [locationButton.titleLabel.attributedText mutableCopy];
    [mat addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, mat.length)];

    locationButton.titleLabel.attributedText = mat;

    // Add tap gesture to "Nearby Seeds" label as well to show map
    UITapGestureRecognizer *labelTapGestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLocationMap:)];
    labelTapGestureRec.numberOfTapsRequired = 1;
    [titleLabel addGestureRecognizer:labelTapGestureRec];
    titleLabel.userInteractionEnabled = YES;

    [titleView addSubview:titleLabel];
    [titleView addSubview:locationButton];

    self.navigationItem.titleView = titleView;

    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:15.0 forBarMetrics:UIBarMetricsDefault];
    // Search for new seeds every 30 seconds.
    [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(triggerNewSeedsSearch:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showLocationMap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CircleMapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"currentCircleMapVC"];
    mapVC.modalPresentationStyle = UIModalPresentationFullScreen;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mapVC];

    [self presentViewController:navController animated:YES completion:nil];
}

- (void) getNearbyContent {

    NSString *lat = [[NSNumber numberWithDouble:self.locationController.location.coordinate.latitude] stringValue];
    NSString *lng = [[NSNumber numberWithDouble:self.locationController.location.coordinate.longitude] stringValue];

    NSString *URLString = [NSString stringWithFormat:@"https://seedalpha88.herokuapp.com/seeds?lat=%@&lng=%@", lat, lng];

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
    NSInteger numSections = 0;

    if ([self.seeds count] > 0) {
        numSections = 1;
        self.tableView.backgroundView = nil;
    } else {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width - 20, self.tableView.bounds.size.height)];
        noDataLabel.text             = @"Be the first one to seed in this area! \nTap SEED on the top right.";
        noDataLabel.numberOfLines = 4;
        noDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
        noDataLabel.textColor        = [UIColor grayColor];
        noDataLabel.font = [UIFont fontWithName:@"Georgia" size:18];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.seeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"seedCell" forIndexPath:indexPath];

    cell.seederLabel.text = [self.seeds objectAtIndex:indexPath.row][@"seeder_name"];

    NSString *rawTimestamp = [self.seeds objectAtIndex:indexPath.row][@"timestamp"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    NSDate *date = [dateFormatter dateFromString:rawTimestamp];

    //[dateFormatter setDateFormat:@"MMM d h:mm a"];
    //NSString *timestamp = [dateFormatter stringFromDate:date];

    cell.timestampLabel.text = [self relativeDateStringForDate:date];

    cell.captionLabel.text = [self.seeds objectAtIndex:indexPath.row][@"title"];
    cell.linkLabel.text = [self.seeds objectAtIndex:indexPath.row][@"link"];

    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;

    return cell;
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{

    // Taken from: http://stackoverflow.com/questions/20487465/how-to-convert-nsdate-in-to-relative-format-as-today-yesterday-a-week-ago
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;

    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];

    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        return @"Today";
    }
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
