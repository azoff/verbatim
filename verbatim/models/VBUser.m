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
NSString* VBUserEventCheckedIn          = @"VBUserEventCheckedIn";

VBUser* currentUser;

@implementation VBUser

@dynamic venue;
@dynamic source;
@dynamic firstName;
@dynamic lastName;

-(void)checkInWithVenue:(VBVenue *)venue
                success:(void(^)(VBUser*))success
                failure:(void(^)(NSError*))failure;
{
    // validate user
    if ([self.class.currentUser foursquareID] != self.foursquareID) {
        id desc  = @{NSLocalizedDescriptionKey:@"Only current user may check in"};
        id error = [NSError errorWithDomain:@"" code:0 userInfo:desc];
        failure(error);
    }
    
    // check in on foursquare
    [VBFoursquare checkInWithVenue:venue success:^(VBVenue *venue) {
        // create the venue on parse
        [venue upsertWithSuccess:^(id venue) {
            // save the venu to the user
            self.venue = venue;
            [self upsertWithSuccess:^(id user) {
                [[NSNotificationCenter defaultCenter] postNotificationName:VBUserEventCheckedIn object:self userInfo:@{@"venue": venue}];
                success(user);
            } andFailure:failure];
        } andFailure:failure];
    } failure:failure];
}

+(NSString *)parseClassName
{
    return @"User";
}

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
