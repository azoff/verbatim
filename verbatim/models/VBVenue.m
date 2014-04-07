//
//  VBVenue.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBVenue.h"
#import <Parse/PFObject+Subclass.h>

@implementation VBVenue

+(NSString *)parseClassName
{
    return @"Venue";
}

@dynamic foursquareID;
@dynamic name;
@dynamic address;
@synthesize distance;


-(PFQuery *)checkedInUsersQuery
{
    PFQuery *query = [VBUser query];
    [query whereKey:@"venue" equalTo:self];
    return query;
}

-(void)checkedInUsersWithSuccess:(void (^)(NSArray*))success
                      andFailure:(void (^)(NSError*))failure
{
    [[self checkedInUsersQuery] findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) success(users);
        else failure(error);
    }];
}

-(void)checkedInUserCountWithSuccess:(void (^)(int))success
                          andFailure:(void (^)(NSError*))failure
{
    [[self checkedInUsersQuery] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) success(number);
        else failure(error);
    }];
}

@end
