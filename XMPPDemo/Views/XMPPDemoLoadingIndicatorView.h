//
//  XMPPDemoLoadingIndicatorView.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XMPPDemoLoadingIndicatorViewStyle) {
    XMPPDemoLoadingIndicatorViewStyleNormal,
    XMPPDemoLoadingIndicatorViewStyleModal,
};

@interface XMPPDemoLoadingIndicatorView : UIView

@property(nonatomic, assign, readonly) XMPPDemoLoadingIndicatorViewStyle style;
/**
 *  Only valid for LcLoadingIndicatorViewStyleNormal.
 */
@property(nonatomic, assign) BOOL white;

+ (XMPPDemoLoadingIndicatorView *)loadingIndicatorViewWithSytle:(XMPPDemoLoadingIndicatorViewStyle)style;

- (void)show;
- (void)hide;

+ (void)showNormal:(BOOL)white;
+ (void)hideNormal;
+ (void)showModal;
+ (void)hideModal;

@end
