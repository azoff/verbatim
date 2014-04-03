//
//  VBAppDelegate.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBAppDelegate.h"
#import "VBCaptionController.h"
#import "VBParse.h"
#import "VBWindow.h"

@implementation VBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [VBParse setupWithLaunchOptions:launchOptions];
    self.window = [VBWindow window];
    return YES;
}

@end
