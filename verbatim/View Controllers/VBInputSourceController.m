//
//  VBInputSourceController.m
//  verbatim
//
//  Created by Nicolas Halper on 4/12/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBInputSourceController.h"
#import "VBCheckinController.h"
#import "VBBarButtonItem.h"

@interface VBInputSourceController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray *users; // of VBUser

@end

@implementation VBInputSourceController


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

-(void)setupNavigationBar
{
    [super setupNavigationBar];
    self.navigationItem.leftBarButtonItem = [VBBarButtonItem locationButtonWithTarget:self action:@selector(gotoCheckinController)];
    self.navigationItem.rightBarButtonItem = [VBBarButtonItem captionButtonWithTarget:self action:@selector(dismissController)];
}

-(void)dismissController
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)gotoCheckinController
{
    [self.vbNavigationController pushViewController:[VBCheckinController controller] animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupNavigationBar];
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
    [VBUser currentUser].source = [self.users objectAtIndex:indexPath.row];
    [[VBUser currentUser] saveEventually];
}


- (void)setup
{
    VBUser *currentUser = [VBUser currentUser];
    self.tableView.hidden = currentUser && currentUser.venue;
    self.loginView.hidden = !self.tableView.hidden;
    if (!self.tableView.hidden)
        [self fetchUsersFromVenue:currentUser.venue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end