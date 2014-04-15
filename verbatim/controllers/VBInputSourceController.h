//
//  VBInputSourceController.h
//  verbatim
//
//  Created by Nicolas Halper on 4/15/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBInputSourceController : UIViewController

// any time the input source controller selects a user as an input source
// it will NSNotification with userInfo as @{@"user":VBUser}
extern NSString *const VBInputSourceControllerChangedSourceUserNotification;

@end
