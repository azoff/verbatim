//
//  VBVenue.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//
#import "VBFoursquareObject.h"
#import <Parse/PFGeoPoint.h>

@interface VBVenue : VBFoursquareObject<PFSubclassing>

@property (nonatomic) NSString * name;         // for display in table views
@property (nonatomic) NSString * address;      // for display in table views
@property (nonatomic) PFGeoPoint *geoPoint;    // lat/long from Foursquare, if available
@property (nonatomic) NSNumber * distance;     // in meters, from location (not saved, used in table views)

-(void)checkedInUsersWithSuccess:(void (^)(NSArray*))success
                      andFailure:(void (^)(NSError*))failure;

-(void)checkedInUserCountWithSuccess:(void (^)(int))success
                          andFailure:(void (^)(NSError*))failure;

+(instancetype)venueWithDictionary:(NSDictionary*)dictionary;

+(NSArray*)venuesNearBy:(CLLocation *)location;
@end
