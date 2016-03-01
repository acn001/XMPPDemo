//
//  XMShareManager.h
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMShareDef.h"


/**
 *  分享SDK的管理器
 */
@interface XMShareManager : NSObject

/**
 *  分享面板的透明度
 */
@property (nonatomic, strong) UIColor *alphaColor;


/**
 *  分享面板的背景色
 */
@property (nonatomic, strong) UIColor *backgroundColor;


/**
 *  分享面板的背景图片，默认为空，可配置
 */
@property (nonatomic, strong) UIImage *backgroundImage;


/**
 * 分享面板的文字颜色
 */
@property (nonatomic, strong) UIColor *textColor;


/**
 *  分享SDK管理器单例
 *
 *  @return 分享管理器实例
 */
+ (XMShareManager *)sharedManager;


/**
 *  注册所有分享渠道的appID
 * 
 *  @return 所有成功注册返回YES，否则返回NO
 */
+ (BOOL)registerChannelAppId;


/**
 *  注册指定的分享渠道
 *
 *  @param appID   appID键
 *  @param channel 渠道类型
 *
 *  @return 成功返回YES，否则返回NO
 */
- (BOOL)registerAppID:(NSString *)appID forChannel:(XMShareChannelType)channel;


/**
 *  打开指定的url，仅仅处理分享回调并过滤其他类型回调
 *
 *  @param url  待打开的url
 *
 *  @return 是否能打开url的状态
 */
- (BOOL)handleOpenURL:(NSURL *)url;


/**
 *  开放微博h5页面授权分享。打开该选项后，当没有安装微博时，将使用内嵌的页面进行授权和分享
 *
 *  @param opened 是否打开
 */
- (void)openWBAuthShare:(BOOL)opened;

@end




@interface XMShareManager (XMSharePanel)

/**
 *  返回分享面板视图
 *
 *  @param panel       面板类型
 *  @param shareObject 将分享的内容
 *  @param platforms   分享面板上所有的分享平台
 *
 *  @return 显示某类型面板的视图
 */
- (XMShareView *)shareViewWithPanel:(XMSharePanelStyle)panel shareObject:(XMShareObject *)shareObject platforms:(NSArray<NSString *> *)platforms;


/**
 *  调起分享面板
 *
 *  @param panel             面板类型
 *  @param shareObject       将分享的内容
 *  @param platforms         配置本次分享面板上的平台，包括所有（第三方和通用）的平台
 *  @param completionHandler 分享结束后的回调块，可以为空
 */
- (void)showWithPanel:(XMSharePanelStyle)panel shareObject:(XMShareObject *)shareObject platforms:(NSArray<NSString *> *)platforms completionHandler:(XMShareOperationCompletionHandler)completionHandler;


/**
 *  调起分享面板
 *      显示分享平台的策略如下：
 *          1）若提供了平台参数，则使用配置的平台
 *          2）若没提供平台参数，但在代理类XMShareDelegate中设置了defaultPlatforms，则使用该平台
 *          3）若没有提供平台参数并且没有在代理中设置平台，则使用默认的平台
 *
 *  @param shareObject       将分享的内容
 *  @param platforms         配置本次分享面板上的平台，包括所有（第三方和通用）的平台
 *  @param completionHandler 分享结束后的回调块，可以为空
 */
- (void)showWithShareObject:(XMShareObject *)shareObject platforms:(NSArray<NSString *> *)platforms completionHandler:(XMShareOperationCompletionHandler)completionHandler;


/**
 *  调起分享面板，使用默认的分享平台
 *
 *  @param shareObject       将分享的内容
 *  @param completionHandler 分享结束后的回调代码块，可以为空
 */
- (void)showWithShareObject:(XMShareObject *)shareObject completionHandler:(XMShareOperationCompletionHandler)completionHandler;


/**
 *  手动关闭分享面板
 */
- (void)closeSharePanel;

@end


@interface XMShareManager (SSOAuthLogin)
- (void)weixinSSOWithResponse:(XMSSOResponseHandler)respBlock;
@end