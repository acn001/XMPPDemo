//
//  XMShareOperation.h
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMShareDef.h"



/**
 *  处理分享到具体某个平台的操作
 */
@interface XMShareOperation : NSObject
<
WXApiDelegate,
QQApiInterfaceDelegate,
WeiboSDKDelegate
>

@property (nonatomic, assign, readonly)  BOOL isShareCtl;  //是否是分享操作
@property (nonatomic, assign, readwrite) BOOL canWBH5Auth; //是否开启微博h5授权分享
@property (nonatomic, assign, readwrite) BOOL canQQH5Auth; //是否开启QQh5授权分享
@property (nonatomic, strong, readonly)  XMShareObject *shareObject;
@property (nonatomic, assign, readonly)  XMShareChannelType channel;
@property (nonatomic, copy, readonly)    NSString *platformName; //当前的分享平台名称
@property (nonatomic, copy, readonly)    XMShareOperationCompletionHandler completionHandler; //分享完成响应句柄


/**
 *  获取某个分享操作实例
 *
 *  @param shareObject       待分享的内容
 *  @param completionHandler 分享完成后执行的代码块
 *
 *  @return 分享操作实例
 */
+ (XMShareOperation *)operationWithPlatform:(NSString *)platformName shareObject:(XMShareObject *)shareObject completionHandler:(XMShareOperationCompletionHandler)completionHandler;


/**
 *  获取授权登实例
 *
 *  @param handler        登陆响应回调
 *  @param viewController 发起的viewController, 可为nil
 *
 *  @return 授权登实例
 */
+ (XMShareOperation *)operationForChannel:(NSUInteger)channel SSOResponseHandler:(XMSSOResponseHandler)handler fromViewController:(UIViewController *)viewController;


- (void)commitSSOAuth;

/**
 *  显示下载图片进度并提交分享至某个指定的平台
 */
- (void)commitOperationWithProgressHUD:(BOOL)showHUD;

@end


