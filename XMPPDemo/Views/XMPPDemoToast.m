//
//  XMPPDemoToast.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoToast.h"
#import "AppDelegate.h"
#import "UIColor+XMPPDemo.h"
#import "UILabel+XMPPDemo.h"
#import "XMPPDemoFont.h"

@implementation XMPPDemoToast

static UIWindow *toastWindow;
static NSInteger toastId;

+ (void)showToastWithMessage:(NSString *)message {
    [self showToastWithMessage:message durationType:TOAST_DURATION_SHORT];
}

+ (void)showToastWithMessage:(NSString *)message durationType:(ToastDurationType)durationType {
    if ([NSThread isMainThread]) {
        [self doShowToastWithMessage:message durationType:durationType];
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self doShowToastWithMessage:message durationType:durationType];
        }];
    }
}

+ (void)doShowToastWithMessage:(NSString *)message durationType:(ToastDurationType)durationType {
    if (![(AppDelegate *)[[UIApplication sharedApplication] delegate] isForeground]) {
        return;
    }
    if (toastWindow == nil) {
        [self createToastWindow];
    }
    
    // fix for iOS7 bug, window' height will become to 0 when
    // UIImagePickerController shows
    if (toastWindow.bounds.size.height == 0) {
        const CGFloat TOAST_VIEW_HEIGHT = 64.0;
        toastWindow.frame = CGRectMake(0, -TOAST_VIEW_HEIGHT, [UIScreen mainScreen].bounds.size.width, TOAST_VIEW_HEIGHT);
    }
    
    ++toastId;
    NSInteger currentToastId = toastId;
    if (![self isToastShowing]) {
        [self setMessage:message];
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = toastWindow.frame;
            frame.origin.y += frame.size.height;
            toastWindow.frame = frame;
        } completion:^(BOOL finished) {
            if (durationType != TOAST_DURATION_FOREVER) {
                [self.class performSelector:@selector(dismissToastWithId:) withObject:@(currentToastId) afterDelay:[self timeIntervalForDurationType:durationType]];
            }
        }];
    } else {
        [self setMessage:message];
        [self.class performSelector:@selector(dismissToastWithId:) withObject:@(currentToastId) afterDelay:[self timeIntervalForDurationType:durationType]];
    }
}

+ (void)setMessage:(NSString *)message {
    UILabel *label = (UILabel *)[toastWindow viewWithTag:10];
    label.text = message;
}

+ (BOOL)isToastShowing {
    return toastWindow != nil && toastWindow.frame.origin.y == 0;
}

+ (void)createToastWindow {
    const CGFloat TOAST_VIEW_HEIGHT = 64.0;
    toastWindow = [[UIWindow alloc]
                   initWithFrame:CGRectMake(0, -TOAST_VIEW_HEIGHT, [UIScreen mainScreen].bounds.size.width, TOAST_VIEW_HEIGHT)];
    toastWindow.backgroundColor = XMPPDEMO_COLOR_BLACK;
    
    // message label
    const CGFloat LABEL_TOP_Y = 20.0;
    const CGFloat LABEL_HORIZONTAL_MARGIN = 45;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_HORIZONTAL_MARGIN, LABEL_TOP_Y, toastWindow.bounds.size.width - 2 * LABEL_HORIZONTAL_MARGIN, TOAST_VIEW_HEIGHT - LABEL_TOP_Y)];
    label.backgroundColor = [UIColor clearColor];
    [label setXMPPDemoFont:[XMPPDemoFont wb14]];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.tag = 10;
    [toastWindow addSubview:label];
    
    // close button
    UIImage *normalCloseImage = [UIImage imageNamed:@"toast_close_normal"];
    UIImage *highlightedCloseImage = [UIImage imageNamed:@"toast_close_active"];
    const CGFloat CLOSE_BUTTON_RIGHT_MARGIN = 10;
    const CGFloat CLOSE_BUTTON_TOP_Y = LABEL_TOP_Y;
    const CGFloat CLOSE_BUTTON_WIDTH = normalCloseImage.size.width + 2 * CLOSE_BUTTON_RIGHT_MARGIN;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(toastWindow.bounds.size.width - CLOSE_BUTTON_WIDTH, CLOSE_BUTTON_TOP_Y, CLOSE_BUTTON_WIDTH, TOAST_VIEW_HEIGHT - CLOSE_BUTTON_TOP_Y)];
    [button setImage:normalCloseImage forState:UIControlStateNormal];
    [button setImage:highlightedCloseImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(toastCloseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [toastWindow addSubview:button];
    
    toastWindow.hidden = NO;
    toastWindow.clipsToBounds = YES;
    toastId = 0;
}

+ (void)dissmissCurrentToast {
    [self dismissToastWithId:@(toastId)];
}

+ (void)toastCloseButtonClicked {
    [self dismissToastWithId:@(toastId)];
}

+ (void)dismissToastWithId:(NSNumber *)dismissToastId {
    NSLog(@"dismissToastId=%@", dismissToastId);
    if (dismissToastId.longLongValue == toastId && [self isToastShowing]) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = toastWindow.frame;
            frame.origin.y -= frame.size.height;
            toastWindow.frame = frame;
        } completion:nil];
    }
}

+ (NSTimeInterval)timeIntervalForDurationType:(ToastDurationType)durationType {
    switch (durationType) {
        case TOAST_DURATION_SHORT:
            return 2;
        case TOAST_DURATION_LONG:
            return 5;
        case TOAST_DURATION_FOREVER:
            return 24.0 * 60.0 * 60.0;
        default:
            return 0;
    }
}

@end
