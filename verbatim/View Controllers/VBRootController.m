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
@property (weak, nonatomic) IBOutlet UIView *headerView; // the parent view for nav
@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet VBButton *micButton;
@property (weak, nonatomic) IBOutlet VBButton *locationButton;

// our child view controllers
@property (nonatomic,strong) VBCaptionController *captionController;
@property (nonatomic,strong) VBInputSourceController *inputSourceController;
@property (nonatomic,strong) VBCheckinController *checkinController;
@property (nonatomic,strong) VBWelcomeController *welcomeController;

// views for our child view controllers for transition management
@property (weak, nonatomic) IBOutlet UIView *containerView; // the parent view for child controllers
@property (weak, nonatomic) IBOutlet UIView *welcomeView;
@property (weak, nonatomic) IBOutlet UIView *captionView;
@property (weak, nonatomic) IBOutlet UIView *checkinView;
@property (weak, nonatomic) IBOutlet UIView *inputSourceView;

@property (assign,nonatomic) VBAppState appState;

- (IBAction)onButtonTap:(id)sender;

@end

@implementation VBRootController

- (void)updateViewsToAppState
{

    id on  = [VBColor activeColor];
    id off = [VBColor translucsentTextColor];

    
    // reset to previous positions.
    if (!(self.appState == APP_STATE_CAPTION)) {
        // zoom caption state into background...
        self.captionView.alpha = 0.5;
        self.captionView.transform = CGAffineTransformMakeScale(0.9,0.9);
    }
    if (!(self.appState == APP_STATE_INPUTSOURCE)) {
        // move InputSource away again
        self.inputSourceView.transform = CGAffineTransformMakeTranslation(300.0,0);
        self.inputSourceView.alpha = 0.5;
    }
    if (!(self.appState == APP_STATE_CHECKIN)) {
        // move checkin state away
        self.checkinView.transform = CGAffineTransformMakeTranslation(-300.0,0);
        self.checkinView.alpha = 0.5;
    }
    if (!(self.appState == APP_STATE_WELCOME)) {
        self.welcomeView.alpha = 0;
        self.welcomeView.transform = CGAffineTransformMakeScale(4,4);
    }
    
    // handle nav bar states
    [self setNavBarHidden:(self.appState == APP_STATE_WELCOME) animated:YES];
    self.micButton.overlayColor = (self.appState == APP_STATE_INPUTSOURCE) ? on : off;
    self.locationButton.overlayColor = (self.appState == APP_STATE_CHECKIN) ? on : off;
    
    if (self.appState == APP_STATE_WELCOME) {
        
        self.welcomeView.hidden = NO;
        
        self.checkinView.alpha = 0.3;
        self.inputSourceView.alpha = 0.3;
        
        self.inputSourceView.hidden = YES;
        self.captionView.hidden = YES;
        self.welcomeView.alpha = 1;

        [self.containerView bringSubviewToFront:self.welcomeView];
        [self.welcomeController onRootMadeActive];
    }
    else if ((self.appState == APP_STATE_CAPTION)) {
        self.captionView.hidden = NO;
        self.captionView.alpha = 1;
        self.captionView.transform = CGAffineTransformIdentity;
        
        [self.containerView bringSubviewToFront:self.captionView];
        [self.captionController onRootMadeActive];
        
    }
    else if (self.appState == APP_STATE_INPUTSOURCE) {
        self.inputSourceView.hidden = NO;
        self.inputSourceView.alpha = 1;
        self.inputSourceView.transform = CGAffineTransformIdentity;

        [self.containerView bringSubviewToFront:self.inputSourceView];
        [self.inputSourceController onRootMadeActive];
    }
    else if (self.appState == APP_STATE_CHECKIN) {
        NSLog(@"switching app to checkin state");
        self.checkinView.hidden = NO;
        self.checkinView.alpha = 1;
        self.checkinView.transform = CGAffineTransformIdentity;
        
        [self.containerView bringSubviewToFront:self.checkinView];
        [self.checkinController onRootMadeActive];
    }
    [self.headerView bringSubviewToFront:self.navBar];
    [self.view bringSubviewToFront:self.headerView];
}

- (void)switchToAppState:(VBAppState)appState animate:(BOOL)animate
{
    [self switchToAppState:appState removeWelcomeSplash:NO animate:animate];
}

- (void)switchToAppState:(VBAppState)appState removeWelcomeSplash:(BOOL)remove animate:(BOOL)animate
{
    if (!remove && (self.appState == APP_STATE_WELCOME)) {
        // disregard the transition as we are still in the welcome mode.
        return;
    }
    if (animate) {
        [UIView animateWithDuration:0.4 animations:^{
            self.appState = appState;
            [self updateViewsToAppState];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.appState = appState;
        [self updateViewsToAppState];
    }
}

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
    
    self.containerView.backgroundColor = [UIColor clearColor];
    self.captionView.backgroundColor = [UIColor clearColor];
    self.inputSourceView.backgroundColor = [UIColor clearColor];
    self.checkinView.backgroundColor = [UIColor clearColor];
    
    self.welcomeController = [[VBWelcomeController alloc] init];
    [self addChildController:self.welcomeController toView:self.welcomeView];
    
    self.captionController = [[VBCaptionController alloc] init];
    [self addChildController:self.captionController toView:self.captionView];
    
    self.checkinController = [[VBCheckinController alloc] init];
    [self addChildController:self.checkinController toView:self.checkinView];
    
    self.inputSourceController = [[VBInputSourceController alloc] init];
    [self addChildController:self.inputSourceController toView:self.inputSourceView];
    
    // setup initial app state
    self.appState = APP_STATE_WELCOME;
    [self updateViewsToAppState];
    
}

- (IBAction)onButtonTap:(id)sender {
    // on tap the mic and location button toggle between themselves and the caption view
    if (sender == self.micButton) {
        [self switchToAppState:((self.appState == APP_STATE_INPUTSOURCE)?APP_STATE_CAPTION:APP_STATE_INPUTSOURCE) animate:YES];
    }
    else if (sender == self.locationButton) {
        [self switchToAppState:((self.appState==APP_STATE_CHECKIN)?APP_STATE_CAPTION:APP_STATE_CHECKIN) animate:YES];
    }
    else
        [NSException raise:@"Unimplemented Sender" format:@"Unable to find target for sender %@", sender];
}


@end
