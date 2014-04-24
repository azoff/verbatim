//
//  VBFoursquareModel.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/10/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBFoursquareObject.h"
#import <Parse/PFObject+Subclass.h>

NSUInteger const PARSE_OBJECT_NOT_FOUND = 101;

@implementation VBFoursquareObject

@dynamic foursquareID;

-(BOOL)isEqualObject:(VBFoursquareObject *)object
{
    return [self.foursquareID isEqualToString:[object foursquareID]];
}

-(void)upsertWithSuccess:(void(^)(id))success
              andFailure:(void(^)(NSError*))failure
{
    
    __block id result = self;
    
    // for when we're done
    PFBooleanResultBlock done = ^(BOOL succeeded, NSError *error) {
        if (succeeded) success(result);
        else failure(error);
    };
    
    // first check to see if the object is already hydrated...
    if (self.objectId) {
        // and has nothing to save...
        if (!self.isDirty) done(true, nil);
        // or something to save...
        else [self saveInBackgroundWithBlock:done];
        return;
    }
    
    // next, check if the object already exists
    PFQuery *query = [self.class query];
    [query whereKey:@"foursquareID" equalTo:self.foursquareID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        // blow up on error...
        if (error != nil && error.code != PARSE_OBJECT_NOT_FOUND)
            done(false, error);
        // create a new object if not found...
        else if (!object)
            [self saveInBackgroundWithBlock:done];
        // or merge the objects
        else {
            self.objectId = object.objectId;
            for(id key in [object allKeys]) {
                if (self[key] == nil) {
                    self[key] = object[key];
                    if ([self[key] isKindOfClass:PFObject.class]) {
                        [self[key] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if (error) failure(error);
                            else self[key] = object;
                        }];
                    }
                }
            }
            result = object;
            [self saveInBackgroundWithBlock:done];
        }
        
    }];
    
    
}

+(void)objectCachedInBackgroundWithId:(NSString *)objectId success:(void(^)(id))success failure:(void(^)(NSError*))failure
{
    PFQuery *query = [self query];
// temporarily disabling caching...
//    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
//    query.maxCacheAge = 60 * 60 * 24; // object details cached for a day
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error) {
        // blow up on error
        if (error != nil && error.code != PARSE_OBJECT_NOT_FOUND) failure(error);
        // return nil or the object, if found
        else success(object);
    }];
}

@end
