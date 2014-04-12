//
//  VBHUD.m
//  verbatim
//
//  Created by Nicolas Halper on 4/12/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBHUD.h"
#import "MBProgressHUD.h"

@interface VBHUD()

@property (nonatomic, strong) MBProgressHUD *hud;


@end

@implementation VBHUD

+ (instancetype)instance {
    static id _vbhud = nil;
    static dispatch_once_t _predicate;
    dispatch_once(&_predicate, ^{
        _vbhud = [[self alloc] init];
    });
    
    return _vbhud;
}

// we lazy instantiate the hud since we want to be sure view's have been loaded before getting the window.
- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES];
    }
    return _hud;
}

+(void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [VBHUD instance].hud;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud show:YES];
    if (delay>0) {
        [hud hide:YES afterDelay:delay];
    }
}

+(void)showWithText:(NSString *)text
{
    [VBHUD showWithText:text hideAfterDelay:0];
}

+(void)showWithError:(NSError*)error
{
    [VBHUD showWithText:error.localizedDescription];
}

+(void)hide {
    MBProgressHUD *hud = [VBHUD instance].hud;
    [hud hide:YES];
}

+(NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

@end
