//
//  VBUserTableViewCell.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/21/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBLabel.h"
#import "UIImage+Overlay.h"
#import "VBUserTableViewCell.h"

@interface VBUserTableViewCell ()

@property (weak, nonatomic) IBOutlet VBLabel *nameLabel;
@property (weak, nonatomic) IBOutlet VBLabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImageView;

@end

@implementation VBUserTableViewCell

-(void)setUser:(VBUser *)user
{
    _user = user;
    self.nameLabel.text = user.label;
    self.countLabel.text = @"-";
    [user listenerCountWithSuccess:^(int count) {
        self.countLabel.text = [[NSNumber numberWithInt:count] stringValue];
    } andFailure:^(NSError *error) {
        self.countLabel.text = @"0";
        NSLog(@"[ERROR] Unable to get listener count, displaying 0. Reason: %@", error);
    }];
    [self updateStyleForState];
}

- (void)updateStyleForState
{
    VBUser *source = [[VBUser currentUser] source];
    BOOL active = [self.user isEqualObject:source];
    
    id color = active ? [VBColor activeColor] : [VBColor translucsentTextColor];
    id image = active ? @"mic" : (self.user.canonical ? @"podium" : @"person");
    self.nameLabel.textColor =
    self.countLabel.textColor = color;
    self.sourceImageView.image = [[UIImage imageNamed:image] imageByApplyingOverlayColor:color];
}

@end
