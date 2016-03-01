//
//  XMTranslucencyView.h
//  BaiduNuomiTuan
//
//  Created by liuzuopeng01 on 15/8/21.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMShareDef.h"


// define color
#define kXMTranslucencyViewDefaultBackgroundColor (UIColorFromRGBA(0x000000, 0.3))

typedef NS_ENUM(NSUInteger, XMShareAnimationProgress) {
    kXMShareAnimationNone,
    kXMShareAnimationBegin,
    kXMShareAnimationIng,
};


@class XMTranslucencyView;


/**
 *  XMTranslucencyViewDelegate
 */
@protocol XMTranslucencyViewDelegate <NSObject>

@optional
- (void)translucencyView:(UIView *)view didTapGuesture:(UITapGestureRecognizer *)tapGesture;

@end


/**
 *  XMTranslucencyView: 透明层视图、delegate处理透明层的点击事件
 */
@interface XMTranslucencyView : UIView

@property (nonatomic, weak) id<XMTranslucencyViewDelegate> delegate;

- (void)show;
- (void)showWithCompletionHandler:(XMAnimationCompletionHandler)completionHandler;
- (void)dismiss;
- (void)dismissWithCompletionHandler:(XMAnimationCompletionHandler)completionHandler;

@end
