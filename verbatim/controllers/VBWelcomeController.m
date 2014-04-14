//
//  VBWelcomeController.m
//  verbatim
//
//  Created by Chris Ahlering on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBWelcomeController.h"
#import "VBColor.h"

@interface VBWelcomeController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel3;
@property (weak, nonatomic) IBOutlet UIImageView *welcomeLogo;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *allOutlets;
@end

@implementation VBWelcomeController

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
    self.view.backgroundColor = [VBColor backgroundColor];
    
    NSDictionary *highlightedAttributes = @{
                                            NSForegroundColorAttributeName: [VBColor greenColor]
                                            };
    NSDictionary *standardAttributes = @{
                                            NSForegroundColorAttributeName: [VBColor opaqueTextColor]
                                            };
    NSMutableAttributedString *tapString = [[NSMutableAttributedString alloc]init];
    [tapString appendAttributedString:[[NSAttributedString alloc]initWithString:@"Tap" attributes:highlightedAttributes]];
    [tapString appendAttributedString:[[NSAttributedString alloc]initWithString:@" To Begin." attributes:standardAttributes]];

    [_welcomeLabel3 setAttributedText:tapString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTap:(UITapGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIViewControllerAnimatedTransitioning methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];

    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    VBWelcomeController *welcomeController = nil;
    if ([toController isKindOfClass:[VBWelcomeController class]]) {
        welcomeController = (VBWelcomeController *)toController;
    }
        
    
    [containerView addSubview:toController.view];
    toController.view.frame = containerView.frame;
    
    toController.view.alpha = 0;
    
    CGFloat firstAnimation = 1;
    if (welcomeController) {
        firstAnimation = 0;
    }
    [UIView animateWithDuration:firstAnimation animations:^{
        for (UIView *outlet in [welcomeController allOutlets]) {
            [outlet setAlpha:0];
        }
        [toController.view setAlpha:1];
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.9 animations:^{
            for (UIView *outlet in [welcomeController allOutlets]) {
                [outlet setAlpha:1];
            }
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }];
}



@end
