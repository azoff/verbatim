//
//  VBUserDelegate.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/21/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VBUserSubDelegate <NSObject>

@required
-(UITableViewCell *)cellForHeightMeasurement;

@optional
-(void)didSelectUser:(VBUser *)user;

@end

@interface VBUserDelegate : NSObject <UITableViewDelegate>

+(instancetype)delegateWithSubDelegate:(id<VBUserSubDelegate>)subDelegate;
-(instancetype)initWithSubDelegate:(id<VBUserSubDelegate>)subDelegate;
@property (nonatomic) id<VBUserSubDelegate> subDelegate;

@end
