//
//  SpeechKitUtil.m
//  verbatim
//
//  Created by Jonathan Azoff on 3/31/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBSpeechKit.h"

unsigned char const SpeechKitApplicationKey[] = {0x9c, 0xf3, 0x69, 0xec, 0xfa, 0x58, 0xbe, 0xd5, 0x8d, 0xfd, 0x1e, 0xba, 0xee, 0x97, 0xb1, 0x70, 0x55, 0x18, 0xbb, 0x93, 0xc4, 0x3e, 0x04, 0x4b, 0x4f, 0x9a, 0x8b, 0x04, 0xdd, 0x74, 0xb4, 0x79, 0x67, 0x1d, 0x65, 0x61, 0x76, 0x24, 0x36, 0x03, 0x21, 0x55, 0xbe, 0x0f, 0xec, 0x6f, 0x7f, 0x41, 0x87, 0x3a, 0xd4, 0x4b, 0x79, 0xd8, 0x97, 0xc8, 0x72, 0x22, 0xcc, 0x50, 0x96, 0x80, 0xc9, 0xfe};

NSString *   const SPEECHKIT_APP_ID = @"NMDPTRIAL_drnick2320140331164050";
NSString *   const SPEECHKIT_HOST   = @"sandbox.nmdp.nuancemobility.net";
unsigned int const SPEECHKIT_PORT   = 443;
BOOL         const SPEECHKIT_SSL    = NO;

@implementation VBSpeechKit

+(void)setupWithDelegate:(id<SpeechKitDelegate>)delegate
{
    static dispatch_once_t setupOnce;
    dispatch_once(&setupOnce, ^{
        [SpeechKit setupWithID:SPEECHKIT_APP_ID
                          host:SPEECHKIT_HOST
                          port:SPEECHKIT_PORT
                        useSSL:SPEECHKIT_SSL
                      delegate:delegate];
    });
}

@end