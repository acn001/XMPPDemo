//
//  BTMToast.m
//  BaiduTuanMerchant
//
//  Created by 吴江伟 on 14-3-17.
//  Copyright (c) 2013年 ShiTuanwei. All rights reserved.
//

#import "BTMToast.h"
#import <QuartzCore/QuartzCore.h>

#define kToastFont [UIFont systemFontOfSize:15.0f]
#define kHudFont  [UIFont systemFontOfSize:13.f]
#define kHudHorizontalPadding       24.0
#define kHorizontalPadding          20.0
#define kVerticalPadding            10.0
#define kCornerRadius               8.0

#define kMaxLines                   (3)
#define kMaxWidth                   ([UIScreen mainScreen].bounds.size.width * 0.75)
#define kMaxHeight                  (kMaxWidth * 0.4)
#define kHudWidth                   ([UIScreen mainScreen].bounds.size.width)
#define kHudHeight                  30

#define kFadeDuration               0.3
#define kOpacity                    0.8
#define kHudOpacity                 0.5

@implementation BTMToast

#pragma mark - 
#pragma mark - Singleton Stuff

static BTMToast *_instance = nil;

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    }
    
    return _instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (!_instance) {
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    }
    
    return nil;   
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kOpacity];
        self.layer.cornerRadius = kCornerRadius;
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:6.0];
        [self.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
        
        UILabel *label = [[UILabel alloc] init];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:kToastFont];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:kMaxLines];
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:label];
        _label = label;
        _stoped = YES;
        _refreshed = NO;
    }
    return self;
}

- (void)startAnimate
{   
    [UIView beginAnimations:@"fade_in" context:( void*)self];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self setAlpha:kOpacity];
    [UIView commitAnimations];
}

- (void)startHudAnimate {
    [UIView beginAnimations:@"fade_in" context:( void*)self];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self setAlpha:kHudOpacity];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
}

- (void)showToast:(NSString *)message inView:(UIView *)superView
{
    [self showToast:message inView:superView centerOffY:0];
}

- (void)showToast:(NSString *)message inView:(UIView *)superView centerOffY:(CGFloat)centerOffY
{
    if ([self isToastMessageEqual:message]) {
        return;
    }
    
    CGSize text_size = [message sizeByNuomiFont:kToastFont constrainedToSize:CGSizeMake(kMaxWidth, kMaxHeight) lineBreakMode:_label.lineBreakMode];
    [_label setText:message];
    [_label setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, text_size.width, text_size.height)];
    [self setFrame:CGRectMake(0.0f, 0.0f, text_size.width + kHorizontalPadding * 2, text_size.height + kVerticalPadding * 2)];
    self.center = CGPointMake(superView.frame.size.width / 2, superView.frame.size.height/2 - self.frame.size.height / 2 - kVerticalPadding + centerOffY);
    
    if (_stoped) {
        [self setAlpha:0.0f];
        self.hidden = NO;
        _stoped = NO;
        [superView addSubview:self];
    }else{
        _refreshed = YES;
    }
    
    [self startAnimate];
}


- (void)showToast:(NSString *)message {
    UIView *keywindow = [UIApplication sharedApplication].keyWindow;
    _duration = 2.0f;
    [[BTMToast sharedInstance] showToast:message centerOffY:(CGRectGetHeight(keywindow.bounds) * 0.12)];
}

- (void)showBalanceRechargeToast:(NSString *)message {
    UIView *keywindow = [UIApplication sharedApplication].keyWindow;
    _duration = 3.0f;
    [[BTMToast sharedInstance] showToast:message centerOffY:(CGRectGetHeight(keywindow.bounds) * 0.12)];
}

- (BOOL)isToastMessageEqual:(NSString *)newMessage
{
    return [_label.text isEqualToString:newMessage] && !_stoped;
}

- (void)showToast:(NSString *)message atY:(CGFloat)atY duration:(NSTimeInterval)duration {
    _duration = duration;
    [[BTMToast sharedInstance] showHud:message centerOffY:atY];
}

//新增hud显示
- (void)showHud:(NSString *)message centerOffY:(CGFloat)centerOffY {
    
    if ([self isToastMessageEqual:message]) {
        return;
    }
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    self.alpha = 0.5f;
    self.layer.cornerRadius = 0;
    [self.layer setShadowOpacity:0];
    [self.layer setShadowRadius:0];
    
    UIWindow *superView = [[UIApplication sharedApplication] keyWindow];
    
    _label.textAlignment = NSTextAlignmentLeft;
    _label.numberOfLines = 0;
    
    [_label setText:message];
    [_label setFont:kHudFont];
    [_label setFrame:CGRectMake(kHorizontalPadding , 0, kHudWidth, kHudHeight)];
    [self setFrame:CGRectMake(0.0f, 0.0f, kHudWidth,  kHudHeight)];
    self.center = CGPointMake(superView.frame.size.width / 2, centerOffY + kHudHeight / 2.0);//superView.frame.size.height/2 - self.frame.size.height / 2 - kVerticalPadding - 55.0f + centerOffY);
    _label.frame = CGRectMake(12, CGRectGetMinY(_label.frame), CGRectGetWidth(_label.frame), CGRectGetHeight(_label.frame));
    
    if (_stoped) {
        [self setAlpha:0.0f];
        self.hidden = NO;
        _stoped = NO;
        [superView addSubview:self];
    }else{
        _refreshed = YES;
    }
    [self startHudAnimate];
}

- (void)showToast:(NSString *)message centerOffY:(CGFloat)centerOffY {
    
    if ([self isToastMessageEqual:message]) {
        return;
    }
    
    UIWindow *superView = [[UIApplication sharedApplication] keyWindow];
    
    CGSize text_size = [message sizeByNuomiFont:kToastFont constrainedToSize:CGSizeMake(kMaxWidth, kMaxHeight) lineBreakMode:_label.lineBreakMode];
    [_label setText:message];
    [_label setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, text_size.width, text_size.height)];
    [self setFrame:CGRectMake(0.0f, 0.0f, text_size.width + kHorizontalPadding * 2, text_size.height + kVerticalPadding * 2)];
    self.center = CGPointMake(superView.frame.size.width / 2, superView.frame.size.height/2 - self.frame.size.height / 2 - kVerticalPadding - 55.0f + centerOffY);
    
    if (_stoped) {
        [self setAlpha:0.0f];
        self.hidden = NO;
        _stoped = NO;
        [superView addSubview:self];
    }else{
        _refreshed = YES;
    }
    [self startAnimate];
}

#pragma mark - Animation Delegate Method

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context
{    
    UIView *toast = (__bridge UIView *)context;
    
    if([animationID isEqualToString:@"fade_in"]) {
        [UIView beginAnimations:@"fade_out" context:context];
        [UIView setAnimationDelay:_label.text.length > 10 ? 1.5 : 1.0];
        [UIView setAnimationDuration:kFadeDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDelay:_duration];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [toast setAlpha:0.0];
        [UIView commitAnimations];
    } 
    else if ([animationID isEqualToString:@"fade_out"]) {
        if (_refreshed) {
            //not remove because of refresh
            _refreshed = NO;
        }else{
            toast.hidden = YES;
            [toast removeFromSuperview];
            _stoped = YES;
            _label.textAlignment = NSTextAlignmentCenter;
            _label.numberOfLines = kMaxLines;
            [self.layer setShadowOpacity:0.8];
            [self.layer setShadowRadius:6.0];
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kOpacity];
            self.layer.cornerRadius = kCornerRadius;
            [_label setFont:kToastFont];
            self.alpha = 0;
        }
    }
}

@end
