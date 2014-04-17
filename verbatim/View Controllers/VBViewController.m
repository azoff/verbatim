//
//  VBViewController.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/16/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBViewController.h"

@implementation VBViewController

-(VBNavigationController*)vbNavigationController
{
    return (VBNavigationController*)[super navigationController];
}

-(void)setupNavigationBar
{
    [self.vbNavigationController navigationBarShowBackground:NO];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

@end
