//
//  VBUser.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUser.h"

@implementation VBUser

+(instancetype)currentUser
{
    return [super currentUser];
}

@dynamic foursquareID;
@dynamic venue;
@dynamic source;
@dynamic name;

-(BOOL)isAnonymous
{
    return [PFAnonymousUtils isLinkedWithUser:self];
}

-(void)checkInToVenue:(VBVenue *)venue
          withSuccess:(void(^)(BOOL))success
           andFailure:(void(^)(NSError *))failure
{
    self[@"venue"] = venue;
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) failure(error);
        else success(succeeded);
    }];
}

@end
