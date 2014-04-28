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

// our navigation/header stuff
@property (weak, nonatomic) IBOutlet VBButton *micButton;
@property (weak, nonatomic) IBOutlet VBButton *locationButton;

// our child view controllers
@property (nonatomic,strong) VBCaptionController *captionController;
@property (nonatomic,strong) VBInputSourceController *inputSourceController;
@property (nonatomic,strong) VBCheckinController *checkinController;
@property (nonatomic,strong) VBWelcomeController *welcomeController;

// views for our child view controllers for transition management
@property (weak, nonatomic) IBOutlet UIView *welcomeContainer;
@property (weak, nonatomic) IBOutlet UIView *captionContainer;
@property (weak, nonatomic) IBOutlet UIView *inputSourceContainer;
@property (weak, nonatomic) IBOutlet UIView *checkinContainer;
@property (weak, nonatomic) IBOutlet UIView *rootContainerView;

- (IBAction)onButtonTap:(id)sender;

// constraints for animations
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationButtonVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *micButtonVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputSourceViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *welcomeViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkinViewLeadingConstraint;

@end

@implementation VBRootController

- (void)animateViewsToAppState
{

    id on  = [VBColor activeColor];
    id off = [VBColor translucsentTextColor];
    id view, controller;

    // nav bar
    self.micButton.overlayColor = (self.appState == APP_STATE_INPUTSOURCE) ? on : off;
    self.locationButton.overlayColor = (self.appState == APP_STATE_CHECKIN) ? on : off;
    
    // header
    if (self.appState == APP_STATE_WELCOME) {
        self.micButton.alpha = self.locationButton.alpha = 0.5;
        self.micButtonVerticalConstraint.constant =
        self.locationButtonVerticalConstraint.constant = -22.0;
    } else {
        self.micButton.alpha = self.locationButton.alpha = 1.0;
        self.micButtonVerticalConstraint.constant =
        self.locationButtonVerticalConstraint.constant = 8.0;
    }
    
    // welcome controller
    if (self.appState == APP_STATE_WELCOME) {
        view = self.welcomeContainer;
        controller = self.welcomeController;
        self.welcomeViewTopConstraint.constant =
        self.welcomeViewBottomConstraint.constant =
        self.welcomeViewLeadingConstraint.constant =
        self.welcomeViewTrailingConstraint.constant = 0.0;
        self.welcomeContainer.alpha     = 1.0;
    } else {
        self.welcomeViewTopConstraint.constant =
        self.welcomeViewBottomConstraint.constant = -self.view.frame.size.height*2;
        self.welcomeViewLeadingConstraint.constant =
        self.welcomeViewTrailingConstraint.constant = -self.view.frame.size.width*2;
        self.welcomeContainer.alpha     = 0.0;
    }
    
    // input source controller
    if (self.appState == APP_STATE_INPUTSOURCE) {
        view = self.inputSourceContainer;
        controller = self.inputSourceController;
        self.inputSourceContainer.alpha = 1.0;
        self.inputSourceViewLeadingConstraint.constant = 0;
    } else {
        self.inputSourceViewLeadingConstraint.constant = self.view.frame.size.width;
        self.inputSourceContainer.alpha = 0.5;
    }
    
    // checkin controller
    if (self.appState == APP_STATE_CHECKIN) {
        view = self.checkinContainer;
        controller = self.checkinController;
        self.checkinViewLeadingConstraint.constant = 0.0;
        self.checkinContainer.alpha = 1.0;
    } else {
        self.checkinViewLeadingConstraint.constant = -self.view.frame.size.width;
        self.checkinContainer.alpha = 0.5;
    }
    
    // caption controller
    CGRect frame = self.rootContainerView.frame;
    if (self.appState == APP_STATE_CAPTION) {
        view = self.captionContainer;
        controller = self.captionController;
        self.captionController.view.frame = frame;
        self.captionContainer.alpha = 1.0;
        self.captionContainer.layer.transform = CATransform3DIdentity;
    } else {
        self.captionController.view.frame = CGRectMake(16, 16, frame.size.width - 32, frame.size.height - 32);
        self.captionContainer.alpha = 0.5;
        self.captionContainer.layer.transform = CATransform3DIdentity;
        if (self.appState == APP_STATE_INPUTSOURCE) {
            CALayer *layer = self.captionContainer.layer;
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 140, 0, -180);
            rotationAndPerspectiveTransform.m34 = 1.0 / -500;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            layer.transform = rotationAndPerspectiveTransform;
        }
    }
    
    [self.rootContainerView bringSubviewToFront:view];
    [controller onRootMadeActive];
    [self.view layoutIfNeeded];
    
}

-(void)setAppState:(VBAppState)appState
{
    [self setAppState:appState animate:NO];
}

- (void)setAppState:(VBAppState)appState animate:(BOOL)animate
{
    _appState = appState;
    CGFloat duration = animate ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self animateViewsToAppState];
    }];
}

- (void)addChildController:(VBViewController *)viewController toView:(UIView *)view
{
    [self addChildViewController:viewController];
    [view addSubview:viewController.view];
    viewController.view.frame = view.frame;
    
    // note that each child controller has a chance to do something once
    // the root view has loaded through this call
    [viewController onRootViewDidLoad];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.welcomeController = [VBWelcomeController controller];
    [self addChildController:self.welcomeController toView:self.welcomeContainer];
    
    self.captionController = [VBCaptionController controller];
    [self addChildController:self.captionController toView:self.captionContainer];
    
    self.checkinController = [VBCheckinController controller];
    [self addChildController:self.checkinController toView:self.checkinContainer];
    
    self.inputSourceController = [VBInputSourceController controller];
    [self addChildController:self.inputSourceController toView:self.inputSourceContainer];
    
    // setup initial app state
    self.appState = APP_STATE_WELCOME;
    
}

- (IBAction)onButtonTap:(id)sender {
    // on tap the mic and location button toggle between themselves and the caption view
    if (sender == self.micButton) {
        [self setAppState:((self.appState == APP_STATE_INPUTSOURCE)?APP_STATE_CAPTION:APP_STATE_INPUTSOURCE) animate:YES];
    }
    else if (sender == self.locationButton) {
        [self setAppState:((self.appState==APP_STATE_CHECKIN)?APP_STATE_CAPTION:APP_STATE_CHECKIN) animate:YES];
    }
    else
        [NSException raise:@"Unimplemented Sender" format:@"Unable to find target for sender %@", sender];
}


@end
