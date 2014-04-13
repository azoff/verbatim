//
//  VBVenueTest.m
//  verbatim
//
//  Created by Jonathan Azoff on 4/12/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTestCase+AsyncTesting.h"

@interface VBVenueTest : XCTestCase

@property (nonatomic) VBVenue *venue;
@property (nonatomic) VBUser *user;

@end

@implementation VBVenueTest

- (void)setUp
{
    [super setUp];
    self.user = [VBUser object];
    self.venue = [VBVenue object];
    self.venue.foursquareID = @"44e1e15af964a52023371fe3";
    self.user.venue = self.venue;
    [self.venue save];
    [self.user save];
}

- (void)tearDown
{
    [self.user delete];
    [self.venue delete];
    [super tearDown];
}

- (void)testHydratedVenueUserCount
{
    [self.venue checkedInUserCountWithSuccess:^(int count) {
        XCTAssertEqual(count, 1);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:10];
}

- (void)testHydratedVenueUser
{
    [self.venue checkedInUsersWithSuccess:^(NSArray *users) {
        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects([users[0] foursquareID], self.user.foursquareID);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:10];
}

- (void)testDehydratedVenueUserCount
{
    VBVenue *venue = [VBVenue object];
    venue.foursquareID = self.venue.foursquareID;
    [venue checkedInUserCountWithSuccess:^(int count) {
        XCTAssertEqual(count, 1);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:10];
}

- (void)testDehydratedVenueUser
{
    VBVenue *venue = [VBVenue object];
    venue.foursquareID = self.venue.foursquareID;
    [venue checkedInUsersWithSuccess:^(NSArray *users) {
        XCTAssertEqual(users.count, 1);
        XCTAssertEqualObjects([users[0] foursquareID], self.user.foursquareID);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:10];
}

- (void)testEmptyVenueUserCount
{
    VBVenue *venue = [VBVenue object];
    venue.foursquareID = @"foobar";
    [venue checkedInUserCountWithSuccess:^(int count) {
        XCTAssertEqual(count, 0);
        [self notify:XCTAsyncTestCaseStatusSucceeded];
    } andFailure:^(NSError *error) {
        XCTFail(@"%@", error);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:10];
}

@end
