//
//  VBCheckinController.m
//  verbatim
//
//  Created by Nicolas Halper on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCheckinController.h"
#import "VBBarButtonItem.h"
#import <AKLocationManager/AKLocationManager.h>


@interface VBCheckinController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSArray *venues; // of VBVenue

@end

@implementation VBCheckinController


-(id)init
{
    self = [super init];
    if (self) {
        self.title = @"Select Venue";
    }
    return self;
}

- (void)fetchVenues
{
    if (![AKLocationManager canLocate]) {
        // prompt for location info...
        NSLog(@"Cannot locate...display request for location");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Enable Location"
                              message:@"Turn on your location"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    [AKLocationManager startLocatingWithUpdateBlock:^(CLLocation *location){
        // location acquired
        NSLog(@"VBCheckinController:location (%f,%f)",location.coordinate.latitude,location.coordinate.longitude);
        
        [AKLocationManager stopLocating]; // we're done once we have a location.
        
        [VBFoursquare venuesNearbyWithSuccess:^(NSArray *venues) {
            self.venues = venues;
            [self.tableView reloadData];
        } andFailure:^(NSError *error) {
            [VBHUD showWithError:error];
        }];
        
    }
    failedBlock:^(NSError *error){
        //[VBHUD showWithError:error];
        [AKLocationManager stopLocating];
        
        CLLocationCoordinate2D coordinate = [AKLocationManager mostRecentCoordinate]; // we're done once we have a location.
        
        if (!CLLocationCoordinate2DIsValid(coordinate)) {
            NSLog(@"Location invalid");
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Location Invalid"
                                  message:@"Invalid location:set your location!"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
        else {
            // show an unhandled error.
            [VBHUD showWithError:error];
        }
        
    }];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
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


-(void)setupNavigationBar
{
    [super setupNavigationBar];
    self.edgesForExtendedLayout = YES;
    [self.vbNavigationController navigationBarShowBackground:YES];
    self.navigationItem.rightBarButtonItem = [VBBarButtonItem micButtonWithTarget:self action:@selector(dismissController)];
}

-(void)dismissController
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupNavigationBar];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // if we submit "OK" on our alert view, let's go try fetchVenues again...
    NSLog(@"Alert button pressed %d",buttonIndex);
    if (buttonIndex == 1) {
        [self fetchVenues];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueTestCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"VenueTestCell"];
    }
    VBVenue *venue = [self.venues objectAtIndex:indexPath.row];
    cell.textLabel.text = venue.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@ miles) %@",venue.distance, venue.address];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // get venue selected
    VBVenue *selectedVenue = [self.venues objectAtIndex:indexPath.row];
    PFQuery *venueQuery = [VBVenue query];
    //Compare the selected venue, which is created from the Foursquare response, to our known venues
    // so as not to create duplicates in Parse
    [venueQuery whereKey:@"foursquareID" equalTo:selectedVenue.foursquareID];
    NSArray *venues = [venueQuery findObjects];
    if (venues.count > 0) {
        selectedVenue = [venues firstObject];
    }
    NSLog(@"Selected venue: %@",selectedVenue);
    
    [[VBUser currentUser] checkInWithVenue:selectedVenue success:^(VBUser *user) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VBUserEventCurrentUserAdded object:user];
        [self dismissController];
    } failure:^(NSError *error) {
        [VBHUD showWithError:error];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
