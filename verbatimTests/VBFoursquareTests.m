//
//  VBFoursquareTests.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/7/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VBFoursquare.h"
#import "XCTestCase+AsyncTesting.h"

@interface VBFoursquareTests : XCTestCase

@end

@implementation VBFoursquareTests

- (void)setUp
{
    // uncomment to test authorization flow
    // [VBFoursquare deauthorize];
    [super setUp];
    if (!VBFoursquare.isAuthorized) {
        [[NSNotificationCenter defaultCenter] addObserverForName:VBFoursquareEventAuthorized object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self notify:XCTAsyncTestCaseStatusSucceeded];
        }];
        [VBFoursquare authorize];
        [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:20];
    }
}

- (void)testVenueSearch
{
    [VBFoursquare venuesNearbyWithSuccess:^(NSArray *venues) {
        XCTAssertNotEqual(venues.count, 0);
        XCTAssertEqual([venues[0] class], VBVenue.class);
        XCTAssertNotEqual([[venues[0] foursquareID] length], 0);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForTimeout:10];
    
}

- (void)testCurrentUserDetails
{
    [VBFoursquare currentUserDetailsWithSuccess:^(VBUser *user) {
        XCTAssertNotNil(user);
        XCTAssertEqual(user.class, VBUser.class);
        XCTAssertNotEqual(user.foursquareID.length, 0);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForTimeout:10];
    
}

@end
