//
//  ReportTableViewController.m
//  seed
//
//  Created by Sid Jha on 2016-10-21.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "ReportTableViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"

@interface ReportTableViewController ()

@end

@implementation ReportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeView:)];
    self.navigationItem.rightBarButtonItem = cancelButton;

    self.navigationItem.title = @"Report an issue";

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    headerLabel.text = @"What's wrong here?";
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.numberOfLines = 2;
    headerLabel.font = [UIFont systemFontOfSize:20.0f];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor blackColor];

    self.tableView.tableHeaderView = headerLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) closeView:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) sendReportToServer:(NSString *)reason {
#if DEVELOPMENT
#define REPORT_SEED_ENDPOINT @"http://d7eeedc9.ngrok.io/seed/report"
#else
#define REPORT_SEED_ENDPOINT @"https://seedalpha88.herokuapp.com/seed/report"
#endif
    NSString *URLString = [NSString stringWithFormat:REPORT_SEED_ENDPOINT];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    data[@"seed_id"] = [NSNumber numberWithInt:self.seedID];
    data[@"reason"] = reason;
    data[@"vendor_id_str"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"vendorIDStr"];

    [manager POST:URLString parameters:data progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        NSLog(@"Data: %@", responseObject);

        [self dismissViewControllerAnimated:YES completion:nil];

    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"Error Response: %@", errResponse);
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *reportType = @"";

    if (indexPath.row == 0) {
        reportType = @"spam";
    } else if (indexPath.row == 1) {
        reportType = @"inappropriate";
    } else if (indexPath.row == 2) {
        reportType = @"abusive";
    } else {
        reportType = @"uninterested";
    }

    [self sendReportToServer:reportType];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
