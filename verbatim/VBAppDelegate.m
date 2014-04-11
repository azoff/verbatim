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
#import "VBInputSourceManager.h"
#import "VBPubSub.h"
#import "VBWelcomeController.h"

@implementation VBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [VBFoursquare setup];
    [VBParse setupWithLaunchOptions:launchOptions];
    [[VBInputSourceManager manager] startListening];
    self.window = [VBWindow window];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    
    VBWelcomeController *splashScreenWelcome = [[VBWelcomeController alloc]init];
    splashScreenWelcome.transitioningDelegate = splashScreenWelcome;
    [self.window.rootViewController presentViewController:splashScreenWelcome animated:YES completion:nil];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
                                       sourceApplication:(NSString *)sourceApplication
                                              annotation:(id)annotation {
    return [VBFoursquare handleURL:url];
}

@end
