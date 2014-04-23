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
