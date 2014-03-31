//
//  VBCaptionScreen.h
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBSpeechKit.h"

@interface VBCaptionController : UIViewController<SpeechKitDelegate>

+ (instancetype)controller;

@end
