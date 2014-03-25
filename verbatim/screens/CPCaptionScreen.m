//
//  CPCaptionScreen.m
//  groupproject
//
//  Created by Jonathan Azoff on 3/24/14.
//  Copyright (c) 2014 Jonathan Azoff. All rights reserved.
//

#import "CPCaptionScreen.h"

@interface CPCaptionScreen ()

@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@end

@implementation CPCaptionScreen

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
