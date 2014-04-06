//
//  VBVenue.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

@interface VBVenue : PFObject<PFSubclassing>

@property (nonatomic) NSString * foursquareID; // for reference
@property (nonatomic) NSString * name;         // for display in table views
@property (nonatomic) NSString * address;      // for display in table views
@property (nonatomic) NSUInteger distance;     // in meters, from location (not saved, used in table views)

-(void)checkedInUsersWithSuccess:(void (^)(NSArray*))success
                      andFailure:(void (^)(NSError*))failure;

-(void)checkedInUserCountWithSuccess:(void (^)(int))success
                          andFailure:(void (^)(NSError*))failure;

@end
