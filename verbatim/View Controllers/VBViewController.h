//
//  VBViewController.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/16/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBRootController.h"

@interface VBViewController : UIViewController

@property (nonatomic, readonly) VBRootController *rootController;

-(void)onRootMadeActive; // abstract, must be implemented by super class
-(void)onRootViewDidLoad; // called after the root view is loaded for the first time.

@end
