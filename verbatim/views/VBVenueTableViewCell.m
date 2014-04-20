//
//  VBVenueTableViewCell.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/19/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBVenueTableViewCell.h"
#import "VBLabel.h"
#import "UIImage+Overlay.h"

@interface VBVenueTableViewCell ()

@property (weak, nonatomic) IBOutlet VBLabel *nameLabel;
@property (weak, nonatomic) IBOutlet VBLabel *addressLabel;
@property (weak, nonatomic) IBOutlet VBLabel *userCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImage;

@end

@implementation VBVenueTableViewCell

-(void)setVenue:(VBVenue *)venue
{
    _venue = venue;
    self.nameLabel.text = venue.name;
    self.addressLabel.text = venue.address;
    [self.venue checkedInUserCountWithSuccess:^(int count) {
        self.userCountLabel.text = [[NSNumber numberWithInt:count] stringValue];
    } andFailure:^(NSError *error) {
        self.userCountLabel.text = @"0";
        NSLog(@"[ERROR] Unable to get user count, displaying 0. Reason: %@", error);
    }];

}

- (void)awakeFromNib
{
    id color = [VBColor translucsentTextColor];
    self.sourceImage.image = [self.sourceImage.image
                              imageByApplyingOverlayColor:color];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.contentView.backgroundColor = selected ? [VBColor separatorColor] : [VBColor backgroundColor];
}

+(UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass(self.class) bundle:NSBundle.mainBundle];
}

@end
