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
#import "MBProgressHUD.h"
#import "SeedsTableViewModelObject.h"

@interface CreateSeedViewController ()

@end

@implementation CreateSeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.seedLinkTextView.delegate = self;
    self.seedTitleTextView.delegate = self;
    self.usernameField.delegate = self;

    self.locationController = [LocationController sharedLocationController];

    [self.seedTitleTextView becomeFirstResponder];
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
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.seedLinkTextView becomeFirstResponder];
        }];
        [alertController addAction:okAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) postSeedToServer:(NSString *)title andLink:(NSString *)link {

    NSNumber *lat = [NSNumber numberWithDouble:self.locationController.location.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithDouble:self.locationController.location.coordinate.longitude];

#if DEVELOPMENT
#define CREATE_SEED_ENDPOINT @"http://d7eeedc9.ngrok.io/seed/create"
#else
#define CREATE_SEED_ENDPOINT @"https://seedalpha88.herokuapp.com/seed/create"
#endif
    NSString *URLString = [NSString stringWithFormat:CREATE_SEED_ENDPOINT];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

        data[@"title"] = title;
        data[@"link"] = link;
        data[@"lat"] = lat;
        data[@"lng"] = lng;
        data[@"vendor_id_str"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"vendorIDStr"];

        if (self.usernameField.text != nil && ![self.usernameField.text isEqualToString:@""]) {
            data[@"username"] = self.usernameField.text;
        } else {
            // TODO: generate random usernames
            data[@"username"] = @"anon123";
        }

        [manager POST:URLString parameters:data progress:nil success:^(NSURLSessionTask *task, id responseObject) {

            NSLog(@"Data: %@", responseObject);

            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });

            SeedsTableViewModelObject *newlyCreatedSeed = (SeedsTableViewModelObject *)responseObject;

            [self.delegate createSeedViewController:self didFinishPublishingSeed:newlyCreatedSeed];
            [self dismissViewControllerAnimated:YES completion:nil];

        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });

        }];
    });
}

/*
-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
 */

- (void)textViewDidEndEditing:(UITextView *)textView {
    // Show/hide placeholder label
    if (textView.tag == 1) {
        self.titlePlaceholderLabel.hidden = ([textView.text length] > 0);
    } else {
        self.linkPlaceholderLabel.hidden = ([textView.text length] > 0);
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    // Show/hide placeholder label
    if (textView.tag == 1) {
        self.titlePlaceholderLabel.hidden = ([textView.text length] > 0);
    } else {
        self.linkPlaceholderLabel.hidden = ([textView.text length] > 0);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Limit title to 140 characters, and link to 2000 characters.
    if (textView.tag == 1) {
        return textView.text.length + (text.length - range.length) <= 140;
    } else {
        return textView.text.length + (text.length - range.length) <= 2000;
    }
}

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];

    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];

    return [string isEqualToString:filtered];
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
