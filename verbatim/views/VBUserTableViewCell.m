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
#import "VBPubSub.h"

@interface VBUserTableViewCell ()

@property (weak, nonatomic) IBOutlet VBLabel *nameLabel;
@property (weak, nonatomic) IBOutlet VBLabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImageView;
@property (strong,nonatomic) UIImage *image;

@property FirebaseHandle userImageHandle;

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
    
    // subscribe to any new images for that user that come in.
   // [VBPubSub unsubscribeFromHandle:self.userImageHandle];
   
    self.userImageHandle = [VBPubSub subscribeToUserImageData:user success:^(NSData *imageData) {
        NSLog(@"Got new image data");
        self.sourceImageView.image = [[UIImage alloc] initWithData:imageData];
        
    } failure:^(NSError *error) {
        [VBHUD showWithError:error];
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
