//
//  VBUser.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

@interface VBUser : PFUser

@property (nonatomic) NSString * foursquareID;    // for reference
@property (nonatomic, readonly) VBVenue  * venue; // checked-in venue, could be nil
@property (nonatomic) VBUser   * source;          // input source, defaults to self
@property (nonatomic) NSString * name;            // from foursquare

-(void)checkInToVenue:(VBVenue *)venue
          withSuccess:(void(^)(BOOL))success
           andFailure:(void(^)(NSError *))failure;

-(BOOL)isAnonymous;

+(instancetype)currentUser;

@end
