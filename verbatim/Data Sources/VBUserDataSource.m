//
//  VBUserDataSource.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/21/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUserDataSource.h"

@interface VBUserDataSource()

@property (nonatomic) NSArray *users;

@end

@implementation VBUserDataSource

-(id)init
{
    self.users = @[];
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

-(void)reloadWithError:(void(^)(NSError*))done
{
    if (self.venue) {
        [self.venue checkedInUsersWithSuccess:^(NSArray *users) {
            self.users = users;
            done(nil);
        } andFailure:^(NSError *error) {
            done(error);
        }];
    } else {
        // if no venue, populate with current user
        self.users = @[[VBUser currentUser]];
        done(nil);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell  = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier];
    id user = [self.users objectAtIndex:indexPath.row];
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
