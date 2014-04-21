//
//  VBTableViewCell.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/21/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBTableViewCell.h"

@implementation VBTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    void(^update)(void) = ^{
        self.contentView.backgroundColor = selected ? [VBColor activeColor] : [VBColor backgroundColor];
    };
    if (animated) {
        [UIView animateWithDuration:0.3 animations:update];
    } else {
        update();
    }
}

+(UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:NSBundle.mainBundle];
}

@end
