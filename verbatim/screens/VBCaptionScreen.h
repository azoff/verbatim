//
//  VBCaptionScreen.h
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/PocketsphinxController.h>
#import <RapidEarsDemo/PocketsphinxController+RapidEars.h>
#import <RapidEarsDemo/OpenEarsEventsObserver+RapidEars.h>

@interface VBCaptionScreen : UIViewController<OpenEarsEventsObserverDelegate>

+ (instancetype)screen;

@end
