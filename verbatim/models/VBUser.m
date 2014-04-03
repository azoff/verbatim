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

-(NSString *)foursquareID
{
    return self[@"foursquare_id"];
}

-(void)setFoursquareID:(NSString *)foursquareID
{
    self[@"foursquare_id"] = foursquareID;
}

-(VBVenue *)venue
{
    return self[@"venue"];
}

-(void)setVenue:(VBVenue *)venue
{
    self[@"venue"] = venue;
}

- (VBUser *)source
{
    return self[@"source"];
}

-(void)setSource:(VBUser *)source
{
    self[@"source"] = source;
}

-(NSString *)name
{
    return self[@"name"];
}

-(void)setName:(NSString *)name
{
    self[@"name"] = name;
}


@end
