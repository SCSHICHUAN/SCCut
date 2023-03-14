//
//  SVProgressHUD+SChud.m
//  SCCut
//
//  Created by Stan on 2023/3/7.
//

#import "SVProgressHUD+SChud.h"

@implementation SVProgressHUD (SChud)

+ (void)showMessage:(NSString *)message
{
    if (message && ![message containsString:@"null"]) {
        // --修改
        [SVProgressHUD setForegroundColor:[BlackColor colorWithAlphaComponent:0.1f]];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setCornerRadius:5.f];
        
        [SVProgressHUD setInfoImage:[UIImage imageNamed:@""]];
        [SVProgressHUD showInfoWithStatus:message];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD dismissWithDelay:1.5];
    }
}


+ (void)showLondingMessage:(NSString *)message
{
    // --修改
    [SVProgressHUD setForegroundColor:[BlackColor colorWithAlphaComponent:0.1f]];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setCornerRadius:5.f];
    
    [SVProgressHUD showWithStatus:message];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}


@end
