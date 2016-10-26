//
//  SeedsTableViewModelObject.h
//  seed
//
//  Created by Sid Jha on 2016-10-26.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeedsTableViewModelObject : NSObject

@property (nonatomic) int seedID;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *link;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic) int seederID;
@property (nonatomic) NSString *username;
@property (nonatomic) BOOL isActive;
@property (nonatomic) NSDate *timestamp;
@property (nonatomic) int upvotes;

- (instancetype) initWithJSON:(NSMutableDictionary *)jsonData;

@end
