//
//  VBPubSub.m
//  verbatim
//
//  Created by Nicolas Halper on 4/9/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBPubSub.h"

// how soon we poll the Parse server after we just got their data
NSTimeInterval const POLL_AGAIN_INTERVAL = 1.0;

@interface VBPubSub()

@property (copy) void (^callback)(NSDictionary *);

@property (nonatomic,strong) NSString *subscribedChannel;
@property (nonatomic,strong) NSDate *polledAt;

-(void)pollForNewData;

@end

@implementation VBPubSub

-(void)subscribeOnlyToChannel:(NSString *)channel usingBlock:(void (^)(NSDictionary *))callback {
    NSLog(@"subscribing to channel %@",channel);
    self.subscribedChannel = channel;
    self.polledAt = [NSDate date];
    self.callback = callback;
    [self pollForNewData];
}

-(void)unsubscribeFromAllChannels {
    self.subscribedChannel = nil;
}

-(void)pollForNewData {

    if (!self.subscribedChannel) {
        return;
    }
    
    NSLog(@"Polling data");
    PFQuery *query = [PFQuery queryWithClassName:@"PubSub"];
    [query whereKey:@"channel" equalTo:self.subscribedChannel];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"createdAt" greaterThan:self.polledAt];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count >0) {
                // The find succeeded with new objects since our last poll.
                PFObject *mostRecentObject = objects[0];
                
                // updated our last successful poll time to the most recently created object in the list
                self.polledAt = mostRecentObject.createdAt;
                
                for (PFObject *object in objects) {
                    //NSLog(@"%@ %@", object.createdAt, object[@"data"]);
                    self.callback(object[@"data"]);
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"ERROR VBPubSub:pollForNewData: %@ %@", error, [error userInfo]);
        }
        [self performSelector:@selector(pollForNewData) withObject:nil afterDelay:POLL_AGAIN_INTERVAL];
    }];
    
}


-(void)publishToChannel:(NSString *)channel Data:(NSDictionary *)data {
    NSLog(@"publish to channel %@:%@",channel,data);
    
    NSDictionary *channelEntry = @{@"channel":channel,@"data":data};
    
    PFObject *channelData = [PFObject objectWithClassName:@"PubSub" dictionary:channelEntry];
    [channelData saveInBackground];
}

@end
