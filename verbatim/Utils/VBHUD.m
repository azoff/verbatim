//
//  VBHUD.m
//  verbatim
//
//  Created by Nicolas Halper on 4/12/14.
//  Copyright (c) 2014 Verbatim. All rights reserved.
//

#import "VBHUD.h"
#import "VBFont.h"
#import "MBProgressHUD.h"
#import "UIImage+Overlay.h"

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
        _hud.labelFont = [VBFont defaultFontWithSize:17];
    }
    return _hud;
}

+ (void)showIndeterminateProgress
{
    [self showIndeterminateProgressWithText:nil];
}

+ (void)showIndeterminateProgressWithText:(NSString *)text
{
    MBProgressHUD *hud = [VBHUD instance].hud;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = text;
    [hud show:YES];
}

+ (void)showDoneWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hud = [VBHUD instance].hud;
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *done = [[UIImage imageNamed:@"checkmark"] imageByApplyingOverlayColor:[VBColor translucsentTextColor]];
    UIImageView *image = [[UIImageView alloc] initWithImage:done];
    image.frame = CGRectMake(0, 0, 24, 24);
    hud.customView = image;
    hud.labelText = text;
    [hud show:YES];
    if (delay>0)
        [self hideAfterDelay:delay];
}

+(void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay
{
    if (text == nil || text.length <= 0) return;
    MBProgressHUD *hud = [VBHUD instance].hud;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud show:YES];
    if (delay>0)
        [self hideAfterDelay:delay];
}

+(void)showWithText:(NSString *)text
{
    [VBHUD showWithText:text hideAfterDelay:0];
}

+(void)showWithError:(NSError*)error
{
    [VBHUD showWithText:error.localizedDescription hideAfterDelay:5];
}

+(void)hide {
    [self hideAfterDelay:0];
}

+(void)hideAfterDelay:(NSTimeInterval)delay {
    [[VBHUD instance].hud hide:YES afterDelay:delay];
}


@end
