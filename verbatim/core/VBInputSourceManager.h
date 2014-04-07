//
//  VBInputSourceManager.h
//  verbatim
//
//  Created by Nicolas Halper on 4/6/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBInputSourceManager : NSObject

// notifications you can subscribe to
extern NSString *const VBInputSourceManagerDidFinishWithResultsNotification;

+ (instancetype)manager;

- (void)startListening;

@end
