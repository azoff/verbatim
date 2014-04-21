//
//  VBFoursquareModel.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/10/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Parse/Parse.h>

@interface VBFoursquareObject : PFObject

@property (nonatomic) NSString * foursquareID;

-(BOOL)isEqualObject:(VBFoursquareObject *)object;

-(void)upsertWithSuccess:(void(^)(id))success
              andFailure:(void(^)(NSError*))failure;

@end
