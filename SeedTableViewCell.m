//
//  SeedTableViewCell.m
//  seed
//
//  Created by Sid Jha on 2016-09-13.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "SeedTableViewCell.h"
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"

@implementation SeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    // Set up button aesthetics
    [self.upvoteButton setTitle:@"UPVOTE" forState:UIControlStateNormal];
    [self.upvoteButton setTintColor:[UIColor greenColor]];

    [self changeUpvotedButton];
}

- (void) changeUpvotedButton {
    if (self.hasbeenUpvoted) {
        [self.upvoteButton setTitle:@"UPVOTED" forState:UIControlStateNormal];
    } else {
        [self.upvoteButton setTitle:@"UPVOTE" forState:UIControlStateNormal];
    }
}

- (IBAction)upvoteButtonTapped:(id)sender {
    [self toggleUpvotedState];
}

- (void) toggleUpvotedState {
    self.hasbeenUpvoted = !self.hasbeenUpvoted;
    [self changeUpvotedButton];
    [self sendUpvoteToServer];
}

- (void) sendUpvoteToServer {

#if DEVELOPMENT
#define UPVOTE_SEED_ENDPOINT @"http://0.0.0.0:5000/seed/upvote"
#else
#define UPVOTE_SEED_ENDPOINT @"https://seedalpha88.herokuapp.com/seed/upvote"
#endif
    NSString *URLString = [NSString stringWithFormat:UPVOTE_SEED_ENDPOINT];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    data[@"seed_id"] = self.seedID;
    data[@"vendor_id_str"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"vendorIDStr"];
    if (self.hasbeenUpvoted) {
        data[@"upvote_sign"] = @"up";
    } else {
        data[@"upvote_sign"] = @"down";
    }

    [manager POST:URLString parameters:data progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        NSLog(@"Data: %@", responseObject);

    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"Error Response: %@", errResponse);
    }];

}

- (void) highlightBorder {
    [self.upvoteButton setBackgroundColor:[UIColor greenColor]];
    [[self.upvoteButton layer] setBorderColor:[UIColor greenColor].CGColor];
}

- (void) unhighlightBorder {
    [self.upvoteButton setBackgroundColor:[UIColor whiteColor]];
    [[self.upvoteButton layer] setBorderColor:[UIColor blackColor].CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
