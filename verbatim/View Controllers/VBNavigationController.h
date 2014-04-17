//
//  VBNavigationController.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/16/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Factory.h"

@interface VBNavigationController : UINavigationController

@property (nonatomic) CATransition *transition;

-(void)setRootViewController:(UIViewController*)controller animated:(BOOL)animated;
-(void)navigationBarShowBackground:(BOOL)visible;

@end
