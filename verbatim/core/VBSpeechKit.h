//
//  SpeechKitUtil.h
//  verbatim
//
//  Created by Jonathan Azoff on 3/31/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpeechKit/SpeechKit.h>

@interface VBSpeechKit : NSObject

+(void)setupWithDelegate:(id<SpeechKitDelegate>)delegate;

@end
