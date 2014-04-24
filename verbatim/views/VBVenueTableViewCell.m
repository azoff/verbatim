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
#import "VBPubSub.h"

@interface VBVenueTableViewCell ()

@property (weak, nonatomic) IBOutlet VBLabel *nameLabel;
@property (weak, nonatomic) IBOutlet VBLabel *addressLabel;
@property (weak, nonatomic) IBOutlet VBLabel *userCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sourceImage;
@property (nonatomic) NSMutableSet *userObjectIds;
@property (nonatomic) FirebaseHandle onAdded;
@property (nonatomic) FirebaseHandle onRemoved;

@end

@implementation VBVenueTableViewCell

-(void)setVenue:(VBVenue *)venue
{
    
    if (self.venue) {
        [VBPubSub unsubscribeFromVenue:self.venue handle:self.onAdded];
        [VBPubSub unsubscribeFromVenue:self.venue handle:self.onRemoved];
    }
    
    _venue = venue;
    self.nameLabel.text = venue.name;
    self.addressLabel.text = venue.address;
    
    [self.userObjectIds removeAllObjects];
    self.onAdded = [VBPubSub subscribeToVenueUserAdditions:venue success:^(id objectId) {
        [self didAddUserObjectId:objectId];
    } failure:^(NSError *error) {
        [self didReceiveError:error];
    }];
    
    self.onRemoved = [VBPubSub subscribeToVenueUserDeletions:venue success:^(id objectId) {
        [self didRemoveUserObjectId:objectId];
    } failure:^(NSError *error) {
        [self didReceiveError:error];
    }];
    
    [self updateStyleForState];
    [self updateUserCount];
}

- (void)updateUserCount
{
    self.userCountLabel.text = [[NSNumber numberWithInteger:self.userObjectIds.count] stringValue];
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
    VBUser *current = [VBUser currentUser];
    BOOL selected = current != nil && [self.venue isEqualObject:current.venue];
    id color = selected ? [VBColor activeColor] : [VBColor translucsentTextColor];
    id image = selected ? @"checkmark" : @"person";
    self.nameLabel.textColor =
    self.addressLabel.textColor =
    self.userCountLabel.textColor = color;
    self.sourceImage.image = [[UIImage imageNamed:image] imageByApplyingOverlayColor:color];
}

- (void)awakeFromNib
{
    self.userObjectIds = [NSMutableSet set];
    id color = [VBColor translucsentTextColor];
    self.sourceImage.image = [self.sourceImage.image
                              imageByApplyingOverlayColor:color];
}

@end
