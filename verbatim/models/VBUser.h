//
//  VBUser.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Parse/Parse.h>

@interface VBUser : PFUser

@property (nonatomic, weak) NSString * foursquareID; // for reference
@property (nonatomic, weak) VBVenue  * venue;        // checked-in venue, could be nil
@property (nonatomic, weak) VBUser   * source;       // input source, defaults to self
@property (nonatomic, weak) NSString * name;         // from foursquare

+(instancetype)currentUser;

@end
