//
//  VBWindow.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/3/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBWindow.h"
#import "VBColor.h"
#import "VBCaptionController.h"
#import "VBNavigationController.h"

@implementation VBWindow

- (id)init
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    self = [self initWithFrame:frame];
    if (self) {
        [self makeKeyAndVisible];
        self.backgroundColor = [VBColor backgroundColor];
        self.rootViewController = [VBNavigationController controller];
    }
    return self;
}

+(instancetype)window
{
    static id _window = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{ _window = [[self alloc] init]; });
    return _window;
}

@end
