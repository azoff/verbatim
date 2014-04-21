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
    return NSStringFromClass(self.class);
}

@dynamic foursquareID;
@dynamic name;
@dynamic address;
@synthesize distance;


-(void)syncWithSuccess :(void (^) (VBVenue *))success andError:(void (^) (NSError *))errorBlock
{
    PFQuery *venueQuery = [VBVenue query];
    [venueQuery whereKey:@"foursquareID" equalTo:self.foursquareID];
    NSArray *venues = [venueQuery findObjects];
    if (venues.count > 0) {
        self.objectId = ((VBVenue *)[venues firstObject]).objectId;
    } else {
        [self upsertWithSuccess:^(VBVenue *venue) {
            success(venue);
        } andFailure:^(NSError *error) {
            errorBlock(error);
        }];
    }
        
}

-(PFQuery *)checkedInUsersQuery
{
    PFQuery *query = [VBUser query];
    
    // straight lookup when using a hydrated venue
    if (self.objectId != nil) {
        [query whereKey:@"venue" equalTo:self];
        
        // otherwise use an outer join
    } else {
        PFQuery *venueQuery = [VBVenue query];
        [venueQuery whereKey:@"foursquareID" equalTo:self.foursquareID];
        [venueQuery setLimit:1];
        [query whereKey:@"venue" matchesQuery:venueQuery];
    }
    
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

-(void)checkedInUserCountWithSuccess:(void(^)(int))success
                          andFailure:(void(^)(NSError*))failure
{
    
    // get the user count
    [[self checkedInUsersQuery] countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) failure(error);
        else success(number);
    }];
    
}

+(instancetype)venueWithDictionary:(NSDictionary *)dictionary
{
    VBVenue *instance = [self object];
    instance.name = dictionary[@"name"];
    instance.foursquareID = dictionary[@"id"];
    instance.address = dictionary[@"location"][@"address"];
    instance.distance = dictionary[@"location"][@"distance"];
    return instance;
}

@end
