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

// showWithText and convenience functions
+(void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
+(void)showWithText:(NSString *)text;

+(void)showWithError:(NSError*)error;

+(void)hide;

// left from Azoff's initial implementation
+(NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;

@end
