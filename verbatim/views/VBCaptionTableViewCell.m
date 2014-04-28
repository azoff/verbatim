//
//  VBCaptionTableViewCell.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/28/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionTableViewCell.h"
#import "VBLabel.h"

@interface VBCaptionTableViewCell ()

@property (weak, nonatomic) IBOutlet VBLabel *captionLabel;

@end

@implementation VBCaptionTableViewCell

-(void)setCaption:(NSString *)caption
{
    self.captionLabel.text = _caption = caption;
}

@end
