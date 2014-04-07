//
//  VBFoursquare.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/6/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUser.h"

extern NSString * VBFoursquareEventAuthorized;
extern NSString * VBFoursquareEventDeauthorized;

@interface VBFoursquare : NSObject

+(void)setup;
+(BOOL)handleURL:(NSURL*)url;

+(BOOL)isAuthorized;
+(void)authorize;
+(void)deauthorize;

+(void)venuesNearbyWithSuccess:(void(^)(NSArray*))success
                    andFailure:(void(^)(NSError*))failure;

+(void)currentUserDetailsWithSuccess:(void(^)(VBUser*))success
                          andFailure:(void(^)(NSError*))failure;


@end
