//
//  BTMToast.h
//  BaiduTuanMerchant
//
//  Created by 吴江伟 on 14-3-17.
//  Copyright (c) 2013年 ShiTuanwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTMToast : UIView
{
    @private 
    UILabel *_label;
    BOOL _stoped;
    BOOL _refreshed;
    NSTimeInterval  _duration;
}

- (void)showToast:(NSString *)message inView:(UIView *)superView;
- (void)showToast:(NSString *)message inView:(UIView *)superView centerOffY:(CGFloat)centerOffY;

//windows
- (void)showToast:(NSString *)message;
- (void)showToast:(NSString *)message centerOffY:(CGFloat)centerOffY;
- (void)showToast:(NSString *)message atY:(CGFloat)atY duration:(NSTimeInterval)duration;
- (void)showBalanceRechargeToast:(NSString *)message;

+ (id)sharedInstance;

@end
