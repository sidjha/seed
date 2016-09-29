//
//  CreateSeedViewController.h
//  seed
//
//  Created by Sid Jha on 2016-09-23.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "LocationController.h"

@interface CreateSeedViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *seedTitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *seedLinkTextView;
@property (nonatomic, strong) LocationController* locationController;

- (IBAction)publishSeedTapped:(id)sender;

@end
