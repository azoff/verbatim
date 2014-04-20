//
//  VBVenueDelegate.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/20/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VBVenueSubDelegate <NSObject>

@required
-(UITableViewCell *)cellForHeightMeasurement;

@optional
-(void)didSelectVenue:(VBVenue *)venue;

@end

@interface VBVenueDelegate : NSObject<UITableViewDelegate>

+(instancetype)delegateWithSubDelegate:(id<VBVenueSubDelegate>)subDelegate;
-(instancetype)initWithSubDelegate:(id<VBVenueSubDelegate>)subDelegate;
@property (nonatomic) id<VBVenueSubDelegate> subDelegate;


@end
