//
//  VBVenue.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//
#import "VBFoursquareObject.h"

@interface VBVenue : VBFoursquareObject<PFSubclassing>

@property (nonatomic) NSString * name;         // for display in table views
@property (nonatomic) NSString * address;      // for display in table views
@property (nonatomic) NSNumber * distance;     // in meters, from location (not saved, used in table views)

-(void)syncWithSuccess :(void (^) (VBVenue *))success andError:(void (^) (NSError *))errorBlock;

-(void)checkedInUsersWithSuccess:(void (^)(NSArray*))success
                      andFailure:(void (^)(NSError*))failure;

-(void)checkedInUserCountWithSuccess:(void (^)(int))success
                          andFailure:(void (^)(NSError*))failure;

+(instancetype)venueWithDictionary:(NSDictionary*)dictionary;

@end
