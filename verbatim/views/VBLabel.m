//
//  VBLabel.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/18/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBLabel.h"
#import "VBFont.h"

@implementation VBLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    self.font = [VBFont defaultFontWithSize:self.font.pointSize];
    self.textColor = [VBColor translucsentTextColor];
}

@end
