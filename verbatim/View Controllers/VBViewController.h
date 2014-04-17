//
//  VBViewController.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/16/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBNavigationController.h"

@interface VBViewController : UIViewController

-(VBNavigationController*)vbNavigationController;
-(void)setupNavigationBar;

@end
