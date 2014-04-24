//
//  VBUser.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBVenue.h"
#import "VBFoursquareObject.h"

extern NSString* VBUserDefaultLabel;
extern NSString* VBUserEventSourceChanged;
extern NSString* VBUserEventCurrentUserAdded;
extern NSString* VBUserEventCurrentUserRemoved;
extern NSString* VBUserEventCheckedIn;
extern NSString* VBUserEventCheckedOut;
extern NSString* VBUserEventSourceChanged;
extern NSString* VBUserEventCameraSourceChanged;

@interface VBUser : VBFoursquareObject<PFSubclassing>

@property (nonatomic) VBVenue  * venue;     // checked-in venue, could be nil
@property (nonatomic, readonly) VBUser   * source;          // user source at checked-in venue, could be nil;

@property (nonatomic) NSString * firstName; // from foursquare
@property (nonatomic) NSString * lastName;  // from foursquare
@property (nonatomic) BOOL canonical;  // when coming from editor

@property (nonatomic, readonly) NSString* label;
@property (nonatomic, readonly) BOOL isListeningToSelf;
@property (nonatomic, readonly) BOOL isNotListeningToSelf;

+(instancetype)userWithDictionary:(NSDictionary *)dictionary;
+(void)setupCurrentUser;
+(instancetype)currentUser;

-(BOOL)isCheckedIn;

-(void)saveSourceWithUser:(VBUser *)user
                  success:(void(^)(VBUser*))success
                  failure:(void(^)(NSError*))failure;

-(void)checkInWithVenue:(VBVenue *)venue
                success:(void(^)(VBUser*))success
                failure:(void(^)(NSError*))failure;

-(void)checkOutWithSuccess:(void (^)(VBUser *))success
                andFailure:(void (^)(NSError *))failure;

-(void)listenerCountWithSuccess:(void (^)(int))success
                     andFailure:(void (^)(NSError*))failure;

@end
