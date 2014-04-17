//
//  VBNibView.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/17/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBNibView.h"

@interface VBNibView ()

@property (nonatomic, weak) UIView *nib;

@end

@implementation VBNibView

+(instancetype)viewWithFrame:(CGRect)frame
{
    VBNibView *owner = [[self alloc] initWithFrame:frame];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:[NSBundle mainBundle]];
    NSArray *subviews = [nib instantiateWithOwner:owner options:nil];
    for (UIView *subview in subviews) {
        subview.frame = frame;
        [owner addSubview:subview];
    }
    return owner;
}

@end
