//
//  XMPPDemoLoadingIndicatorView.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoLoadingIndicatorView.h"
#import "UIColor+XMPPDemo.h"
#import "NSDate+XMPPDemo.h"

@interface XMPPDemoLoadingIndicatorView ()

@property (nonatomic, weak) UIActivityIndicatorView *progressView;
@property (nonatomic, assign) long long modalLoadingIndicatorViewStartShowingTime;

@end

@implementation XMPPDemoLoadingIndicatorView

+ (XMPPDemoLoadingIndicatorView *)loadingIndicatorViewWithSytle:(XMPPDemoLoadingIndicatorViewStyle)style {
    if (style == XMPPDemoLoadingIndicatorViewStyleNormal) {
        return [self createNormalLoadingIndicatorView];
    } else if (style == XMPPDemoLoadingIndicatorViewStyleModal) {
        return [self createModalLoadingIndicatorView];
    } else {
        return nil;
    }
}

+ (XMPPDemoLoadingIndicatorView *)createNormalLoadingIndicatorView {
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    XMPPDemoLoadingIndicatorView *loadingIndicatorView = [[self alloc] initWithFrame:progressView.bounds];
    loadingIndicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height * 2.0 / 5.0);
    loadingIndicatorView.userInteractionEnabled = NO;
    loadingIndicatorView.hidden = YES;
    [loadingIndicatorView addSubview:progressView];
    loadingIndicatorView.progressView = progressView;
    loadingIndicatorView->_style = XMPPDemoLoadingIndicatorViewStyleNormal;
    return loadingIndicatorView;
}

+ (XMPPDemoLoadingIndicatorView *)createModalLoadingIndicatorView {
    XMPPDemoLoadingIndicatorView *loadingIndicatorView = [[self alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    loadingIndicatorView.backgroundColor = [XMPPDEMO_COLOR_BLACK colorWithAlphaComponent:0.3];
    loadingIndicatorView.userInteractionEnabled = YES;
    loadingIndicatorView.alpha = 0;
    loadingIndicatorView.hidden = YES;
    
    UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    const CGFloat BACKGROUND_VIEW_SIZE = 80.0;
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BACKGROUND_VIEW_SIZE, BACKGROUND_VIEW_SIZE)];
    backgroundView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height * 2.0 / 5.0);
    backgroundView.backgroundColor = [XMPPDEMO_COLOR_BLACK colorWithAlphaComponent:0.9];
    backgroundView.layer.cornerRadius = 12;
    backgroundView.layer.masksToBounds = YES;
    progressView.center = CGPointMake(BACKGROUND_VIEW_SIZE / 2.0, BACKGROUND_VIEW_SIZE / 2.0);
    [backgroundView addSubview:progressView];
    
    [loadingIndicatorView addSubview:backgroundView];
    loadingIndicatorView.progressView = progressView;
    loadingIndicatorView->_style = XMPPDemoLoadingIndicatorViewStyleModal;
    return loadingIndicatorView;
}

- (void)show {
    if (self.style == XMPPDemoLoadingIndicatorViewStyleNormal) {
        self.progressView.activityIndicatorViewStyle = self.white ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
    }
    [self.progressView startAnimating];
    self.hidden = NO;
    if (self.style == XMPPDemoLoadingIndicatorViewStyleNormal) {
    } else {
        self.modalLoadingIndicatorViewStartShowingTime = [NSDate currentTimeMillis];
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0;
        }];
    }
}

- (void)hide {
    if (self.style == XMPPDemoLoadingIndicatorViewStyleNormal) {
        [self.progressView stopAnimating];
        self.hidden = YES;
    } else {
        const int64_t MIN_SHOWING_TIME = 350;
        int64_t elapsed = [NSDate currentTimeMillis] - self.modalLoadingIndicatorViewStartShowingTime;
        if (elapsed < MIN_SHOWING_TIME && elapsed >= 0) {
            NSTimeInterval delay = (MIN_SHOWING_TIME - elapsed) / 1000.0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    self.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.progressView stopAnimating];
                    self.hidden = YES;
                    self.window.hidden = YES;
                }];
            });
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self.progressView stopAnimating];
                self.hidden = YES;
                self.window.hidden = YES;
            }];
        }
    }
}

static XMPPDemoLoadingIndicatorView *_normalLoadingIndicatorView;
static XMPPDemoLoadingIndicatorView *_modalLoadingIndicatorView;
static UIWindow *window;
static UIWindow *modalWindow;

+ (void)showNormal:(BOOL)white {
    if (window == nil) {
        window = [UIApplication sharedApplication].windows[0];
    }
    if (_normalLoadingIndicatorView == nil) {
        _normalLoadingIndicatorView = [XMPPDemoLoadingIndicatorView loadingIndicatorViewWithSytle:XMPPDemoLoadingIndicatorViewStyleNormal];
        [window addSubview:_normalLoadingIndicatorView];
    }
    [window bringSubviewToFront:_normalLoadingIndicatorView];
    _normalLoadingIndicatorView.white = white;
    [_normalLoadingIndicatorView show];
}

+ (void)hideNormal {
    if (_normalLoadingIndicatorView != nil) {
        [_normalLoadingIndicatorView hide];
    }
}

+ (void)showModal {
    if (modalWindow == nil) {
        [self createModalWindow];
    }
    if (_modalLoadingIndicatorView == nil) {
        _modalLoadingIndicatorView = [XMPPDemoLoadingIndicatorView loadingIndicatorViewWithSytle:XMPPDemoLoadingIndicatorViewStyleModal];
        [modalWindow addSubview:_modalLoadingIndicatorView];
    }
    modalWindow.hidden = NO;
    [_modalLoadingIndicatorView show];
}

+ (void)hideModal {
    if (_modalLoadingIndicatorView != nil) {
        [_modalLoadingIndicatorView hide];
    }
}

+ (void)createModalWindow {
    modalWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    modalWindow.windowLevel = UIWindowLevelAlert;
}

@end
