//
//  VBTranslationTitleView.m
//  verbatim
//
//  Created by Chris Ahlering on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBTranslationTitleView.h"

@implementation VBTranslationTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)onLanguageChange:(UISegmentedControl *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(stateDidChange)]) {
        [_delegate stateDidChange];
    }
}

@end
