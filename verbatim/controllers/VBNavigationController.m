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
- (IBAction)selectSource:(id)sender;
- (IBAction)checkIn:(id)sender;
- (IBAction)translateOptions:(id)sender;

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
        barButton.imageView.image = [barButton.imageView.image imageWithColor:[UIColor whiteColor]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectSource:(id)sender {
}
- (IBAction)checkIn:(id)sender {
}

- (IBAction)translateOptions:(id)sender {
}
@end
