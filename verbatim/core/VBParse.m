//
//  VBParse.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBParse.h"

NSString * const APPLICATION_ID = @"Y3hSYuF2y9tzwgyaBGtu0IKSSLgNPyFX8QRaUo00";
NSString * const CLIENT_KEY     = @"Ltv2ItjS8XVGDbUBhpbMJbOPlQHO4gHG9RPOnn9w";

@implementation VBParse

+(void)setupWithLaunchOptions:(NSDictionary*)launchOptions
{
    static dispatch_once_t setupOnce;
    dispatch_once(&setupOnce, ^{
        [VBUser registerSubclass];
        [VBVenue registerSubclass];
        [VBUser setupCurrentUser];
        [Parse setApplicationId:APPLICATION_ID clientKey:CLIENT_KEY];
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    });
}

@end
