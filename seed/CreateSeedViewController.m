//
//  CreateSeedViewController.m
//  seed
//
//  Created by Sid Jha on 2016-09-23.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "CreateSeedViewController.h"
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"

@interface CreateSeedViewController ()

@end

@implementation CreateSeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publishSeedTapped:(id)sender {

    [self postSeedToServer];

}

- (void) postSeedToServer {

    NSString *lat = [[NSNumber numberWithDouble:self.locationController.location.coordinate.latitude] stringValue];
    NSString *lng = [[NSNumber numberWithDouble:self.locationController.location.coordinate.longitude] stringValue];

    NSString *URLString = [NSString stringWithFormat:@"http://0.0.0.0:5000/seed/create"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    data[@"title"] = self.seedTitleTextView.text;
    data[@"link"] = self.seedLinkTextView.text;
    data[@"lat"] = lat;
    data[@"lng"] = lng;
    data[@"user_id"] = @"1"; // TODO: get user id of current user

    [manager POST:URLString parameters:data progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        NSLog(@"Data: %@", responseObject);

    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
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
