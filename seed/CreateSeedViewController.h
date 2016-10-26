//
//  CreateSeedViewController.h
//  seed
//
//  Created by Sid Jha on 2016-09-23.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "LocationController.h"
#import "SeedsTableViewModelObject.h"

@class CreateSeedViewController;

@protocol CreateSeedViewControllerDelegate <NSObject>

- (void) createSeedViewController:(CreateSeedViewController *)controller didFinishPublishingSeed:(SeedsTableViewModelObject *)seed;

@end

@interface CreateSeedViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *seedTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *seedLinkTextView;
@property (nonatomic, strong) LocationController* locationController;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titlePlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;

- (IBAction)publishSeedTapped:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;

@property (weak, nonatomic) id <CreateSeedViewControllerDelegate> delegate;

@end
