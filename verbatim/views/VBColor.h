//
//  VBColor.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBColor : UIColor

+(UIColor*)backgroundColor;
+(UIColor*)translucsentTextColor;
+(UIColor*)opaqueTextColor;
+(UIColor*)activeColor;
+(UIColor*)selectedColor;

@end


//Adding UIImage category here since we use it to color images
@interface UIImage(Overlay)
- (UIImage *)imageWithColor:(UIColor *)color1;
@end

