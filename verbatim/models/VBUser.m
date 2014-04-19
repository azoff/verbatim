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
NSString* VBUserEventSourceChanged      = @"VBUserEventSourceChanged";

VBUser* currentUser;

@implementation VBUser

@dynamic venue;
@dynamic firstName;
@dynamic lastName;
@dynamic canonical;
@dynamic source;

-(void)setSource:(VBUser *)source
{
    id old = self.source;
    self[@"source"] = source;
    if (![source isEqual:old])
        [[NSNotificationCenter defaultCenter] postNotificationName:VBUserEventSourceChanged object:self];
}

-(BOOL)isCheckedIn
{
    return self.venue != nil;
}

-(void)listenerCountWithSuccess:(void (^)(int))success
                     andFailure:(void (^)(NSError*))failure
{
    PFQuery *query = [self.class query];
    [query whereKey:@"source" equalTo:self];
    return [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error) failure(error);
        else success(number);
    }];
}

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

-(void)checkOutWithSuccess:(void (^)(VBUser *))success
                andFailure:(void (^)(NSError *))failure
{
    if (!self.venue && !self.canonical && !self.source) {
        success(self);
        return;
    }
    self.source    = nil;
    self.venue     = nil;
    self.canonical = false;
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) success(self);
        else failure(error);
    }];
}

+(NSString *)parseClassName
{
    return NSStringFromClass(self.class);
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
        id center = [NSNotificationCenter defaultCenter];
        SEL selector = @selector(updateCurrentUser);
        NSArray *names = @[VBFoursquareEventAuthorized, VBFoursquareEventDeauthorized];
        for (NSString *name in names)
            [center addObserver:self selector:selector name:name object:nil];
    });
}

+(void)updateCurrentUser
{
    id center = [NSNotificationCenter defaultCenter];
    id failure = ^(NSError *error) { [VBHUD showWithError:error]; };
    if (!VBFoursquare.isAuthorized) {
        [currentUser checkOutWithSuccess:^(VBUser *user) {
            currentUser = nil;
            [center postNotificationName:VBUserEventCurrentUserRemoved object:self];
        } andFailure:failure];
    } else {
        [VBFoursquare currentUserDetailsWithSuccess:^(VBUser *user) {
            currentUser = user;
            [user checkOutWithSuccess:^(VBUser *user) {
                [center postNotificationName:VBUserEventCurrentUserAdded object:self];
            } andFailure:failure];
        } andFailure:failure];
    }
}

@end
