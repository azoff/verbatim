//
//  VBCaptionDelegate.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/28/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBCaptionDataSource.h"

@interface VBCaptionDelegate : NSObject<UITableViewDelegate>

+(instancetype)delegateWithDataSource:(VBCaptionDataSource *)dataSource;
-(instancetype)initWithDataSource:(VBCaptionDataSource *)dataSource;
@property (nonatomic) VBCaptionDataSource *dataSource;

@end
