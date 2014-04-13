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
    return [super colorWithRed:255 green:255 blue:255 alpha:0.8];
}

+(UIColor*)opaqueTextColor
{
    return [super colorWithRed:255 green:255 blue:255 alpha:1];
}

+(UIColor*)activeColor
{
    return [super colorWithRed:134 green:195 blue:81 alpha:1];
}

+(UIColor*)selectedColor
{
    return [super colorWithRed:0 green:255 blue:0 alpha:1];
}

@end
