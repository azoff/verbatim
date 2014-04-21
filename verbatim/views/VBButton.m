//
//  VBBarButton.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/17/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBButton.h"
#import "UIImage+Overlay.h"

@interface VBButton ()

@property (nonatomic) UIImage *originalBackgroundImage;

@end

@implementation VBButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.originalBackgroundImage = [self backgroundImageForState:UIControlStateNormal];
    self.overlayColor = [VBColor translucsentTextColor];
    [self setAdjustsImageWhenHighlighted:NO];
}

-(void)setOverlayColor:(UIColor *)overlayColor
{
    if ([overlayColor isEqual:_overlayColor]) return;
    id image = [self.originalBackgroundImage imageByApplyingOverlayColor:(_overlayColor = overlayColor)];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

@end
