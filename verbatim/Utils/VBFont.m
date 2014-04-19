//
//  VBFont.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/18/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBFont.h"

NSString * const DEFAULT_FONT_FAMILY_NAME = @"NanumGothic";

@implementation VBFont

+(UIFont *)defaultFontWithSize:(CGFloat)size
{
    UIFont *defaultFont = [UIFont fontWithName:DEFAULT_FONT_FAMILY_NAME size:size];
    if (defaultFont == nil) {
        defaultFont = [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:size];
    }
    return defaultFont;
}

@end
