//
//  VBPubSub.m
//  verbatim
//
//  Created by Nicolas Halper on 4/9/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBPubSub.h"

NSString * const FIREBASE_URL = @"https://blazing-fire-9021.firebaseio.com";

@implementation VBPubSub

+(void)publishNewCaption:(NSString*)value fromUser:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    [[[self channelForUser:user] childByAutoId] setValue:value withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}

+(void)deleteChannelWithUser:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    [[self channelForUser:user] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}

+(void)publishNewUser:(VBUser *)user atVenue:(VBVenue *)venue success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    [[[self channelForVenue:venue] childByAppendingPath:user.foursquareID] setValue:user.objectId withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}

+(void)redactExistingUser:(VBUser *)user fromVenue:(VBVenue *)venue success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    [[[self channelForVenue:venue] childByAppendingPath:user.foursquareID] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}

+(void)publishNewListener:(VBUser *)listener toSource:(VBUser *)source success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    [[[self channelForSource:source] childByAppendingPath:listener.foursquareID] setValue:listener.objectId withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}

+(void)redactExistingListener:(VBUser *)listener fromSource:(VBUser *)source success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    [[[self channelForSource:source] childByAppendingPath:listener.foursquareID] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}
+(void)publishImageData:(NSData *)imageData user:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
    
    [[self channelForUserImage:user] setValue:base64String withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}

+(FirebaseHandle)subscribeToUserImageData:(VBUser *)user success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    id block = ^(FDataSnapshot *snapshot) {
        if (!(snapshot.value == (id)[NSNull null])) {
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:snapshot.value options:0];
            success(decodedData);
        }
    };
    return [[self channelForUserImage:user] observeEventType:FEventTypeValue withBlock:block withCancelBlock:failure];
}

+(FirebaseHandle)subscribeToUserCaptionAdditions:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure
{
    id block = ^(FDataSnapshot *snapshot) { success(snapshot.value); };
    return [[self channelForUser:user] observeEventType:FEventTypeChildAdded withBlock:block withCancelBlock:failure];
}

+(FirebaseHandle)subscribeToListenerAdditions:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure
{
    id block = ^(FDataSnapshot *snapshot) { success(snapshot.value); };
    return [[self channelForSource:user] observeEventType:FEventTypeChildAdded withBlock:block withCancelBlock:failure];
}

+(FirebaseHandle)subscribeToListenerDeletions:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure
{
    id block = ^(FDataSnapshot *snapshot) { success(snapshot.value); };
    return [[self channelForSource:user] observeEventType:FEventTypeChildRemoved withBlock:block withCancelBlock:failure];
}

+(FirebaseHandle)subscribeToVenueUserAdditions:(VBVenue *)venue success:(void(^)(id))success failure:(void(^)(NSError*))failure
{
    id block = ^(FDataSnapshot *snapshot) { success(snapshot.value); };
    return [[self channelForVenue:venue] observeEventType:FEventTypeChildAdded withBlock:block withCancelBlock:failure];
}

+(FirebaseHandle)subscribeToVenueUserDeletions:(VBVenue *)venue success:(void(^)(id))success failure:(void(^)(NSError*))failure
{
    id block = ^(FDataSnapshot *snapshot) { success(snapshot.value); };
    return [[self channelForVenue:venue] observeEventType:FEventTypeChildRemoved withBlock:block withCancelBlock:failure];
}

+(void)unsubscribeFromVenue:(VBVenue *)venue handle:(FirebaseHandle)handle
{
    [[self channelForVenue:venue] removeObserverWithHandle:handle];
}

+(void)unsubscribeFromUser:(VBUser *)user handle:(FirebaseHandle)handle
{
    [[self channelForUser:user] removeObserverWithHandle:handle];
}

+(void)unsubscribeFromUserImage:(VBUser *)user handle:(FirebaseHandle)handle
{
    [[self channelForUserImage:user] removeObserverWithHandle:handle];
}

+(Firebase *)channelForSource:(VBUser *)source
{
    return [self.channelForSources childByAppendingPath:source.foursquareID];
}

+(Firebase *)channelForUser:(VBUser *)user
{
    return [self.channelForUsers childByAppendingPath:user.foursquareID];
}

+(Firebase *)channelForUserImage:(VBUser *)user
{
    return [self.channelForUserImages childByAppendingPath:user.foursquareID];
}

+(Firebase *)channelForVenue:(VBVenue *)venue
{
    return [self.channelForVenues childByAppendingPath:venue.foursquareID];
}

+(Firebase *)channelForSources
{
    return [self.channelForRoot childByAppendingPath:@"sources"];
}

+(Firebase *)channelForUsers
{
    return [self.channelForRoot childByAppendingPath:@"users"];
}

+(Firebase *)channelForUserImages
{
    return [self.channelForRoot childByAppendingPath:@"images"];
}

+(Firebase *)channelForVenues
{
    return [self.channelForRoot childByAppendingPath:@"venues"];
}

+(Firebase *)channelForRoot
{
    static id _root = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _root = [[Firebase alloc] initWithUrl:FIREBASE_URL];
    });
    return _root;
}

@end
