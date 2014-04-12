//
//  VBNavigationController.m
//  verbatim
//
//  Created by Chris Ahlering on 4/7/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBNavigationController.h"
#import "VBColor.h"

@interface VBNavigationController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *titleBarButtons;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
- (IBAction)selectSource:(UIButton *)sender;
- (IBAction)checkIn:(UIButton *)sender;
- (IBAction)translateOptions:(UIButton *)sender;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonVerticalContraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarTopConstraint;
@property (weak, nonatomic) UIView *stateMenu;
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
    [sender setSelected:!sender.selected];
    if (sender.selected) {
        [self doMenuWithAnimation:^{

            UINib *nib = [UINib nibWithNibName:@"TranslationTitleView" bundle:nil];
            NSArray *objects = [nib instantiateWithOwner:self options:nil];
            _stateMenu = objects[0];
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
            //    [self.view addConstraints:[NSLayoutConstraint
            //                              constraintsWithVisualFormat:@"V:|-45-[_stateMenu]"
            //                              options:0
            //                              metrics:nil
            //                              views:NSDictionaryOfVariableBindings(_stateMenu)
            //                              ]];
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
            [self.view layoutIfNeeded];
        }];
    } else {
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
}

@end
