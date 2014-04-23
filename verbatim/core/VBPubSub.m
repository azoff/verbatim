//
//  VBPubSub.m
//  verbatim
//
//  Created by Nicolas Halper on 4/9/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBPubSub.h"

NSString * const FIREBASE_URL = @"https://blazing-fire-9021.firebaseio.com/users";

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
    return [self.root childByAppendingPath:user.foursquareID];
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
