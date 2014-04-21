//
//  VBFoursquareModel.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/10/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBFoursquareObject.h"

NSUInteger const PARSE_OBJECT_NOT_FOUND = 101;

@implementation VBFoursquareObject

@dynamic foursquareID;

-(PFQuery *)query
{
    return nil; // prevents compiler errors
}

-(void)upsertWithSuccess:(void(^)(id))success
              andFailure:(void(^)(NSError*))failure
{
    
    // for when we're done
    PFBooleanResultBlock done = ^(BOOL succeeded, NSError *error) {
        if (succeeded) success(self);
        else failure(error);
    };
    
    // first check to see if the object is already hydrated...
    if (self.objectId) {
        // and has nothing to save...
        if (self.isDirty) done(true, nil);
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
        // or set the object ID and save the object
        else {
            self.objectId = object.objectId;
            [self saveInBackgroundWithBlock:done];
        }
        
    }];
    
    
}

@end
