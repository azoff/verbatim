//
//  VBViewController.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/16/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBViewController.h"
#import "UIViewController+Factory.h"

@implementation VBViewController

-(VBRootController *)rootController
{
    return (VBRootController *)self.parentViewController;
}

-(void)onRootMadeActive
{
    // implement in parent class
}

-(void)onRootViewDidLoad
{
    // implement in parent class
}

@end
