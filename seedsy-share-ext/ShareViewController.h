//
//  ShareViewController.h
//  seedsy-share-ext
//
//  Created by Sid Jha on 2016-10-27.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "LocationController.h"

@interface ShareViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *seedTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *seedLinkTextView;
@property (nonatomic, strong) LocationController* locationController;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titlePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;

- (IBAction)publishSeedTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;

@end
