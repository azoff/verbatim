//
//  VBUser.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUser.h"
#import <Parse/PFObject+Subclass.h>

NSString* VBUserDefaultLabel = @"Microphone";
NSString* VBUserEventSourceChanged = @"VBUserEventSourceChanged";
NSString* VBUserEventCurrentUserAdded   = @"VBUserEventCurrentUserAdded";
NSString* VBUserEventCurrentUserRemoved = @"VBUserEventCurrentUserRemoved";
NSString* VBUserEventCheckedIn          = @"VBUserEventCheckedIn";

VBUser* currentUser;

@implementation VBUser

@dynamic firstName;
@dynamic lastName;
@dynamic canonical;
@dynamic venue;

-(BOOL)isCheckedIn
{
    return self.venue != nil;
}

-(BOOL)isListeningToSelf
{
    return [self isEqualObject:self.source];
}

-(BOOL)isNotListeningToSelf
{
    return ![self isListeningToSelf];
}

-(void)listenerCountWithSuccess:(void (^)(int))success
                     andFailure:(void (^)(NSError*))failure
{
    PFQuery *query = [self.class query];
    [query whereKey:@"source" equalTo:self];
    [self.source fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) failure(error);
        NSUInteger plusMe = self.isListeningToSelf ? 1 : 0;
        return [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (error) failure(error);
            else success(number+plusMe);
        }];
    }];
}

-(void)checkInWithVenue:(VBVenue *)venue
                success:(void(^)(VBUser*))success
                failure:(void(^)(NSError*))failure;
{
    // validate user
    if ([self.class.currentUser foursquareID] != self.foursquareID) {
        [NSException raise:@"Invalid User Access" format:@"Only allowed to change venue for current user"];
    }
    
    // exit early if no change
    if ([venue.foursquareID isEqualToString:[self.venue foursquareID]] && self.objectId) {
        success(self);
        return;
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
    if (!self.venue && !self.canonical && !self.source && self.objectId) {
        success(self);
        return;
    }
    self.source    = nil;
    self.venue     = nil;
    self.canonical = false;
    [self upsertWithSuccess:success andFailure:failure];
}

-(void)saveSourceWithUser:(VBUser *)user
                success:(void(^)(VBUser*))success
                failure:(void(^)(NSError*))failure;
{
    // validate user
    if ([self.class.currentUser foursquareID] != self.foursquareID) {
        [NSException raise:@"Invalid User Access" format:@"Only allowed to change source for current user"];
    }
    
    // exit early if no change
    if ([user isEqualObject:self.source] && self.objectId) {
        success(self);
        return;
    }
    
    // save the source to the user
    self.source = user;
    [self upsertWithSuccess:^(id user) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VBUserEventSourceChanged object:self userInfo:@{@"source": user}];
        success(user);
    } andFailure:failure];
}

-(NSString *)label
{
    
    VBUser *cur = [VBUser currentUser];
    if ([self.foursquareID isEqualToString:[cur foursquareID]])
        return VBUserDefaultLabel;
    
    NSMutableString *label = [NSMutableString string];
    
    if (self.firstName != nil && self.firstName.length > 0)
        [label appendString:self.firstName];
    
    if (self.lastName != nil && self.lastName.length > 0) {
        if (label.length > 0)
            [label appendFormat:@" %@.", [self.lastName substringToIndex:1]];
        else
            [label appendString:self.lastName];
    }
    
    if (label.length <= 0)
        [label appendString:@"Anonymous"];
    
    return label;
        
}

- (VBUser *)source
{
    id source = self[@"source"];
    return source ? source : self;
}

-(void)setSource:(VBUser *)source
{
    if (source == nil)
        [self removeObjectForKey:@"source"];
    else if (![self.source isEqualObject:source])
        self[@"source"] = source;
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
        currentUser = nil;
        [center postNotificationName:VBUserEventCurrentUserRemoved object:self];
    } else {
        [VBFoursquare currentUserDetailsWithSuccess:^(VBUser *user) {
            [user upsertWithSuccess:^(VBUser *_user) {
                currentUser = _user;
                [center postNotificationName:VBUserEventCurrentUserAdded object:self];
            } andFailure:failure];
        } andFailure:failure];
    }
}

@end
