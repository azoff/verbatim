//
//  VBUser.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation VBUser

+(NSString *)parseClassName
{
    return @"User";
}

@dynamic foursquareID;
@dynamic venue;
@dynamic source;
@dynamic firstName;
@dynamic lastName;


+(instancetype)userWithDictionary:(NSDictionary *)dictionary
{
    VBUser *user = [self object];
    user.foursquareID = dictionary[@"id"];
    user.firstName = dictionary[@"firstName"];
    user.lastName = dictionary[@"lastName"];
    return user;
}

@end
