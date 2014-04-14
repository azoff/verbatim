//
//  VBCheckinTitleView.m
//  verbatim
//
//  Created by Chris Ahlering on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCheckinTitleView.h"

@implementation VBCheckinTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (IBAction)onCheckinTap:(UITapGestureRecognizer *)sender {
    if (_delegate) [_delegate stateDidChange];
}

@end
