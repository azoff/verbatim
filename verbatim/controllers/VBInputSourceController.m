//
//  VBInputSourceController.m
//  verbatim
//
//  Created by Nicolas Halper on 4/12/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBInputSourceController.h"

@interface VBInputSourceController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *users; // of VBUser

@end

@implementation VBInputSourceController

NSString *const VBInputSourceControllerChangedSourceUserNotification = @"VBInputSourceControllerChangedSourceUserNotification";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)fetchUsersFromVenue:(VBVenue *)venue
{
    
    [venue checkedInUsersWithSuccess:^(NSArray *users) {
        self.users = users;
        [self.tableView reloadData];
    } andFailure:^(NSError *error) {
        [VBHUD showWithError:error];
    }];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // we hide both views until we reach setup, at which point we'll show either the login or table view.
    self.loginView.hidden = YES;
    self.tableView.hidden = YES;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // if the user logs in or logs out, make sure to update this controller's state and enter setup.
    [[NSNotificationCenter defaultCenter] addObserverForName:VBUserEventCurrentUserAdded object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"Got user logged in notification");
        [self setup];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:VBUserEventCurrentUserRemoved object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"Got user logged out notification");
        [self setup];
    }];
    
    [self setup];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InputSourceTestCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"InputSourceTestCell"];
    }
    VBUser *user = [self.users objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",user.firstName,user.lastName];
    cell.detailTextLabel.text = @"(x listeners)";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // get user selected
    VBUser *selectedUser = [self.users objectAtIndex:indexPath.row];
    NSLog(@"Selected user: %@",selectedUser);
    NSDictionary *userInfo = @{
                               @"user":selectedUser
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:VBInputSourceControllerChangedSourceUserNotification object:self userInfo:userInfo];
    
}


- (void)setup
{
    NSLog(@"VBInputSourceController setup");
    // depending on the state, the InputSourceController does one of three things:
    // unauthenticated: show the foursquare button (which starts the authentication flow)
    // authenticated but NOT checked in to a venue: transition to CheckinController
    // checked-in: display users at venue
    
    VBUser *currentUser = [VBUser currentUser];
    
    if (currentUser) {
        // we are authenticated. Check if we have a venue
        if (currentUser.venue) {
            // when we have a venue, fetch users from venue and display in table view.
            self.loginView.hidden = YES;
            self.tableView.hidden = NO;
            [self fetchUsersFromVenue:currentUser.venue];
        }
        else {
            // no venue? Then transition to VBCheckinController
            self.loginView.hidden = YES;
            self.tableView.hidden = YES;
            [VBHUD showWithText:@"todo:transition to checkinController"];
        }
        
    } else {
        // we are not authenticated, so show the foursquare login view
        self.loginView.hidden = NO;
        self.tableView.hidden = YES;
        NSLog(@"User is not logged in ");
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end