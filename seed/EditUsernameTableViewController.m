//
//  EditUsernameTableViewController.m
//  seed
//
//  Created by Sid Jha on 2016-10-07.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "EditUsernameTableViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"

@interface EditUsernameTableViewController ()

@end

@implementation EditUsernameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:nil action:@selector(doneAction:)];

     self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doneAction:(id)sender {
    NSString *username = self.usernameField.text;

    [self postUsernameToServer:username];

}


- (void) postUsernameToServer:(NSString *)username {

    NSString *URLString = [NSString stringWithFormat:@"https://seedalpha88.herokuapp.com/user/update"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    data[@"username"] = username;
    data[@"vendor_id_str"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"vendorIDStr"];

    [manager POST:URLString parameters:data progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"Data: %@", responseObject);

        [self dismissViewControllerAnimated:YES completion:nil];
    } failure: ^(NSURLSessionTask *operation, NSError *error) {

        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - Table view data source

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
