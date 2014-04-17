//
//  VBBarButton.h
//  verbatim
//
//  Created by Jonathan Azoff on 4/17/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VBBarButtonItem : UIBarButtonItem

+(instancetype)micButtonWithTarget:(id)target action:(SEL)action;
+(instancetype)locationButtonWithTarget:(id)target action:(SEL)action;
+(instancetype)captionButtonWithTarget:(id)target action:(SEL)action;
+(instancetype)buttonWithImageNamed:(NSString *)name target:(id)target action:(SEL)action;

@end
