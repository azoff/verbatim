//
//  VBUser.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUser.h"
#import "VBPubSub.h"
#import <Parse/PFObject+Subclass.h>

NSString* VBUserDefaultLabel = @"Microphone";
NSString* VBUserEventSourceChanged = @"VBUserEventSourceChanged";
NSString* VBUserEventCurrentUserAdded   = @"VBUserEventCurrentUserAdded";
NSString* VBUserEventCurrentUserRemoved = @"VBUserEventCurrentUserRemoved";
NSString* VBUserEventCheckedIn          = @"VBUserEventCheckedIn";
NSString* VBUserEventCheckedOut         = @"VBUserEventCheckedOut";
NSString* VBUserEventCameraSourceChanged = @"VBUserEventCameraSourceChanged";

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
    
    // exit early if no change
    if ([venue isEqualObject:self.venue] && self.objectId) {
        success(self);
        return;
    }

    // (1) check out, if currently checked in
    [self checkOutWithSuccess:^(VBUser *user) {
        
        // (2) check in on foursquare
        [VBFoursquare checkInWithVenue:venue success:^(VBVenue *venue) {
            
            // (3) create the venue on parse
            [venue upsertWithSuccess:^(VBVenue *venue) {
                
                // (4) save the venu to the user
                self.venue = venue;
                [self upsertWithSuccess:^(VBUser *user) {
                    
                    // (5) publish on Firebase
                    [VBPubSub publishNewUser:user atVenue:venue success:^(Firebase *ref) {
                        
                        // (6) publish locally
                        [[NSNotificationCenter defaultCenter] postNotificationName:VBUserEventCheckedIn object:self userInfo:@{@"venue": venue}];
                        success(user);
                        
                    } failure:failure];
                } andFailure:failure];
            } andFailure:failure];
        } failure:failure];
    } andFailure:failure];
    
}

-(void)checkOutWithSuccess:(void (^)(VBUser *))success
                andFailure:(void (^)(NSError *))failure
{
    
    // exit early if already reset
    if (!self.venue && !self.canonical && !self.source && self.objectId) {
        success(self);
        return;
    }
    
    void(^reset)(id) = ^(id result){
        
        // (2) remove the user's source, since it is no longer applicable
        [self saveSourceWithUser:nil success:^(VBUser *user) {
            
            // (3) update the user internals to represent the checked out state
            self.venue     = nil;
            self.canonical = false;
            [self upsertWithSuccess:^(VBUser *user) {
                
                // (4) delete any captions the user has
                [VBPubSub deleteChannelWithUser:user success:^(Firebase *ref) {
                    
                    // (5) publish locally
                    [[NSNotificationCenter defaultCenter] postNotificationName:VBUserEventCheckedOut object:self userInfo:nil];
                    success(self);
                    
                } failure:failure];
            } andFailure:failure];
        } failure:failure];
    };
    
    // (1) publish checkout if the user is checked in
    if (!self.venue) reset(nil);
    else [self.venue fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) failure(error);
        else [VBPubSub redactExistingUser:self fromVenue:self.venue success:reset failure:failure];
    }];
    
}

-(void)saveSourceWithUser:(VBUser *)source
                success:(void(^)(VBUser*))success
                failure:(void(^)(NSError*))failure;
{
    
    // exit early if no change
    if ([source isEqualObject:self.source] && self.objectId) {
        success(self);
        return;
    }
    
    void(^notifySourceChange)(id) = ^(id ref){
        // (4) finally, publish locally
        [[NSNotificationCenter defaultCenter] postNotificationName:VBUserEventSourceChanged object:self userInfo:@{@"source": self}];
        success(self);
    };
    
    void(^updateSource)(id) = ^(id ref){
        
        // (2) save the source ref change to the user
        BOOL validSource = source && ![source isEqualObject:self];
        if (validSource) self[@"source"] = source;
        else [self removeObjectForKey:@"source"];
        [self upsertWithSuccess:^(VBUser *user) {
            
            // (3) check if we're adding a new source, if so, publish
            if (!validSource) notifySourceChange(user);
            else [VBPubSub publishNewListener:self toSource:source success:notifySourceChange failure:failure];
            
        } andFailure:failure];
    };
    
    // (1) make sure we don't have a current source
    if (!self.source) updateSource(nil);
    else [VBPubSub redactExistingListener:self fromSource:self.source success:updateSource failure:failure];
    
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
            [user upsertWithSuccess:^(VBUser *user) {
                [user checkOutWithSuccess:^(VBUser *user) {
                    currentUser = user;
                    [center postNotificationName:VBUserEventCurrentUserAdded object:self];
                } andFailure:failure];
            } andFailure:failure];
        } andFailure:failure];
    }
}

@end
