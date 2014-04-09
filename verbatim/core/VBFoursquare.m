//
//  VBFoursquare.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/6/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBFoursquare.h"
#import <Foursquare-API-v2/Foursquare2.h>
#import <AKLocationManager/AKLocationManager.h>

NSString * VBFoursquareEventAuthorized   = @"VBFoursquareEventAuthorized";
NSString * VBFoursquareEventDeauthorized = @"VBFoursquareEventDeauthorized";

NSString * const CLIENT_ID     = @"UOULYSQU10DNDEGTKFVZDP4WGDQUSTUMBJJIAYT33W1CCJAM";
NSString * const CLIENT_SECRET = @"WMJUL3BUYEMGN4M4U045NUEZLCQAAFYAKW4RAZGLJGYY3L34";
NSString * const CALLBACK_URL  = @"verbatim://foursquare";

@implementation VBFoursquare

+(void)setup
{
    [Foursquare2 setupFoursquareWithClientId:CLIENT_ID
                                      secret:CLIENT_SECRET
                                 callbackURL:CALLBACK_URL];
}

+(BOOL)handleURL:(NSURL *)url
{
    return [Foursquare2 handleURL:url];
}

+(BOOL)isAuthorized
{
    return [Foursquare2 isAuthorized];
}

+(void)authorize
{
    [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:VBFoursquareEventAuthorized object:self];
        }
    }];
}

+(void)deauthorize
{
    if (self.isAuthorized) {
        [Foursquare2 removeAccessToken];
        [[NSNotificationCenter defaultCenter] postNotificationName:VBFoursquareEventDeauthorized object:self];
    }
}

+(void)venuesNearbyWithSuccess:(void(^)(NSArray*))success
                    andFailure:(void(^)(NSError*))failure
{
    [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location) {
        [Foursquare2 venueSearchNearByLatitude:@(location.coordinate.latitude) longitude:@(location.coordinate.longitude) query:nil limit:nil intent:intentCheckin radius:@500 categoryId:nil
                                      callback:^(BOOL found, id result) {
                                          if (found)
                                              [self convertResult:result toVenuesWithBlock:success];
                                          else
                                              failure(result);
                                      }];
    } failedBlock:failure];
}

+(void)currentUserDetailsWithSuccess:(void(^)(VBUser*))success
                          andFailure:(void(^)(NSError*))failure
{
    [Foursquare2 userGetDetail:@"self" callback:^(BOOL found, id result) {
        if (found) [self convertResult:result toUserWithBlock:success];
        else failure(result);
    }];
}

+(void)convertResult:(NSDictionary *)result toUserWithBlock:(void(^)(VBUser*))block
{
    NSDictionary *dict = [result valueForKeyPath:@"response.user"];
    VBUser *user = [VBUser userWithDictionary:dict];
    block(user);
}

+(void)convertResult:(NSDictionary *)result toVenuesWithBlock:(void(^)(NSArray*))block
{
    NSArray *dicts         = [result valueForKeyPath:@"response.venues"];
    NSMutableArray *venues = [NSMutableArray array];
    for (NSDictionary *dict in dicts)
        [venues addObject:[VBVenue venueWithDictionary:dict]];
    block(venues);
}


@end
