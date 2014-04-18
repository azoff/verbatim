//
//  VBColor.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBColor.h"

@implementation VBColor

+(UIColor*)backgroundColor
{
    return [super blackColor];
}

+(UIColor*)translucsentTextColor
{
    return [super colorWithRed:1 green:1 blue:1 alpha:0.8];
}

+(UIColor*)opaqueTextColor
{
    return [super colorWithRed:1 green:1 blue:1 alpha:1];
}

+(UIColor*)activeColor
{
    return [super colorWithRed:0.525490196 green:0.764705882 blue:.317647059 alpha:1];
}

+(UIColor *)navigationBarColor
{
    return [super colorWithRed:0 green:0 blue:0 alpha:0.7];
}

@end
