//
//  VBUserDelegate.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/21/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBUserDelegate.h"

@interface VBUserDelegate ()

@property (nonatomic) CGFloat rowHeight;

@end

@implementation VBUserDelegate

+(instancetype)delegateWithSubDelegate:(id<VBUserSubDelegate>)subDelegate
{
    return [[self alloc] initWithSubDelegate:subDelegate];
}

-(instancetype)initWithSubDelegate:(id<VBUserSubDelegate>)subDelegate
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
    if (![self.subDelegate respondsToSelector:@selector(didSelectUser:)])
        return;
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    id user = [cell user];
    [self.subDelegate didSelectUser:user];
}

@end
