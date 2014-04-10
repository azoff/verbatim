//
//  VBUser.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUser.h"
#import <Parse/PFObject+Subclass.h>

NSString* VBUserEventCurrentUserAdded   = @"VBUserEventCurrentUserAdded";
NSString* VBUserEventCurrentUserRemoved = @"VBUserEventCurrentUserRemoved";

VBUser* currentUser;

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

+(instancetype)currentUser
{
    return currentUser;
}

+(void)setupCurrentUser
{
    static dispatch_once_t setupOnce;
    dispatch_once(&setupOnce, ^{
        if (VBFoursquare.isAuthorized)
            [self updateCurrentUser];
        id center   = [NSNotificationCenter defaultCenter];
        SEL selector = @selector(updateCurrentUser);
        NSArray *names = @[VBFoursquareEventAuthorized, VBFoursquareEventDeauthorized];
        for (NSString *name in names)
            [center addObserver:self selector:selector name:name object:nil];
    });
}

+(void)updateCurrentUser
{
    id center = [NSNotificationCenter defaultCenter];
    if (!VBFoursquare.isAuthorized) {
        currentUser = nil;
        [center postNotificationName:VBUserEventCurrentUserRemoved object:self];
        return;
    }
    [VBFoursquare currentUserDetailsWithSuccess:^(VBUser *user) {
        currentUser = user;
        [center postNotificationName:VBUserEventCurrentUserAdded object:self];
    } andFailure:^(NSError *error) {
        //TODO: Use global error handler here
        NSLog(@"%@", error);
    }];
}

@end
