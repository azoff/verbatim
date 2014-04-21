//
//  VBNavigationController.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/19/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>

enum VBAppState {
    APP_STATE_WELCOME,
    APP_STATE_CAPTION,
    APP_STATE_CHECKIN,
    APP_STATE_INPUTSOURCE
};

typedef enum VBAppState VBAppState;


@interface VBRootController : UIViewController

- (void)switchToAppState:(VBAppState)appState animate:(BOOL)animate;
- (void)switchToAppState:(VBAppState)appState removeWelcomeSplash:(BOOL)remove animate:(BOOL)animate;

@end
