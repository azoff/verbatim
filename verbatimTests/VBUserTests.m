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

@end
