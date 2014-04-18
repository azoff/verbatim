//
//  UIViewController+Factory.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/16/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "UIViewController+Factory.h"

@implementation UIViewController (Factory)

+(instancetype)controller
{
    return [[self alloc] init];
}

@end
