//
//  VBHUD.h
//  verbatim
//
//  Created by Nicolas Halper on 4/12/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBHUD : NSObject

+ (instancetype)instance;

+ (void)showIndeterminateProgress;
+ (void)showIndeterminateProgressWithText:(NSString *)text;

+ (void)showDoneWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;

// showWithText and convenience functions
+(void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
+(void)showWithText:(NSString *)text;

+(void)showWithError:(NSError*)error;

+(void)hide;

@end
