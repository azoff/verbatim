//
//  VBBarButton.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/17/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBBarButtonItem.h"
#import "UIImage+Overlay.h"

@implementation VBBarButtonItem

+(instancetype)micButtonWithTarget:(id)target action:(SEL)action {
    return [self buttonWithImageNamed:@"mic" target:target action:action];
}

+(instancetype)locationButtonWithTarget:(id)target action:(SEL)action {
    return [self buttonWithImageNamed:@"location" target:target action:action];
}

+(instancetype)captionButtonWithTarget:(id)target action:(SEL)action {
    return [self buttonWithImageNamed:@"caption" target:target action:action];
}

+(instancetype)buttonWithImageNamed:(NSString *)name target:(id)target action:(SEL)action
{
    id image = [UIImage imageNamed:name];
    id color = [VBColor translucsentTextColor];
    image = [image imageByApplyingOverlayColor:color];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 24, 24);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[self alloc] initWithCustomView:button];
}

@end
