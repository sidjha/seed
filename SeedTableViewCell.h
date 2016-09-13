//
//  SeedTableViewCell.h
//  seed
//
//  Created by Sid Jha on 2016-09-13.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *seederLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;

@end
