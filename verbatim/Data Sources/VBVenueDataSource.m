//
//  VBVenueDataSource.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/19/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBVenueDataSource.h"

@interface VBVenueDataSource()

@property (nonatomic) NSArray *venues;

@end

@implementation VBVenueDataSource

-(id)init
{
    self.venues = @[];
    return self;
}

-(instancetype)initWithCellReuseIdentifier:(NSString *)identifier
{
    self = [self init];
    if (self) {
        self.cellReuseIdentifier = identifier;
    }
    return self;
}

-(void)reloadWithError:(void(^)(NSError*))done
{
    [VBFoursquare venuesNearbyWithSuccess:^(NSArray *venues) {
        self.venues = venues;
        done(nil);
    } andFailure:^(NSError *error) {
        done(error);
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell  = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier];
    id venue = [self.venues objectAtIndex:indexPath.row];
    [cell setVenue:venue];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

+(instancetype)sourceWithCellReuseIdentifier:(NSString *)identifier
{
    return [[self alloc] initWithCellReuseIdentifier:identifier];
}

@end
