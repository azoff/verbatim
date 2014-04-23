//
//  SpeechKitUtil.h
//  verbatim
//
//  Created by Jonathan Azoff on 3/31/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpeechKit/SpeechKit.h>

typedef void(^VBSpeechKitResultBlock)(SKRecognition *);

@interface VBSpeechKit : NSObject

+(instancetype)kit;
-(void)startListeningWithBlock:(VBSpeechKitResultBlock)block;
-(void)stopListening;

@end
