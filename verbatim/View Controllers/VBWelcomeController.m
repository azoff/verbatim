//
//  VBWelcomeController.m
//  verbatim
//
//  Created by Chris Ahlering on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBWelcomeController.h"
#import "VBCaptionController.h"
#import "VBInputSourceManager.h"

@interface VBWelcomeController ()

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel3;

- (IBAction)onTap:(id)sender;

@end

@implementation VBWelcomeController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    NSDictionary *highlightedAttributes = @{NSForegroundColorAttributeName: [VBColor activeColor]};
    NSDictionary *standardAttributes = @{NSForegroundColorAttributeName: [VBColor translucsentTextColor]};
    NSMutableAttributedString *tapString = [[NSMutableAttributedString alloc]init];
    [tapString appendAttributedString:[[NSAttributedString alloc]initWithString:@"Tap" attributes:highlightedAttributes]];
    [tapString appendAttributedString:[[NSAttributedString alloc]initWithString:@" To Begin." attributes:standardAttributes]];

    self.welcomeLabel1.textColor = [VBColor translucsentTextColor];
    self.welcomeLabel2.textColor = [VBColor activeColor];
    [self.welcomeLabel3 setAttributedText:tapString];
}

- (IBAction)onTap:(id)sender {
    [[VBInputSourceManager manager] startListening];
    [self.rootController renderViewControllerWithClass:VBCaptionController.class];
}

@end
