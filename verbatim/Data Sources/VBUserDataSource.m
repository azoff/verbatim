//
//  VBUserDataSource.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/21/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUserDataSource.h"
#import "VBPubSub.h"

typedef void(^VBUserDataSourceHandle)(NSError*);

@interface VBUserDataSource()

@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSMutableArray *objectIds;
@property (nonatomic) FirebaseHandle onRemoval;
@property (nonatomic) FirebaseHandle onAddition;
@property (nonatomic, strong) VBUserDataSourceHandle onUpdate;

@end

@implementation VBUserDataSource

-(id)init
{
    self.objectIds = [NSMutableArray array];
    self.users = [NSMutableDictionary dictionary];
    self.onUpdate = nil;
    return self;
}

-(instancetype)initWithCellReuseIdentifier:(NSString *)identifier andVenue:(VBVenue *)venue
{
    self = [self init];
    if (self) {
        self.cellReuseIdentifier = identifier;
        self.venue = venue;
    }
    return self;
}

- (void)addUser:(VBUser*)user withId:(NSString *)objectId
{
    [self.users setValue:user forKey:objectId];
    [self.objectIds addObject:objectId];
    if (self.onUpdate) self.onUpdate(nil);
}

- (void)removeUserById:(NSString*)objectId
{
    [self.users removeObjectForKey:objectId];
    [self.objectIds removeObject:objectId];
    if (self.onUpdate) self.onUpdate(nil);
}

- (void)removeAllUsers
{
    [self.users removeAllObjects];
    [self.objectIds removeAllObjects];
    if (self.onUpdate) self.onUpdate(nil);
}

- (VBUser *)userById:(NSString*)objectId
{
    return [self.users valueForKey:objectId];
}

- (VBUser *)userByIndex:(NSUInteger)objectIndex
{
    return [self userById:self.objectIds[objectIndex]];
}

-(void)setVenue:(VBVenue *)venue
{
    if (self.venue) {
        [VBPubSub unsubscribeFromVenue:self.venue handle:self.onAddition];
        [VBPubSub unsubscribeFromVenue:self.venue handle:self.onRemoval];
    }
    
    _venue = venue;
    
    [self removeAllUsers];
    VBUser *user = [VBUser currentUser];
    if (user) [self addUser:user withId:user.objectId];
    
    if (!self.venue) return;
    
    self.onAddition = [VBPubSub subscribeToVenueUserAdditions:venue success:^(id objectId) {
        [self didAddUserObjectId:objectId];
    } failure:^(NSError *error) {
        [self didReceiveError:error];
    }];
    
    self.onRemoval = [VBPubSub subscribeToVenueUserDeletions:venue success:^(id objectId) {
        [self didRemoveUserObjectId:objectId];
    } failure:^(NSError *error) {
        [self didReceiveError:error];
    }];
    
}

- (void)didReceiveError:(NSError *)error
{
    if (self.onUpdate) self.onUpdate(error);
}

- (void)didAddUserObjectId:(NSString *)objectId
{
    if ([self userById:objectId])
        return;
    [VBUser objectCachedInBackgroundWithId:objectId success:^(VBUser* user) {
        if (user && ![self userById:objectId])
            [self addUser:user withId:objectId];
    } failure:^(NSError *error) {
        [self didReceiveError:error];
    }];
}

- (void)didRemoveUserObjectId:(NSString *)objectId
{
    if (![self userById:objectId]) return;
    [self removeUserById:objectId];
}

-(void)observeUpdateWithBlock:(VBUserDataSourceHandle)onUpdate
{
    self.onUpdate = onUpdate;
    onUpdate(nil);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objectIds.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell  = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier];
    id user = [self userByIndex:indexPath.row];
    [cell setUser:user];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

+(instancetype)sourceWithCellReuseIdentifier:(NSString *)identifier andVenue:(VBVenue *)venue
{
    return [[self alloc] initWithCellReuseIdentifier:identifier andVenue:venue];
}

@end
