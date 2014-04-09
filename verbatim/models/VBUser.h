//
//  VBUser.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBVenue.h"

@interface VBUser : PFObject<PFSubclassing>

@property (nonatomic) NSString * foursquareID; // for reference
@property (nonatomic) VBVenue  * venue;        // checked-in venue, could be nil
@property (nonatomic) VBUser   * source;       // input source, defaults to self
@property (nonatomic) NSString * firstName;    // from foursquare
@property (nonatomic) NSString * lastName;    // from foursquare

+(instancetype)userWithDictionary:(NSDictionary *)dictionary;

@end
