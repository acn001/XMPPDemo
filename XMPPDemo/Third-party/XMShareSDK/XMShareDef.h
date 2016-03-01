//
//  XMShareDef.h
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApiObject.h"
#import "WXApi.h"
#import "WeiboSDK.h"

#import "AFNetworking.h"


#define kXMImageDirectoryName         (@"Images")
#define kXMPlatformIconsName          (@"PlatformIcons")
#define kXMPanelImagesName            (@"PanelImages")
#define kXMTableStringFileName        (@"XMShareTable")

#define kXMShareDefaultTitleKey       (@"XMShareDefaultTitle")
#define kXMShareDefaultContentKey     (@"XMShareDefaultContent")
#define kXMShareDefaultURLKey         (@"XMShareDefaultURL")
#define kXMShareDefaultThumbImageName (@"XMShareThumbnail")


/**
 *  所有预定义的分享平台的名称
 */
#define kXM_SHARE_PLATFORM_QQ_FRIEND         @"qq_friend"        // QQ好友
#define kXM_SHARE_PLATFORM_QQ_ZONE           @"qq_zone"          // QQ空间
#define kXM_SHARE_PLATFORM_WEIXIN_SESSION    @"weixin_session"   // 微信好友
#define kXM_SHARE_PLATFORM_WEIXIN_TIMELINE   @"weixin_timeline"  // 微信朋友圈
#define kXM_SHARE_PLATFORM_SINAWEIBO         @"sinaweibo"        // 新浪微博
#define kXM_SHARE_PLATFORM_BAIDUHI           @"baiduhi"          // 百度Hi
#define kXM_SHARE_PLATFORM_COPY_LINK         @"copylink"         // 复制链接
#define kXM_SHARE_PLATFORM_EMAIL             @"email"            // 邮件
#define kXM_SHARE_PLATFORM_SMS               @"sms"              // 短信
#define kXM_SHARE_PLATFORM_MORE_OPTIONS      @"more_options"     // 更多选项


#define kXMSharePlatformQQFriendImageName       (@"XMSharePlatformIcon_qq_friend")
#define kXMSharePlatformQQZoneImageName         (@"XMSharePlatformIcon_qq_zone")
#define kXMSharePlatformWeixinSessionImageName  (@"XMSharePlatformIcon_weixin_session")
#define kXMSharePlatformWeixinTimelineImageName (@"XMSharePlatformIcon_weixin_timeline")
#define kXMSharePlatformSinaWeiboImageName      (@"XMSharePlatformIcon_sinaweibo")
#define kXMSharePlatformBaiduHiImageName        (@"XMSharePlatformIcon_baiduhi")
#define kXMSharePlatformCopyLinkImageName       (@"XMSharePlatformIcon_copylink")
#define kXMSharePlatformSMSImageName            (@"XMSharePlatformIcon_sms")
#define kXMSharePlatformEmailImageName          (@"XMSharePlatformIcon_email")
#define kXMSharePlatformMoreOptionsImageName    (@"XMSharePlatformIcon_more_options")


/**
 *  错误消息内容key
 *  通常，在处理XMShareOperationCompletionHandler响应时，可以从error变量中获取这些字段内容
 *  Eg, To get error code:
 *      errCode = [[error.userInfo objectForKey:kXMShareErrorCodeKey] toInteger]
 */
extern NSString * const kXMSharePlatformKey;
extern NSString * const kXMShareErrorCodeKey;
extern NSString * const kXMShareErrorMessageKey;
extern NSString * const kXMShareErrorOtherMessageKey;
extern NSString * const kXMShareErrorDomainKey;


/**
 *  分享平台类型，需要多个分享平台是可用或操作
 */
typedef NS_ENUM(NSUInteger, XMSharePlatform){
    /**
     *  QQ好友
     */
    kXMSharePlatformQQFriend       = 1 << 0,
    /**
     *  QQ空间
     */
    kXMSharePlatformQQZone         = 1 << 1,
    /**
     *  微信好友
     */
    kXMSharePlatformWeixinSession  = 1 << 2,
    /**
     *  微信朋友圈
     */
    kXMSharePlatformWeixinTimeline = 1 << 3,
    /**
     *  新浪微博
     */
    kXMSharePlatformSinaWeibo      = 1 << 4,
    /**
     *  复制链接
     */
    kXMSharePlatformCopyLink       = 1 << 5,
    /**
     *  邮件
     */
    kXMSharePlatformEmail          = 1 << 6,
    /**
     *  短信
     */
    kXMSharePlatformSMS            = 1 << 7,
    /**
     *  百度Hi，目前不支持
     */
    kXMSharePlatformBaiduHi        = 1 << 8,
    /**
     *  更多选项，目前不支持
     */
    kXMSharePlatformMoreOptions    = 1 << 9,
    
    /**
     *  不被支持
     */
    kXMSharePlatformUnSupported    = 1 << 10,
};


