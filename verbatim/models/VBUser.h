//
//  VBUser.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBVenue.h"
#import "VBFoursquareObject.h"

extern NSString* VBUserEventSourceChanged;
extern NSString* VBUserEventCurrentUserAdded;
extern NSString* VBUserEventCurrentUserRemoved;
extern NSString* VBUserEventCheckedIn;

@interface VBUser : VBFoursquareObject<PFSubclassing>

@property (nonatomic) VBVenue  * venue;     // checked-in venue, could be nil
@property (nonatomic) NSString * firstName; // from foursquare
@property (nonatomic) NSString * lastName;  // from foursquare

+(instancetype)userWithDictionary:(NSDictionary *)dictionary;
+(void)setupCurrentUser;
+(instancetype)currentUser;

-(void)checkInWithVenue:(VBVenue *)venue
                success:(void(^)(VBUser*))success
                failure:(void(^)(NSError*))failure;

@end
