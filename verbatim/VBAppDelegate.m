//
//  VBAppDelegate.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBAppDelegate.h"
#import "VBCaptionController.h"
#import "VBWindow.h"
#import "VBPubSub.h"

@implementation VBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [VBFoursquare setup];
//  [VBFoursquare deauthorize]; // uncomment to test auth workflow
    [VBParse setupWithLaunchOptions:launchOptions];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window = [VBWindow window];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
                                       sourceApplication:(NSString *)sourceApplication
                                              annotation:(id)annotation {
    return [VBFoursquare handleURL:url];
}

@end
