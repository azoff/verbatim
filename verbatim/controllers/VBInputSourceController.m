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
@property (strong,nonatomic) VBVenue *venue; // the venue users are in
@property (strong,nonatomic) NSMutableArray *users; // of VBUser

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

- (NSMutableArray *)users
{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

// A simple test and/or demo function to simulate a data fetch
-(NSArray *)fetchSimulatedData
{
    NSArray *testData = @[
                           @{@"firstName":@"Michelle",@"lastName":@"Obama"},
                           @{@"firstName":@"Rachel",@"lastName":@"Jones"},
                           @{@"firstName":@"Nick",@"lastName":@"Halper"},
                           @{@"firstName":@"Jonathan",@"lastName":@"Azoff"},
                           @{@"firstName":@"Chris",@"lastName":@"Ahlering"},
                           @{@"firstName":@"Tim",@"lastName":@"Lee"},
                           @{@"firstName":@"Ridiculously-Long",@"lastName":@"Name-That-We-Cannot-Pronounce"}
                           ];
    return testData;
    
}


- (void)fetchUsers
{
    // TODO: the following test array should be replaced with a
    // parse query to fetch all users from the given self.venue
    NSArray *fetchedData = [self fetchSimulatedData];
    
    NSMutableArray *userArray = [NSMutableArray array];
    
    for (NSDictionary *userDictionary in fetchedData) {
        VBUser *user = [[VBUser alloc] init];
        user.firstName = userDictionary[@"firstName"];
        user.lastName = userDictionary[@"lastName"];
        [userArray addObject:user];
    }
    self.users = userArray;
    [self.tableView reloadData];
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
    
    VBUser *currentUser = [VBUser currentUser];
    if (currentUser) {
        NSLog(@"User is %@",currentUser);
        self.loginView.hidden = YES;
        self.tableView.hidden = NO;
        [self fetchUsers];
    } else {
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
