//
//  VBCheckinController.m
//  verbatim
//
//  Created by Nicolas Halper on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBCheckinController.h"
#import <AKLocationManager/AKLocationManager.h>


@interface VBCheckinController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSArray *venues; // of VBVenue

@end

@implementation VBCheckinController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    [self fetchVenues];
    
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
    NSLog(@"Selected venue: %@",selectedVenue);
    
    // TODO: push the selected venue onto the VBInputSourceController and display
    // or possibly just update navigation controller and have select input as a 2nd option.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
