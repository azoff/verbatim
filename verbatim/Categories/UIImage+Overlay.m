//
//  UIImage+Overlay.m
//  verbatim
//
//  Created by Chris Ahlering on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "UIImage+Overlay.h"

@implementation UIImage (Overlay)

- (UIImage *)imageByApplyingOverlayColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
