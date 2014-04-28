//
//  VBCaptionDataSource.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/28/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCaptionDataSource.h"
#import "VBInputSourceManager.h"

@interface VBCaptionDataSource()

@property (nonatomic, strong) NSMutableArray *captions;
@property (nonatomic, strong) void(^onUpdate)(void);

@end

@implementation VBCaptionDataSource

-(id)init
{
    self.captions = [NSMutableArray array];
    self.onUpdate = nil;
    
    // append captions on input source manager updates
    id center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:VBInputSourceManagerEventCaptionReceived
                        object:nil queue:nil usingBlock:^(NSNotification *notification) {
                            [self appendCaption:notification.userInfo[@"caption"]];
                        }];
    
    // clear out captions on caption source changes
    [center addObserverForName:VBUserEventSourceChanged
                        object:nil queue:nil usingBlock:^(NSNotification *notification) {
                            [self clearCaptions];
                        }];
    return self;
}

-(instancetype)initWithCellReuseIdentifier:(NSString *)identifier
{
    self = [self init];
    if (self)
        self.cellReuseIdentifier = identifier;
    return self;
}

- (void)appendCaption:(NSString*)caption
{
    [self.captions addObject:caption];
    if (self.onUpdate) self.onUpdate();
}

- (void)clearCaptions
{
    [self.captions removeAllObjects];
    if (self.onUpdate) self.onUpdate();
}

-(void)observeUpdateWithBlock:(void(^)(void))onUpdate
{
    self.onUpdate = onUpdate;
    onUpdate();
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.captions.count;
}

-(NSString *)captionForIndexPath:(NSIndexPath *)indexPath
{
    return self.captions[indexPath.row];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell  = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier];
    [cell setCaption:[self captionForIndexPath:indexPath]];
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
