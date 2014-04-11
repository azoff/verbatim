//
//  VBNavigationController.m
//  verbatim
//
//  Created by Chris Ahlering on 4/7/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBNavigationController.h"

@interface UIImage(Overlay)
@end

@implementation UIImage(Overlay)

- (UIImage *)imageWithColor:(UIColor *)color1
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

@interface VBNavigationController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *titleBarButtons;
@property (weak, nonatomic) IBOutlet UIView *toolbar;
- (IBAction)selectSource:(UIButton *)sender;
- (IBAction)checkIn:(UIButton *)sender;
- (IBAction)translateOptions:(UIButton *)sender;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *buttonVerticalContraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
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
        UIImage *imageForBasicState = [barButton.imageView.image imageWithColor:[UIColor whiteColor]];
        UIImage *imageForSelectedState = [barButton.imageView.image imageWithColor:[UIColor greenColor]];
        [barButton setImage:imageForBasicState forState:UIControlStateNormal];
        [barButton setImage:imageForSelectedState forState:UIControlStateSelected];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) slideMenu :(BOOL)slideDown
{
    CGFloat targetHeight = _toolbarHeightConstraint.constant;
    if (slideDown) {
        targetHeight = targetHeight * 2;
    } else {
        targetHeight = targetHeight / 2;
    }
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _toolbarHeightConstraint.constant = targetHeight;
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
    BOOL anyOptionPreviouslySelected = [self isAnyOptionSelected];
    [sender setSelected:!sender.selected];
    if ([self isAnyOptionSelected]  != anyOptionPreviouslySelected) {
        [self slideMenu:sender.selected];
    }
}

- (IBAction)checkIn:(UIButton *)sender {
    BOOL anyOptionPreviouslySelected = [self isAnyOptionSelected];
    [sender setSelected:!sender.selected];
    if ([self isAnyOptionSelected]  != anyOptionPreviouslySelected) {
        [self slideMenu:sender.selected];
    }
}

- (IBAction)translateOptions:(UIButton *)sender {
    BOOL anyOptionPreviouslySelected = [self isAnyOptionSelected];
    [sender setSelected:!sender.selected];
    if ([self isAnyOptionSelected] != anyOptionPreviouslySelected) {
        [self slideMenu:sender.selected];
    }
}

@end
