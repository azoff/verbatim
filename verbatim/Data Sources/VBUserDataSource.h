//
//  VBUserDataSource.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/21/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBUserDataSource : NSObject<UITableViewDataSource>

+ (instancetype)sourceWithCellReuseIdentifier:(NSString *)identifier andVenue:(VBVenue *)venue;
- (instancetype)initWithCellReuseIdentifier:(NSString *)identifier andVenue:(VBVenue *)venue;
- (void)observeUpdateWithBlock:(void(^)(NSError*))done;
@property (nonatomic) VBVenue *venue;
@property (nonatomic) NSString* cellReuseIdentifier;

@end
