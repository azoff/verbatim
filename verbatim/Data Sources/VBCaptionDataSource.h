//
//  VBCaptionDataSource.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/28/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBCaptionDataSource : NSObject<UITableViewDataSource>

+ (instancetype)sourceWithCellReuseIdentifier:(NSString *)identifier;
- (instancetype)initWithCellReuseIdentifier:(NSString *)identifier;
- (void)observeUpdateWithBlock:(void(^)(void))done;
- (NSString *)captionForIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic) NSString* cellReuseIdentifier;


@end
