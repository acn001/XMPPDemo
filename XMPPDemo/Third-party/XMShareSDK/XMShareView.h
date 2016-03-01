//
//  XMShareView.h
//  XMShareSDKTest
//
//  Created by liuzuopeng01 on 15/9/8.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMShareDef.h"


/**
 * 当快速点击时，确保正在显示的分享面板只有一个，且是第一个
 */
extern BOOL panelIsShowing;


@class XMSharePanel;


#pragma mark - XMSharePanelDelegate
/**
 *  分享面板代理类
 */
@protocol XMSharePanelDelegate <NSObject>

@required
- (void)sharePanel:(XMSharePanel *)sharePanel didTapWithPlatformIndex:(NSUInteger)tappedIndex;

@end


/**
 *  分享面板
 */
@interface XMSharePanel : NSObject

@property (nonatomic, assign, readonly) XMSharePanelStyle panel;
@property (nonatomic, strong, readonly) NSArray<NSString *> *platforms;
@property (nonatomic, strong, readonly) XMShareObject *shareObject;
@property (nonatomic, strong, readonly) XMShareView *containerView;
@property (nonatomic, copy)   XMShareOperationCompletionHandler completionHandler;
@property (nonatomic, weak)   id<XMSharePanelDelegate> delegate;

@property (nonatomic, strong) UIColor *alphaColor; // 分享面板的蒙层颜色

+ (BOOL)isShowing;
+ (XMSharePanel *)sharePanelWithStyle:(XMSharePanelStyle)style;
+ (XMSharePanel *)sharePanelWithStyle:(XMSharePanelStyle)style displayedPlatforms:(NSArray<NSString *> *)platforms shareObject:(XMShareObject *)shareObject;

- (void)setWillBeDisplayedPlatforms:(NSArray<NSString *> *)platforms shareObject:(XMShareObject *)aObject;
- (void)showWithCompletionHandler:(XMAnimationCompletionHandler)animationCompletionHandler;
- (void)dismissWithCompletionHandler:(XMAnimationCompletionHandler)animationCompletionHandler;

@end



#pragma mark - XMShareViewDelegate
/**
 *  分享视图代理类
 */
@protocol XMShareViewDelegate <NSObject>

@required
- (void)shareView:(XMShareView *)aView didTapWithPlatformIndex:(NSUInteger)tappedIndex;
- (void)shareView:(XMShareView *)aView didTapCancelButton:(UIButton *)tappedButton;

@end


/**
 *  分享视图基类，显示所有的分享平台
 */
@interface XMShareView : UIView

@property (nonatomic, strong, readonly) NSArray<NSString *> *platforms;
@property (nonatomic, weak)   id<XMShareViewDelegate> delegate;

+ (XMShareView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms;

- (void)setWillBeDisplayedPlatforms:(NSArray<NSString *> *)platforms;

@end



/**
 *  默认的分享视图定义
 */
@interface XMSDefaultView : XMShareView

+ (XMSDefaultView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms;

@end



/**
 *  可滚动的分享视图定义
 */
@interface XMSLineScrollView : XMShareView

+ (XMSLineScrollView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms;

@end



/**
 *  多行单个平台的分享视图定义
 */
@interface XMSLineToOneView : XMShareView

+ (XMSLineToOneView *)shareViewWithPlatforms:(NSArray<NSString *> *)platforms;

@end
