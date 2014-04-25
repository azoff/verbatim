//
//  VBImage.m
//  verbatim
//
//  Created by Nicolas Halper on 4/25/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBImage.h"

@implementation VBImage

+(UIImage*)imageFromColor:(UIColor *)color
{
    // Create a 1 by 1 pixel context and fill with color
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+(UIImage*)randomColorImage
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return [VBImage imageFromColor:color];
}


@end
