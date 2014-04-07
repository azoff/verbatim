//
//  VBCaptionScreen.h
//  verbatim
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>

enum VBCaptionControllerPresentationModeType {
    PM_CAPTION_FULLTEXT,
    PM_CAPTION_CAMERA
};
typedef enum VBCaptionControllerPresentationModeType VBCaptionControllerPresentationModeType;

@interface VBCaptionController : UIViewController

+ (instancetype)controller;

@property (strong,nonatomic) NSString *caption;
@property (assign,nonatomic) VBCaptionControllerPresentationModeType presentationMode;


@end
