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
@property (weak, nonatomic) IBOutlet UIView *headerContainer;
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
@property (weak, nonatomic) IBOutlet UIView *welcomeContainer;
@property (weak, nonatomic) IBOutlet UIView *welcomeView;

@property (weak, nonatomic) IBOutlet UIView *captionContainer;
@property (weak, nonatomic) IBOutlet UIView *captionView;

@property (weak, nonatomic) IBOutlet UIView *inputSourceContainer;
@property (weak, nonatomic) IBOutlet UIView *inputSourceView;

@property (weak, nonatomic) IBOutlet UIView *checkinContainer;
@property (weak, nonatomic) IBOutlet UIView *checkinView;

@property (weak, nonatomic) IBOutlet UIImageView *transitionToCameraView;

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
        self.captionContainer.alpha = 0.5;
        self.captionContainer.transform = CGAffineTransformMakeScale(0.9,0.9);
    }
    if (!(self.appState == APP_STATE_INPUTSOURCE)) {
        // move InputSource away again
        self.inputSourceContainer.transform = CGAffineTransformMakeTranslation(320.0,0);
        self.inputSourceContainer.alpha = 0.5;
    }
    if (!(self.appState == APP_STATE_CHECKIN)) {
        // move checkin state away
        self.checkinContainer.transform = CGAffineTransformMakeTranslation(-320.0,0);
        self.checkinContainer.alpha = 0.5;
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
        
        self.checkinContainer.alpha = 0.3;
        self.inputSourceContainer.alpha = 0.3;
        
        self.inputSourceContainer.hidden = YES;
        self.captionContainer.hidden = YES;
        self.welcomeView.alpha = 1;

        [self.view bringSubviewToFront:self.welcomeContainer];
        [self.welcomeController onRootMadeActive];
    }
    else if ((self.appState == APP_STATE_CAPTION)) {
        self.captionContainer.hidden = NO;
        self.captionContainer.alpha = 1;
        self.captionContainer.transform = CGAffineTransformIdentity;
        
        [self.view bringSubviewToFront:self.captionContainer];
        [self.captionController onRootMadeActive];
        
    }
    else if (self.appState == APP_STATE_INPUTSOURCE) {
        self.inputSourceContainer.hidden = NO;
        self.inputSourceContainer.alpha = 1;
        self.inputSourceContainer.transform = CGAffineTransformIdentity;
        
        self.captionContainer.alpha = 0.5;
        self.captionContainer.transform = CGAffineTransformIdentity;
        CALayer *layer = self.captionContainer.layer;
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 140, 0, -180);
        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        layer.transform = rotationAndPerspectiveTransform;

        [self.view bringSubviewToFront:self.inputSourceContainer];
        [self.inputSourceController onRootMadeActive];
    }
    else if (self.appState == APP_STATE_CHECKIN) {
        self.checkinContainer.hidden = NO;
        self.checkinContainer.alpha = 1;
        self.checkinContainer.transform = CGAffineTransformIdentity;
        
        [self.view bringSubviewToFront:self.checkinContainer];
        [self.checkinController onRootMadeActive];
    }
    
    [self.view bringSubviewToFront:self.headerContainer];
}

- (void)animateNewCameraSourceWithAnimationFrame:(CGRect)frame andImage:(UIImage *)image complete:(void (^)())complete {
    
    [self.view bringSubviewToFront:self.transitionToCameraView];
    
    self.transitionToCameraView.image = image;
    self.transitionToCameraView.alpha = 0.0;
    self.transitionToCameraView.frame = frame;
    self.transitionToCameraView.hidden = NO;
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transitionToCameraView.frame = self.view.frame;
        self.transitionToCameraView.alpha = 0.8;
        self.transitionToCameraView.transform = CGAffineTransformIdentity;
        CALayer *layer = self.transitionToCameraView.layer;
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 240, 0, 100);
        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -10.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
        layer.transform = rotationAndPerspectiveTransform;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.transitionToCameraView.frame = self.view.frame;
            self.transitionToCameraView.alpha = 1;
            self.transitionToCameraView.transform = CGAffineTransformIdentity;
            CALayer *layer = self.transitionToCameraView.layer;
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 140, 0, -180);
            rotationAndPerspectiveTransform.m34 = 1.0 / -500;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
            layer.transform = rotationAndPerspectiveTransform;
        } completion:^(BOOL finished) {
            self.transitionToCameraView.hidden = YES;
            
            complete();
            
            // a final fading animation to get back to normal state.
            self.captionContainer.alpha = 1;
            [UIView animateWithDuration:0.2 animations:^{
                self.captionContainer.alpha = 0.5;
            }];
            
        }];
    }];
    
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
    self.headerContainer.hidden = hidden;
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
    
    self.headerContainer.backgroundColor = self.headerView.backgroundColor = [UIColor redColor];
    self.welcomeContainer.backgroundColor = [UIColor clearColor];
    self.captionContainer.backgroundColor = self.captionView.backgroundColor = [UIColor clearColor];
    self.inputSourceContainer.backgroundColor = self.inputSourceView.backgroundColor = [UIColor clearColor];
    self.checkinContainer.backgroundColor = self.checkinView.backgroundColor = [UIColor clearColor];
    
    self.transitionToCameraView.hidden = YES;
    
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
