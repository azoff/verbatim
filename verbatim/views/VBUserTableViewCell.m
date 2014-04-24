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

@interface VBUserTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet VBLabel *nameLabel;
@property (weak, nonatomic) IBOutlet VBLabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImageView;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong,nonatomic) UIImage *image;
@property (nonatomic) NSMutableSet *userObjectIds;
@property (nonatomic) FirebaseHandle onAdded;
@property (nonatomic) FirebaseHandle onRemoved;
@property (nonatomic) FirebaseHandle onImage;

@end

@implementation VBUserTableViewCell

-(void)setUser:(VBUser *)user
{
    
    if (self.user) {
        [VBPubSub unsubscribeFromUser:self.user handle:self.onAdded];
        [VBPubSub unsubscribeFromUser:self.user handle:self.onRemoved];
        [VBPubSub unsubscribeFromUserImage:self.user handle:self.onImage];
    }
    
    _user = user;
    self.nameLabel.text = user.label;
    [self.userObjectIds removeAllObjects];
    self.onAdded = [VBPubSub subscribeToListenerAdditions:user success:^(id objectId) {
        [self didAddUserObjectId:objectId];
    } failure:^(NSError *error) {
        [self didReceiveError:error];
    }];
    
    self.onRemoved = [VBPubSub subscribeToListenerDeletions:user success:^(id objectId) {
        [self didRemoveUserObjectId:objectId];
    } failure:^(NSError *error) {
        [self didReceiveError:error];
    }];
    
    self.onImage = [VBPubSub subscribeToUserImageData:user success:^(NSData *imageData) {
        self.cameraImageView.image = [[UIImage alloc] initWithData:imageData];
    } failure:^(NSError *error) {
        [VBHUD showWithError:error];
    }];

    [self updateStyleForState];
    [self updateUserCount];
}

- (void)updateUserCount
{
    VBUser *source = [[VBUser currentUser] source];
    BOOL active = [self.user isEqualObject:source];
    NSUInteger count = self.userObjectIds.count;
    count = count == 0 && active ? 1 : count;
    self.countLabel.text = [[NSNumber numberWithInteger:count] stringValue];
}

- (void)didAddUserObjectId:(NSString *)objectId
{
    [self.userObjectIds addObject:objectId];
    [self updateUserCount];
}

- (void)didRemoveUserObjectId:(NSString *)objectId
{
    [self.userObjectIds removeObject:objectId];
    [self updateUserCount];
    
}

- (void)didReceiveError:(NSError *)error
{
    [VBHUD showWithError:error];
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

- (void)awakeFromNib
{
    self.userObjectIds = [NSMutableSet set];
}

@end
