//
//  VBPubSub.m
//  verbatim
//
//  Created by Nicolas Halper on 4/9/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBPubSub.h"

NSString * const FIREBASE_URL = @"https://blazing-fire-9021.firebaseio.com/";

@interface VBPubSub ()

@end

@implementation VBPubSub

+(void)publishCaption:(NSString *)caption user:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    [[[self channelForUser:user] childByAutoId] setValue:caption withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error && failure) failure(error);
        else if(!error && success) success(ref);
    }];
}

+(FirebaseHandle)subscribeToUser:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure
{
    id block = ^(FDataSnapshot *snapshot) { success(snapshot.value); };
    return [[self channelForUser:user] observeEventType:FEventTypeChildAdded withBlock:block withCancelBlock:failure];
}

+(void)unsubscribeFromHandle:(FirebaseHandle)handle
{
    [self.root removeObserverWithHandle:handle];
}

+(Firebase *)channelForUser:(VBUser *)user
{
    return [self.root childByAppendingPath:[NSString stringWithFormat:@"users/%@",user.foursquareID]];
}

+(Firebase *)imageChannelForUser:(VBUser *)user
{
    return [self.root childByAppendingPath:[NSString stringWithFormat:@"userimages/%@",user.foursquareID]];
}

+(void)publishImageData:(NSData *)imageData user:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure
{
    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
    
    [[self imageChannelForUser:user] setValue:base64String withCompletionBlock:^(NSError *error, Firebase *ref) {
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
    return [[self imageChannelForUser:user] observeEventType:FEventTypeValue withBlock:block withCancelBlock:failure];
}

+(Firebase *)root
{
    static id _root = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _root = [[Firebase alloc] initWithUrl:FIREBASE_URL];
    });
    return _root;
}

@end
