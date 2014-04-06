//
//  verbatimTests.m
//  verbatimTests
//
//  Created by Jonathan Azoff on 4/6/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface VBUserTests : XCTestCase

@end

@implementation VBUserTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    [[VBUser currentUser] delete];
    [super tearDown];
}

- (void)testCurrentUser
{
    XCTAssertNotNil([VBUser currentUser], @"Unable to find anonymous user");
}

- (void)testCurrentUserIsAnonymous
{
    XCTAssertTrue([[VBUser currentUser] isAnonymous], @"Current user is not anonymous");
}

@end
