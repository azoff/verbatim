//
//  VBVenueDelegate.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/20/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBVenueDelegate.h"

@interface VBVenueDelegate ()

@property (nonatomic) CGFloat rowHeight;

@end

@implementation VBVenueDelegate

+(instancetype)delegateWithSubDelegate:(id<VBVenueSubDelegate>)subDelegate
{
    return [[self alloc] initWithSubDelegate:subDelegate];
}

-(instancetype)initWithSubDelegate:(id<VBVenueSubDelegate>)subDelegate
{
    if (self = [super init]) {
        self.subDelegate = subDelegate;
        [self calculateRowHeight];
    }
    return self;
}

-(void)calculateRowHeight
{
    UIView *cell = [self.subDelegate cellForHeightMeasurement];
    self.rowHeight = cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.subDelegate respondsToSelector:@selector(didSelectVenue:)])
        return;
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    id venue = [cell venue];
    [self.subDelegate didSelectVenue:venue];
}

@end
