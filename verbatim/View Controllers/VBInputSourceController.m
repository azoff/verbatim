//
//  VBInputSourceController.m
//  verbatim
//
//  Created by Nicolas Halper on 4/12/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBInputSourceController.h"
#import "VBUserTableViewCell.h"
#import "VBCheckinController.h"
#import "VBUserDataSource.h"
#import "VBUserDelegate.h"
#import "VBButton.h"
#import "VBLabel.h"

@interface VBInputSourceController () <VBUserSubDelegate>

@property (weak, nonatomic) IBOutlet VBLabel *sourceNameLabel;
@property (weak, nonatomic) IBOutlet UIView *checkInContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *checkInImageView;
@property (weak, nonatomic) IBOutlet UITableView *sourceTableView;
- (IBAction)onCheckInTap:(id)sender;

@property (nonatomic) VBUserDataSource *userDataSource;
@property (nonatomic) VBUserDelegate *userDelegate;

@end

@implementation VBInputSourceController

-(void)updateSourceNameLabelText
{
    id label = [[[VBUser currentUser] source] label];
    self.sourceNameLabel.text = label ? label : VBUserDefaultLabel;
}

-(void)updateContainerViews
{
    BOOL checkedIn = [[VBUser currentUser] isCheckedIn];
    self.checkInContainerView.hidden = checkedIn;
    self.sourceTableView.hidden = !checkedIn;
}

- (void)setupTableView
{
    
    self.sourceNameLabel.textColor = [VBColor activeColor];
    
    // colors
    self.sourceTableView.backgroundColor = [UIColor clearColor];
    self.sourceTableView.separatorColor = [VBColor separatorColor];
    UIView *view = [UIView new]; view.backgroundColor = [UIColor clearColor];
    self.sourceTableView.backgroundView = view;
    self.sourceTableView.separatorColor = [VBColor separatorColor];
    self.sourceTableView.separatorInset = UIEdgeInsetsZero;
    self.sourceTableView.alpha = 0;
    
    id venue = [[VBUser currentUser] venue];
    if (!venue) return; // exit early if no venue data to load
    
    // data source
    id name = @"UserCell";
    self.userDataSource = [VBUserDataSource sourceWithCellReuseIdentifier:name andVenue:venue];
    self.sourceTableView.dataSource = self.userDataSource;
    [self.sourceTableView registerNib:VBUserTableViewCell.nib forCellReuseIdentifier:name];
    
    // delegate
    self.sourceTableView.delegate = self.userDelegate = [VBUserDelegate delegateWithSubDelegate:self];
    
}

- (void)reloadUsers
{
    [VBHUD showIndeterminateProgressWithText:@"Loading Sources..."];
    [self.userDataSource reloadWithError:^(NSError *error) {
        if (error) {
            [VBHUD showWithError:error];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.sourceTableView.alpha = 1.0;
            }];
            [VBHUD hide];
            [self.sourceTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

- (void)updateTableView
{
    if ([[VBUser currentUser] isCheckedIn]) {
        [self reloadUsers];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.sourceTableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.sourceTableView reloadData];
        }];
    }
    
}

- (void)addObservers
{
    id center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateTableView) name:VBUserEventCheckedIn object:nil];
    [center addObserver:self.sourceTableView selector:@selector(reloadData) name:VBUserEventSourceChanged object:nil];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self updateSourceNameLabelText];
    [self updateContainerViews];
    [self updateTableView];
    [self addObservers];
}

- (UITableViewCell *)cellForHeightMeasurement
{
    return [self.sourceTableView dequeueReusableCellWithIdentifier:self.userDataSource.cellReuseIdentifier];
}

-(void)didSelectUser:(VBUser *)user
{
    id me = [VBUser currentUser];
    if (me) {
        [VBHUD showIndeterminateProgressWithText:@"Applying..."];
        [me saveSourceWithUser:user success:^(VBUser *user) {
            [VBHUD showDoneWithText:@"Done!" hideAfterDelay:1];
            [self.sourceTableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self updateSourceNameLabelText];
        } failure:^(NSError *error) {
            [VBHUD showWithError:error];
        }];
    }
}

- (IBAction)onCheckInTap:(id)sender
{
    [self.rootController renderViewControllerWithClass:VBCheckinController.class];
}
@end