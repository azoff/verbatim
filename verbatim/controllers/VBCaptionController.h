//
//  VBCaptionScreen.h
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBCaptionController : UIViewController<UITableViewDataSource,UITableViewDelegate>

+ (instancetype)controller;

@property (strong,nonatomic) NSString *caption;

@end
