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
    // TODO: need to show hud only if this is an active view...or show it within it's own view
    //[VBHUD showIndeterminateProgressWithText:@"Searching Nearby Venues..."];
    [self.venueDataSource reloadWithError:^(NSError *error) {
        if (error) {
            //[VBHUD showWithError:error];
            [self dismissController];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.tableView.alpha = 1.0;
            }];
            //[VBHUD hide];
            [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

- (void)fetchVenuesIfAuthenticated
{
    if ([VBFoursquare isAuthorized]) {
        [self fetchVenues];
    } else {
        [VBFoursquare authorize];
    }
}

- (void)setupTableView
{
    // colors
    self.view.backgroundColor = [VBColor separatorColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [VBColor separatorColor];
    UIView *view = [UIView new]; view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = view;
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
    [VBHUD showIndeterminateProgressWithText:@"Checkin' in..."];
    [[VBUser currentUser] checkInWithVenue:venue success:^(VBUser *user) {
        [VBHUD showDoneWithText:@"Checked In!" hideAfterDelay:1];
        
        // transition to inputSource view
        [self.rootController setAppState:APP_STATE_INPUTSOURCE animate:YES];
    } failure:^(NSError *error) {
        [VBHUD showWithError:error];
    }];
}

-(UITableViewCell *)cellForHeightMeasurement
{
    return [self .tableView dequeueReusableCellWithIdentifier:self.venueDataSource.cellReuseIdentifier];
}

- (void)addObservers
{
    id center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(fetchVenues) name:VBFoursquareEventAuthorized object:nil];
    [center addObserver:self selector:@selector(dismissController) name:VBFoursquareEventAuthorizeError object:nil];
    [center addObserver:self selector:@selector(dismissController) name:VBFoursquareEventDeauthorized object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self addObservers];
}

- (void)onRootViewDidLoad
{
    [self fetchVenuesIfAuthenticated];
}

- (void)onRootMadeActive
{
    // refetch data each time we come back to the venue list
    [self fetchVenuesIfAuthenticated];
}

- (void)dismissController
{
    [self.rootController setAppState:APP_STATE_CAPTION animate:YES];
}

@end
