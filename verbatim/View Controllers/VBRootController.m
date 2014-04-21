//
//  VBNavigationController.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/19/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBRootController.h"
#import "VBWelcomeController.h"
#import "VBCaptionController.h"
#import "VBCheckinController.h"
#import "VBInputSourceController.h"
#import "VBButton.h"

@interface VBRootController ()

@property (weak, nonatomic) IBOutlet VBButton *micButton;
@property (weak, nonatomic) IBOutlet VBButton *locationButton;
@property (weak, nonatomic) IBOutlet VBButton *captionButton;
@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (nonatomic) UIViewController *controller;
@property (nonatomic) Class lastViewControllerClass;

- (IBAction)onButtonTap:(id)sender;

@end

@implementation VBRootController


- (void)setNavBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    self.navBar.hidden = hidden;
    //TODO: animation
}

- (void)renderNavBarWithClass:(Class)class
{

    id on  = [VBColor activeColor];
    id off = [VBColor translucsentTextColor];
    
    [self setNavBarHidden:(class == VBWelcomeController.class) animated:YES];
    
    self.micButton.overlayColor = class == VBInputSourceController.class ? on : off;
    self.locationButton.overlayColor = class == VBCheckinController.class ? on : off;
    self.captionButton.overlayColor = class == VBCaptionController.class ? on : off;
}

- (void)startAddingViewController:(UIViewController *)controller
{
    if (self.controller)
        [self.controller willMoveToParentViewController:nil];
    [self addChildViewController:controller];
    controller.view.frame = self.container.bounds;
}

- (void)finishAddingViewController:(UIViewController *)controller
{
    if (self.controller) {
        [self.controller didMoveToParentViewController:nil];
        if (self.controller.class != self.lastViewControllerClass) {
            self.lastViewControllerClass = self.controller.class;
        }
    }
    [controller didMoveToParentViewController:self];
    self.controller = controller;
}

- (void)renderContainerWithClass:(Class)class
{
    UIViewController *controller = [class controller];
    [self startAddingViewController:controller];
    
    if (!self.controller) {
        [self.container addSubview:controller.view];
        [self finishAddingViewController:controller];
        return;
    }
    
    controller.view.alpha = 0;
    [self transitionFromViewController:self.controller
                      toViewController:controller
                              duration:0.3
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                self.controller.view.alpha = 0.0;
                                controller.view.alpha = 1.0;
                            }
                            completion:^(BOOL finished) {
                                [self finishAddingViewController:controller];
                            }];
    
}

- (void)renderViewControllerWithClass:(Class)class
{
    [self renderNavBarWithClass:class];
    [self renderContainerWithClass:class];
}

- (void)renderLastViewController
{
    [self renderViewControllerWithClass:self.lastViewControllerClass];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self renderViewControllerWithClass:VBWelcomeController.class];
}

- (IBAction)onButtonTap:(id)sender {
    id targetClass;
    if ([[sender overlayColor] isEqual:[VBColor activeColor]])
        return; // exit early if already active
    if (sender == self.micButton)
        targetClass = VBInputSourceController.class;
    else if (sender == self.captionButton)
        targetClass = VBCaptionController.class;
    else if (sender == self.locationButton)
        targetClass = VBCheckinController.class;
    else
        [NSException raise:@"Unimplemented Sender" format:@"Unable to find target for sender %@", sender];
    [self renderViewControllerWithClass:targetClass];
}

@end
