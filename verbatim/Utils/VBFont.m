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
    id font = [UIFont fontWithName:DEFAULT_FONT_FAMILY_NAME size:size];
    if (font == nil)
        [NSException raise:@"Missing Font"
                    format:@"Unable to find font %@ in bundle resources", DEFAULT_FONT_FAMILY_NAME];
    return font;
}

@end
