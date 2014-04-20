//
//  VBCheckinController.m
//  verbatim
//
//  Created by Nicolas Halper on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCheckinController.h"
#import "VBButton.h"
#import "VBVenueDataSource.h"
#import "VBVenueTableViewCell.h"
#import "VBVenueDelegate.h"

@interface VBCheckinController () <VBVenueSubDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) VBVenueDataSource *venueDataSource;
@property (nonatomic) VBVenueDelegate *venueDelegate;

@end

@implementation VBCheckinController

- (void)fetchVenues
{
    [VBHUD showIndeterminateProgressWithText:@"Searching Nearby Venues..."];
    [self.venueDataSource reloadWithError:^(NSError *error) {
        if (error) {
            [VBHUD showWithError:error];
            [self dismissController];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.tableView.alpha = 1.0;
            }];
            [VBHUD hide];
            [self.tableView reloadData];
        }
    }];
}

- (void)fetchVenuesIfAuthenticated
{
    if ([VBFoursquare isAuthorized]) {
        [self fetchVenues];
    } else {
        id center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(fetchVenues)
                       name:VBFoursquareEventAuthorized object:nil];
        [center addObserver:self selector:@selector(dismissController)
                       name:VBFoursquareEventAuthorizeError object:nil];
        [VBFoursquare authorize];
    }
}

- (void)setupTableView
{
    // colors
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [VBColor separatorColor];
    UIView *view = [UIView new]; view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = view;
    self.tableView.separatorColor = [VBColor separatorColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.alpha = 0;

    // data source
    id name = @"VenueCell";
    self.tableView.dataSource = self.venueDataSource = [VBVenueDataSource sourceWithCellReuseIdentifier:name];
    [self.tableView registerNib:VBVenueTableViewCell.nib forCellReuseIdentifier:name];
    
    // delegate
    self.tableView.delegate = self.venueDelegate = [VBVenueDelegate delegateWithSubDelegate:self];

}

-(void)didSelectVenue:(VBVenue *)venue
{
    [VBHUD showIndeterminateProgressWithText:@"Hold On..."];
    [[VBUser currentUser] checkInWithVenue:venue success:^(VBUser *user) {
        [VBHUD showDoneWithText:@"Checked In!" hideAfterDelay:2];
        [self dismissController];
    } failure:^(NSError *error) {
        [VBHUD showWithError:error];
        [self dismissController];
    }];
}

-(UITableViewCell *)cellForHeightMeasurement
{
    return [self .tableView dequeueReusableCellWithIdentifier:self.venueDataSource.cellReuseIdentifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self fetchVenuesIfAuthenticated];
}

- (void)dismissController
{
    [self.rootController renderLastViewController];
}

@end
