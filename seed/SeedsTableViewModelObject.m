//
//  SeedsTableViewModelObject.m
//  seed
//
//  Created by Sid Jha on 2016-10-26.
//  Copyright © 2016 Mesh8. All rights reserved.
//

#import "SeedsTableViewModelObject.h"

@implementation SeedsTableViewModelObject

- (instancetype) initWithJSON:(NSMutableDictionary *)jsonData{
    self = [super init];
    if (self) {
        self.seedID = [jsonData[@"id"] intValue];
        self.title = jsonData[@"title"];
        self.link = jsonData[@"link"];
        self.lat = [jsonData[@"lat"] doubleValue];
        self.lng = [jsonData[@"lng"] doubleValue];
        self.seederID = [jsonData[@"seeder_id"] intValue];
        self.username = jsonData[@"username"];
        self.isActive = [jsonData[@"isActive"] boolValue];
        self.timestamp = [self dateFromTimestamp:jsonData[@"timestamp"]];
        self.upvotes = [jsonData[@"upvotes"] intValue];
    }
    return self;
}

- (NSDate *)dateFromTimestamp:(NSString *)timestamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    return [dateFormatter dateFromString:timestamp];
}


@end
