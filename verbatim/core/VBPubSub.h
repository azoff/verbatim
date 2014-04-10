//
//  VBPubSub.h
//  verbatim
//
//  Created by Nicolas Halper on 4/9/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

/*
 This is not a fully fledged pubsub client. 
 NOTE:
 - You can only subscribe to one channel. If you subscribe to a new channel, it will no longer listen on any other previously subscribed to channels
 - It implements polling, so is not real-time.
 */

#import <Foundation/Foundation.h>

@interface VBPubSub : NSObject

@property (nonatomic,retain) NSString *name;

-(void)subscribeOnlyToChannel:(NSString *)channel usingBlock:(void(^)(NSDictionary *))callback;
-(void)unsubscribeFromAllChannels;
-(void)publishToChannel:(NSString *)channel Data:(NSDictionary *)data;

@end
