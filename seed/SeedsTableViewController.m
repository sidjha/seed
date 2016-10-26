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
#import "ReportTableViewController.h"
#import "SeedsTableViewModelObject.h"

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

    // Configure long press gesture
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
    longPressGesture.delegate = self;
    [self.tableView addGestureRecognizer:longPressGesture];
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

#if DEVELOPMENT
#define NEARBY_SEEDS_ENDPOINT @"http://0.0.0.0:5000/seeds"
#else
#define NEARBY_SEEDS_ENDPOINT @"https://seedalpha88.herokuapp.com/seeds"
#endif
    NSString *URLString = [NSString stringWithFormat:@"%@?lat=%@&lng=%@", NEARBY_SEEDS_ENDPOINT, lat, lng];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        //NSLog(@"Response: %@", responseObject);

        // Populate array of Seed model objects
        self.seeds = [[NSMutableArray alloc] init];
        for(NSInteger i = 0; i < [[responseObject objectForKey:@"seeds"] count]; i++) {
            NSMutableDictionary *objectDict = [[responseObject objectForKey:@"seeds"] objectAtIndex:i];
            SeedsTableViewModelObject *aSeed = [[SeedsTableViewModelObject alloc] initWithJSON:objectDict];
            [self.seeds addObject:aSeed];
        }

        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
        self.seeds = [NSMutableArray arrayWithArray:[self.seeds sortedArrayUsingDescriptors:@[dateSortDescriptor]]];

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

    SeedsTableViewModelObject *seed = (SeedsTableViewModelObject *)[self.seeds objectAtIndex:indexPath.row];

    cell.seedID = seed.seedID;

    cell.seederLabel.text = seed.username;

    cell.timestampLabel.text = [self relativeDateStringForDate:seed.timestamp];

    cell.captionLabel.text = seed.title;
    cell.linkLabel.text = seed.link;

    cell.upvoteCount = seed.upvotes;

    cell.preservesSuperviewLayoutMargins = false;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;

    return cell;
}


- (void) cellLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {

    CGPoint p = [gestureRecognizer locationInView:self.tableView];

    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];

    if (indexPath == nil) {

    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {

        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *actionReport = [UIAlertAction actionWithTitle:@"Report this Seed" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            SeedsTableViewModelObject *seed = (SeedsTableViewModelObject *)[self.seeds objectAtIndex:indexPath.row];
            [self reportSeed:seed.seedID];
        }];

        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

        [actionSheet addAction:actionReport];
        [actionSheet addAction:actionCancel];

        [self presentViewController:actionSheet animated:YES completion:nil];
    } else {

    }

}

- (void) reportSeed:(int)seedID {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    UINavigationController *reportVCRoot = [storyboard instantiateViewControllerWithIdentifier:@"reportVCRoot"];
    ReportTableViewController *reportVC = (ReportTableViewController *)reportVCRoot.viewControllers.firstObject;

    reportVC.seedID = seedID;

    [self presentViewController:reportVCRoot animated:YES completion:nil];
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

        if (components.year > 1) {
            return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
        } else {
            return [NSString stringWithFormat:@"%ld year ago", (long)components.year];
        }

    } else if (components.month > 0) {

        if (components.month > 1) {
            return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
        } else {
            return [NSString stringWithFormat:@"%ld month ago", (long)components.month];
        }

    } else if (components.weekOfYear > 0) {

        if (components.weekOfYear > 1) {
            return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
        } else {
            return [NSString stringWithFormat:@"%ld week ago", (long)components.weekOfYear];
        }

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

- (void) createSeedViewController:(CreateSeedViewController *)controller didFinishPublishingSeed:(SeedsTableViewModelObject *)seed {
    [self getNearbyContent];
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

        SeedsTableViewModelObject *seed = (SeedsTableViewModelObject *) [self.seeds objectAtIndex:indexPath.row];
        webViewController.urlToLoad = [NSURL URLWithString:seed.link];
    } else if ([segue.identifier isEqualToString:@"createSeedSegue"]) {
        CreateSeedViewController *createSeedVC = (CreateSeedViewController *) segue.destinationViewController;
        createSeedVC.delegate = self;
    }
}


@end
