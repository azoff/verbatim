//
//  VBSourcesTitleView.h
//  verbatim
//
//  Created by Chris Ahlering on 4/13/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBMenuNavigationState.h"

@interface VBSourcesTitleView : UIView

@property (nonatomic, weak) id<VBMenuNavigationState> delegate;

@property (weak, nonatomic) NSString *locationName;
@property (weak, nonatomic) NSString *sourceName;
@end
