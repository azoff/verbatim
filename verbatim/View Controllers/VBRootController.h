//
//  VBNavigationController.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/19/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBRootController : UIViewController

- (void)renderViewControllerWithClass:(Class)class;
- (void)renderLastViewController;

@end
