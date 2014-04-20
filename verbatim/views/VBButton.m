//
//  VBBarButton.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/17/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBButton.h"
#import "UIImage+Overlay.h"

@implementation VBButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.overlayColor = [VBColor translucsentTextColor];
}

-(void)setOverlayColor:(UIColor *)overlayColor
{
    if ([overlayColor isEqual:_overlayColor]) return;
    id image = [self backgroundImageForState:UIControlStateNormal];
    image = [image imageByApplyingOverlayColor:(_overlayColor = overlayColor)];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

@end
