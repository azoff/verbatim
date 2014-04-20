//
//  VBVenueDataSource.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/19/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBVenueDataSource : NSObject<UITableViewDataSource>

+ (instancetype)sourceWithCellReuseIdentifier:(NSString *)identifier;
- (instancetype)initWithCellReuseIdentifier:(NSString *)identifier;
- (void)reloadWithError:(void(^)(NSError*))done;
@property (nonatomic) NSString* cellReuseIdentifier;

@end
