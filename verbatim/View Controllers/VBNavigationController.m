//
//  VBNavigationController.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/16/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBNavigationController.h"
#import "VBWelcomeController.h"

@implementation VBNavigationController

-(id)init
{
    self = [super init];
    return self;
}

-(void)setTransition:(CATransition *)transition
{
    [self.view.layer addAnimation:transition forKey:kCATransition];
}

-(CATransition *)transition
{
    return (CATransition *)[self.view.layer animationForKey:kCATransition];
}

-(void)navigationBarShowBackground:(BOOL)visible
{
    if (visible) {
        self.navigationBar.backgroundColor = [VBColor navigationBarColor];
    } else {
        self.navigationBar.backgroundColor = [UIColor clearColor];
    }
}

-(void)navigationBarSetup
{
    // transparent navigation bar
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    [self navigationBarShowBackground:NO];
    
    // transparent navigation controller background
    self.view.backgroundColor = [UIColor clearColor];
}

-(void)setRootViewController:(UIViewController*)controller animated:(BOOL)animated
{
    [self setViewControllers:@[controller] animated:animated];
}

-(void)viewDidLoad
{
    [self navigationBarSetup];
    [self pushViewController:[VBWelcomeController controller] animated:NO];
}

@end