/**
 *  第三方分享渠道
 */
typedef NS_ENUM(NSUInteger, XMShareChannelType){
    kXMShareChannelWeixin,
    kXMShareChannelQQ,
    kXMShareChannelSinaWeibo,
    kXMShareChannelBaiduHi,
    kXMShareChannelUnknown,
};


/**
 * 分享的结果状态码
 */
typedef NS_ENUM(NSUInteger, XMShareResultCode) {
    kXMShareSuccess  = 0,
    /**
     *  分享失败原因：参数超过平台限制；图片、网页URL地址打不开；网络问题分享超时；设备不支持；不支持的分享平台；
     */
    kXMShareFailed   = 1,
    kXMShareCanceled = 2,
};


/**
 * 分享面板的类型
 */
typedef NS_ENUM(NSUInteger, XMSharePanelStyle) {
    kXMSharePanelDefault      = 0, // 两行，每行包括四个分享平台，可包括多页
    kXMSharePanelLineScroll   = 1, // 两可滚动行，一行包括所有第三方平台，另一行为基本操作
    kXMSharePanelLineToOne    = 2, // 多行，每行包括一个分享平台
};


//#define XM_SHARE_LOG(fmt, ...)         do {  } while(NO)
//#define XM_SHARE_PLOG(errCode, errMsg) XM_SHARE_LOG(@"errCode = %ld, errMessage = %@", (long)errCode, errMsg)
//#define XM_SHARE_VLOG(errCode, errMsg, otherMsg) XM_SHARE_LOG(@"errCode = %ld, errMessage = %@, otherMessage = %@", (long)errCode, errMsg, otherMsg)

#define XM_SHARE_LOG(fmt, ...)  do { NSLog(@"<Source : shareSDK>\t" fmt, ##__VA_ARGS__); } while(NO)
#define XM_SHARE_PLOG(errCode, errMsg) NSLog(@"errCode = %ld, errMessage = %@", (long)errCode, errMsg)
#define XM_SHARE_VLOG(errCode, errMsg, otherMsg) NSLog(@"errCode = %ld, errMessage = %@, otherMessage = %@", (long)errCode, errMsg, otherMsg)

#define XM_IsNetworkReachability (([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWWAN) || ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi))


/**
 * 类的提前声明
 */
@class XMShareObject;
@class XMTranslucencyView;
@class XMShareView;
@class XMShareOperation;
@class XMShareManager;


// RGB颜色
#define UIColorFromRGB(_rgbValue)          ([UIColor colorWithRed:((float)((_rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((_rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(_rgbValue & 0xFF))/255.0 alpha:1.0])
#define UIColorFromRGBA(_rgbValue, _alpha) ([UIColor colorWithRed:((float)((_rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((_rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(_rgbValue & 0xFF))/255.0 alpha:_alpha])


/**
 *  分享结束后的回调函数
 *
 *  @param operation    具体的分享操作
 *  @param errcode      分享结果
 *  @param platformName 分享的具体平台
 *  @param response     返回的信息
 *  @param error        错误信息
 */
typedef void (^XMShareOperationCompletionHandler)(XMShareOperation *operation, XMShareResultCode errcode, NSString *platformName, NSDictionary *response, NSError *error);


// 分享面板回调代码块
typedef void (^XMAnimationCompletionHandler)(BOOL finished);


/**
 *  授权登陆响应类型
 */
@class XMSSOResponseObject;
typedef void (^XMSSOResponseHandler)(XMSSOResponseObject *respObject);



/**
 *  For Test
 */
//  分享平台app id & key
#define kXMShareWeixinAppID          (@"wxd2de02b9fa2bb9aa")
#define kXMShareWeixinAppSecret      (@"182692e89b09d5739eeea559646924b5")
#define kXMShareQQAppID              (@"100226131")
#define kXMShareWeiboAppID           (@"917898555")
#define kXMShareWeiboAppSecret       (@"8831899bde77f4047fa59e1677bcaa3f")
#define kXMShareRenRenAppID          (@"191476")
#define kXMShareRenRenSecretKey      (@"537c1c47ec134bffb97db24fbcd920ca")
#define kXMShareRenRenApiKey         (@"48f08bdfb44d42639e788f88fb056ab8")





