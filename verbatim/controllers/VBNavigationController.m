//
//  VBNavigationController.m
//  verbatim
//
//  Created by Chris Ahlering on 4/7/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBNavigationController.h"
#import "VBCaptionController.h"
#import "VBColor.h"
#import "UIImage+Overlay.h"
#import "VBTranslationTitleView.h"

@interface VBNavigationController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *titleBarButtons;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonVerticalContraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarTopConstraint;
@property (weak, nonatomic) UIView *stateMenu;
@property (weak, nonatomic) UIButton *stateButton;
@property (strong, nonatomic) VBCaptionController *captionController;

@property (weak, nonatomic) id<VBMenuNavigationState> menuState;

- (IBAction)selectSource:(UIButton *)sender;
- (IBAction)checkIn:(UIButton *)sender;
- (IBAction)translateOptions:(UIButton *)sender;

@end

@implementation VBNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    for (UIButton *barButton in _titleBarButtons) {
        UIImage *imageForBasicState = [barButton.imageView.image imageWithColor:[VBColor whiteColor]];
        UIImage *imageForSelectedState = [barButton.imageView.image imageWithColor:[VBColor selectedColor]];
        [barButton setImage:imageForBasicState forState:UIControlStateNormal];
        [barButton setImage:imageForSelectedState forState:UIControlStateSelected];
    }
    _captionController = [[VBCaptionController alloc]init];
    [self addChildViewController:_captionController];
    [self.view addSubview:_captionController.view];
    [self.view bringSubviewToFront:_toolbar];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doMenuWithAnimation :(void(^)(void))menuAnimation
{
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         menuAnimation();
                         [_toolbar layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                     }
    ];
}

- (BOOL) isAnyOptionSelected
{
    BOOL anySelected = NO;
    for (UIButton *button in _titleBarButtons) {
        anySelected = button.selected;
        if (anySelected) break;
    }
    return anySelected;
}

- (IBAction)selectSource:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    if (sender.selected) {
        [self doMenuWithAnimation:^{
            ;
        }];
    } else {
        [self doMenuWithAnimation:^{
            ;
        }];
    }
}

- (IBAction)checkIn:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    if (sender.selected) {
        [self doMenuWithAnimation:^{
            ;
        }];
    } else {
        [self doMenuWithAnimation:^{
            ;
        }];
    }
}

- (IBAction)translateOptions:(UIButton *)sender {
    _stateButton = sender;
    [sender setSelected:!sender.selected];
    if (sender.selected) {
        [self doMenuWithAnimation:^{

            UINib *nib = [UINib nibWithNibName:@"VBTranslationTitleView" bundle:nil];
            NSArray *objects = [nib instantiateWithOwner:self options:nil];
            VBTranslationTitleView *translateView = objects[0];
            translateView.delegate = self;

            _stateMenu = translateView;
            [_stateMenu setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.view addSubview:_stateMenu];
            
            [self.view removeConstraint:_toolbarTopConstraint];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stateMenu
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:86
                                      ]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stateMenu
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:320
                                      ]];

            [self.view addConstraint:[NSLayoutConstraint
                                      constraintWithItem:_stateMenu
                                      attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.view
                                      attribute:NSLayoutAttributeLeading
                                      multiplier:1
                                      constant:10
                                      ]];
            
            _toolbarTopConstraint = [NSLayoutConstraint
                                     constraintWithItem:_toolbar
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:_stateMenu
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:0
                                     ];
            [self.view addConstraint:_toolbarTopConstraint];
            [_toolbar setHidden:YES];
            [self.view bringSubviewToFront:_stateMenu];
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark VBMenuNavigationState methods
-(void)stateDidChange
{
    [_stateButton setSelected:NO];
    [self doMenuWithAnimation:^{
        
        [_stateMenu removeFromSuperview];
        _toolbarTopConstraint = [NSLayoutConstraint constraintWithItem:_toolbar
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1
                                                              constant:10
                                 ];
        [self.view addConstraint:_toolbarTopConstraint];
        [_toolbar setHidden:NO];
        [self.view layoutIfNeeded];
    }];
    
}


@end
