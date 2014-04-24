//
//  VBPubSub.h
//  verbatim
//
//  Created by Nicolas Halper on 4/9/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@interface VBPubSub : NSObject

+(void)publishNewCaption:(NSString*)value fromUser:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;
+(void)publishNewUser:(VBUser *)user atVenue:(VBVenue *)venue success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;
+(void)publishNewListener:(VBUser *)listener toSource:(VBUser *)source success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;
+(void)publishImageData:(NSData *)imageData user:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;

+(void)deleteChannelWithUser:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;
+(void)redactExistingUser:(VBUser *)user fromVenue:(VBVenue *)venue success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;
+(void)redactExistingListener:(VBUser *)listener fromSource:(VBUser *)source success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;

+(FirebaseHandle)subscribeToListenerAdditions:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure;
+(FirebaseHandle)subscribeToListenerDeletions:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure;
+(FirebaseHandle)subscribeToUserCaptionAdditions:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure;
+(FirebaseHandle)subscribeToVenueUserAdditions:(VBVenue *)venue success:(void(^)(id))success failure:(void(^)(NSError*))failure;
+(FirebaseHandle)subscribeToVenueUserDeletions:(VBVenue *)venue success:(void(^)(id))success failure:(void(^)(NSError*))failure;
+(FirebaseHandle)subscribeToUserImageData:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure;

+(void)unsubscribeFromVenue:(VBVenue *)venue handle:(FirebaseHandle)handle;
+(void)unsubscribeFromUser:(VBUser *)user handle:(FirebaseHandle)handle;
+(void)unsubscribeFromUserImage:(VBUser *)user handle:(FirebaseHandle)handle;

@end
