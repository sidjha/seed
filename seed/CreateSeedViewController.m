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

    self.seedLinkTextView.delegate = self;
    self.seedTitleTextView.delegate = self;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    [doneButton setTintColor:[UIColor blueColor]];

    self.navigationItem.leftBarButtonItem = doneButton;
    self.locationController = [LocationController sharedLocationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publishSeedTapped:(id)sender {

    NSString *title = self.seedTitleTextView.text;
    NSString *link = self.seedLinkTextView.text;

    // Check if link is a valid URL
    NSURL *url = [NSURL URLWithString:link];

    if (url && [url scheme] && [url host]) {
        [self postSeedToServer:title andLink:link];
    } else {
        NSLog(@"Malformed URL");

        // Show error message to user
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Link" message:@"Please enter a valid link. e.g. http://google.com" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) doneAction:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) postSeedToServer:(NSString *)title andLink:(NSString *)link {

    NSNumber *lat = [NSNumber numberWithDouble:self.locationController.location.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithDouble:self.locationController.location.coordinate.longitude];

    NSString *URLString = [NSString stringWithFormat:@"http://0.0.0.0:5000/seed/create"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    data[@"title"] = title;
    data[@"link"] = link;
    data[@"lat"] = lat;
    data[@"lng"] = lng;
    data[@"vendor_id_str"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"vendorIDStr"];
    // TODO: generate random usernames
    data[@"username"] = @"anon123";

    [manager POST:URLString parameters:data progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        NSLog(@"Data: %@", responseObject);

        [self dismissViewControllerAnimated:YES completion:nil];

    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.titlePlaceholderLabel setHidden:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        [self.titlePlaceholderLabel setHidden:NO];
    } else {
        [self.titlePlaceholderLabel setHidden:YES];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Limit title to 140 characters, and link to 2000 characters.
    if (textView.tag == 1) {
        return textView.text.length + (text.length - range.length) <= 140;
    } else {
        return textView.text.length + (text.length - range.length) <= 2000;
    }
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
