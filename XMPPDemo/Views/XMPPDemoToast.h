//
//  XMPPDemoToast.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ToastDurationType) {
    TOAST_DURATION_SHORT = 0,
    TOAST_DURATION_LONG,
    TOAST_DURATION_FOREVER,
};

@interface XMPPDemoToast : NSObject

+ (void)showToastWithMessage:(NSString *)message;
+ (void)showToastWithMessage:(NSString *)message durationType:(ToastDurationType)durationType;
+ (void)dissmissCurrentToast;

@end
