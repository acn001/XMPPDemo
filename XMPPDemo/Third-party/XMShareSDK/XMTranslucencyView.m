//
//  XMPopUpView.m
//  BaiduNuomiTuan
//
//  Created by liuzuopeng01 on 15/8/21.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import "XMTranslucencyView.h"
#import "XMShareView.h"


/**
 *  Extension Of XMTranslucencyView
 */
@interface XMTranslucencyView ()

@property (nonatomic, strong) UITapGestureRecognizer *selfTapGesture;
/**
 * 动画状态进行中标识，防止快速点击，上一个点击中的动画由于异步处理尚未完成，又开始响应下一个点击事件
 */
@property (nonatomic, assign) XMShareAnimationProgress animationProgress;

@end


/**
 *  Implementation Of XMTranslucencyView
 */
@implementation XMTranslucencyView

- (instancetype)init
{
    if ((self = [super init])) {
        self.frame = [UIScreen mainScreen].bounds;
        self.animationProgress = kXMShareAnimationNone;
        self.backgroundColor = kXMTranslucencyViewDefaultBackgroundColor;
        [self addGestures];
    }
    return self;
}


- (void)dealloc
{
    [self removeGestures];
}


#pragma mark - gesture

- (void)addGestures
{
    [self removeGestures];
    [self addGestureRecognizer:self.selfTapGesture];
}


- (void)removeGestures
{
    if (_selfTapGesture) {
        [self removeGestureRecognizer:_selfTapGesture];
    }
}


#pragma mark - show and dismiss view

- (void)show
{
    [self showWithCompletionHandler:nil];
}


- (void)showWithCompletionHandler:(XMAnimationCompletionHandler)completionHandler
{
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    [self _showTransluencyViewInView:appDelegate.window animated:YES completion:completionHandler];
}


- (void)dismiss
{
    [self dismissWithCompletionHandler:nil];
}


- (void)dismissWithCompletionHandler:(XMAnimationCompletionHandler)completionHandler
{
    [self _dismissTranslucencyViewWithAnimation:YES completionHandler:completionHandler];
}


#pragma mark - private method for show/hidden

- (void)_showTransluencyViewInView:(UIView *)view animated:(BOOL)animated completion:(XMAnimationCompletionHandler)completionHandler
{
    if (!view) {
        XM_SHARE_LOG(@"view is nil");
        return;
    }
    if (![view isKindOfClass:[UIWindow class]]) {
        XM_SHARE_LOG(@"view is not the instance of UIWindow");
        return;
    }
    
    if (self.superview == view) {
        [self removeFromSuperview];
    }
    [view addSubview:self];
    
    self.hidden = NO;
    self.frame = [[UIScreen mainScreen] bounds];
    if (animated) {
        self.alpha = 0.3f;
        self.animationProgress = kXMShareAnimationBegin;
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.alpha = 1.f;
            strongSelf.animationProgress = kXMShareAnimationIng;
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (completionHandler) {
                completionHandler(finished);
            }
            strongSelf.animationProgress = kXMShareAnimationNone;
        }];
    } else {
        self.alpha = 1.f;
        if (completionHandler) {
            completionHandler(YES);
        }
    }
}


- (void)_dismissTranslucencyViewWithAnimation:(BOOL)animated completionHandler:(XMAnimationCompletionHandler)completionHandler
{
    if (animated) {
        self.alpha = 0.5f;
        self.animationProgress = kXMShareAnimationBegin;
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.1 animations:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.alpha = 0.f;
            strongSelf.animationProgress = kXMShareAnimationIng;
        } completion:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.hidden = YES;
            [strongSelf removeFromSuperview];
            if (completionHandler) {
                completionHandler(finished);
            }
            strongSelf.animationProgress = kXMShareAnimationNone;
        }];
    } else {
        self.alpha = 0.f;
        self.hidden = YES;
        [self removeFromSuperview];
    }
    
    panelIsShowing = NO;
}


#pragma mark - getter/setter property

- (UITapGestureRecognizer *)selfTapGesture
{
    if (!_selfTapGesture) {
        _selfTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSelfView:)];
        _selfTapGesture.numberOfTapsRequired = 1;
        _selfTapGesture.numberOfTouchesRequired = 1;
    }
    
    return _selfTapGesture;
}


#pragma mark - action

- (void)didTapSelfView:(UITapGestureRecognizer *)sender
{
    if ([self isAnimating]) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(translucencyView:didTapGuesture:)]) {
        [self.delegate translucencyView:self didTapGuesture:sender];
    } else {
        [self dismissWithCompletionHandler:nil];
    }
}


#pragma mark - animation

- (BOOL)isAnimating {
    return (self.animationProgress != kXMShareAnimationNone);
}

@end
