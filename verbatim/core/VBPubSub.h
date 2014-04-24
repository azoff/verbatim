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

+(void)publishCaption:(NSString *)caption user:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;
+(FirebaseHandle)subscribeToUser:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure;

+(void)publishImageData:(NSData *)imageData user:(VBUser *)user success:(void(^)(Firebase*))success failure:(void(^)(NSError*))failure;
+(FirebaseHandle)subscribeToUserImageData:(VBUser *)user success:(void(^)(id))success failure:(void(^)(NSError*))failure;

+(void)unsubscribeFromHandle:(FirebaseHandle)handle;


@end
