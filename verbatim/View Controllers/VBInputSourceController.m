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
    
    // data source
    id name = @"UserCell";
    self.userDataSource = [VBUserDataSource sourceWithCellReuseIdentifier:name andVenue:venue];
    self.sourceTableView.dataSource = self.userDataSource;
    [self.sourceTableView registerNib:VBUserTableViewCell.nib forCellReuseIdentifier:name];
    
    [self.userDataSource observeUpdateWithBlock:^(NSError *error) {
        if (error) [VBHUD showWithError:error];
        else self.sourceTableView.alpha = 1;
        [self.sourceTableView reloadData];
    }];
    
    // delegate
    self.sourceTableView.delegate = self.userDelegate = [VBUserDelegate delegateWithSubDelegate:self];
    
}

- (void)updateTableView
{
    self.userDataSource.venue = [[VBUser currentUser] venue];
}

- (void)addObservers
{
    id center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateTableView) name:VBUserEventSourceChanged object:nil];
    [center addObserver:self selector:@selector(onUserCheckedIn) name:VBUserEventCheckedIn object:nil];
    [center addObserver:self selector:@selector(onDeauthorized) name:VBUserEventCurrentUserRemoved object:nil];
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTableView];
    [self addObservers];
}

-(void)onRootViewDidLoad
{
    // prefetch the data as soon as the root view has loaded so we
    // have it all ready if a user is checked in on startup
    [self updateTableView];
}

-(void)onRootMadeActive
{
    // refresh data whenever we switch back to this view
    [self updateTableView];
    [self updateSourceNameLabelText];
    [self updateContainerViews];
}

-(void)onUserCheckedIn
{
    // when user checks in, update our checked in states for views
    // and fetch new data
    self.userDataSource.venue = [[VBUser currentUser] venue];
    [self updateContainerViews];
    [self updateTableView];
}

-(void)onDeauthorized
{
    // when logging out, update login/out state
    [self updateContainerViews];
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
            
            // transition back to caption view
            [self.rootController switchToAppState:APP_STATE_CAPTION animate:YES];
            
        } failure:^(NSError *error) {
            [VBHUD showWithError:error];
        }];
    }
}

- (IBAction)onCheckInTap:(id)sender
{
    if ([VBUser currentUser])
        [self.rootController switchToAppState:APP_STATE_CHECKIN animate:YES];
    else
        [VBFoursquare authorize];
        
}
@end