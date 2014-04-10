//
//  VBUserTests.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/9/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+AsyncTesting.h"

@interface VBUserTests : XCTestCase

@end

@implementation VBUserTests

- (void)testCurrentUserLoaded
{
    if (VBUser.currentUser)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:VBUserEventCurrentUserAdded object:nil queue:nil usingBlock:^(NSNotification *note) {
        id user = [note.object currentUser];
        XCTAssertNotNil(user);
        XCTAssertEqual([user class], VBUser.class);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    }];
    
    if (!VBFoursquare.isAuthorized)
        [VBFoursquare authorize];
    
    [self waitForTimeout:30];
    
}

- (void)testCheckIn
{
    [VBFoursquare venuesNearbyWithSuccess:^(NSArray *venues) {
        NSUInteger index = arc4random() % [venues count];
        VBVenue *venue = venues[index];
        [VBUser.currentUser checkInWithVenue:venue success:^(VBUser *user) {
            XCTAssertEqual(user.venue.foursquareID, venue.foursquareID);
            [self notify:XCTAsyncTestCaseStatusSucceeded];
        } failure:^(NSError *error) {
            XCTFail(@"%@", error);
            [self notify:XCTAsyncTestCaseStatusFailed];
        }];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:30];
}

@end
