//
//  XMShareOperation.h
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import <MessageUI/MessageUI.h>
#import <objc/runtime.h>
#import "XMShareOperation.h"
#import "XMShareManager.h"
#import "XMShareObject.h"
#import "MBProgressHUD.h"
#import "BTMToast.h"
#import "DDLog.h"
#import "XMSSOObject.h"



NSString * const kXMSharePlatformKey          = @"kXMSharePlatformKey";
NSString * const kXMShareErrorCodeKey         = @"kXMShareErrorCodeKey";
NSString * const kXMShareErrorMessageKey      = @"kXMShareErrorMessageKey";
NSString * const kXMShareErrorOtherMessageKey = @"kXMShareErrorOtherMessageKey";
NSString * const kXMShareErrorDomainKey       = @"kXMShareErrorDomainKey";


/**
 * 分享的错误码，仅供内部使用
 */
typedef NS_ENUM(NSUInteger, XMShareErrorCode) {
    kXMErrorCodeSuccess                    = 0,  //分享成功
    kXMErrorCodeFailed                     = 1,  //分享失败
    kXMErrorCodeCanceled                   = 2,  //分享取消
    kXMErrorCodeAuthDeny                   = 3,  //认证失败
    kXMErrorCodeParametersInvalid          = 4,  //参数不合法
    kXMErrorCodeDeviceUnSupported          = 5,  //设备不支持该分享功能（如模拟器上不能分享，没有配置邮件不能邮件分享，您的设备不支持发送短信（比如ipad、itouch等））
    kXMErrorCodeAppNotInstalled            = 6,  //没有安装该应用
    kXMErrorCodePlatformTypeUnknown        = 7,  //不支持该分享平台类型（如暂不支持百度hi）
    kXMErrorCodeShareObjectTypeUnknown     = 8,  //不支持的分享对象类型（参见：XMShareObject.h）
    kXMErrorCodeShareObjectInvalid         = 9,  //分享对象不合法（包括为null和不合法）
    kXMErrorCodeObjectAllocFailed          = 10, //对象分配失败
    kXMErrorCodeSendRequestFailed          = 11, //发送请求失败
    kXMErrorCodeAppNotRegistered           = 12, //应用没有被注册
    kXMErrorCodeUnSupported                = 13, //分享渠道不支持（或者该sdk不支持）
    kXMErrorCodeNetworkUnReachability      = 14, //网络不可达
    kXMErrorCodeUnknown                    = 15, //未知错误
    kXMErrorCodeNone                       = 16,
    kXMErrorCodeCount
};


static char const *errMessages[kXMErrorCodeCount] = {
    "分享成功",
    "分享失败",
    "分享取消",
    "认证失败",
    "参数不合法",
    "设备不支持该分享功能",
    "没有安装该应用，请安装",
    "不支持的分享平台类型",
    "不支持的分享对象类型",
    "分享对象不合法",
    "对象分配失败",
    "发送请求失败",
    "应用没有被注册",
    "分享渠道不支持",
    "网络连接失败",
    "未知错误",
    "初始化状态",
};



/**
 *  XMShareOperation
 */
@interface XMShareOperation ()
<
MFMessageComposeViewControllerDelegate,
MFMailComposeViewControllerDelegate,
MBProgressHUDDelegate
>

@property (nonatomic, assign, readwrite) BOOL isShareCtl;
@property (nonatomic, assign, readwrite) XMShareErrorCode errCode; //内部错误码
@property (nonatomic, copy, readwrite)   NSString *operationID;
@property (nonatomic, assign, readwrite) XMShareChannelType channel;
@property (nonatomic, strong, readwrite) XMShareObject *shareObject;
@property (nonatomic, assign, readwrite) XMSharePlatform platformType;
@property (nonatomic, copy, readwrite)   NSString *platformName;
@property (nonatomic, copy, readwrite)   XMShareOperationCompletionHandler completionHandler;
@property (nonatomic, weak, readwrite)   UIViewController *currentViewController;
@property (nonatomic, strong, readwrite) MBProgressHUD *HUD;

@property (nonatomic, assign) BOOL isSSOForLogin; // default is NO XMSSOResponseHandler
@property (nonatomic, copy) XMSSOResponseHandler ssoCallback;

/**
 *  处理分享完成后的回掉函数
 */
- (void)responseShareCompletionHandler;

- (void)sendSSOAuth;
- (void)getAccessTokenWithSSOObject:(XMSSOResponseObject *)respObj;
- (void)getUserInfoWithSSOObject:(XMSSOResponseObject *)respObj;

@end


/**
 *  微信WXApiDelegate代理实现
 */
@interface XMWXOperationImpl : XMShareOperation
<
WXApiDelegate
>
@end


/**
 *  腾讯QQApiInterfaceDelegate代理实现
 */
@interface XMQQOperationImpl : XMShareOperation
<
QQApiInterfaceDelegate
>
@end;


/**
 *  微博WeiboSDKDelegate代理实现
 */
static NSString *wbAccessToken   = nil;
static NSString *wbCurrentUserID = nil;
static NSString *wbRefreshToken  = nil;
@interface XMWBOperationImpl : XMShareOperation
<
WeiboSDKDelegate
>
@end


@implementation XMShareOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initObjects];
    }
    return self;
}


- (void)initObjects
{
    self.HUD = nil;
    
    self.isSSOForLogin     = NO;
    
    self.isShareCtl        = NO;
    self.canWBH5Auth       = NO;
    self.canQQH5Auth       = NO;
    self.errCode           = kXMErrorCodeNone;
    self.channel           = kXMShareChannelUnknown;
    self.platformName      = nil;
    self.completionHandler = nil;
    
    id <UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    self.currentViewController = appDelegate ? appDelegate.window.rootViewController : nil;
    
    [self registerNotifications];
}


- (void)dealloc
{
    [self unregisterNotifications];
}


+ (XMShareOperation *)operationWithPlatform:(NSString *)platformName shareObject:(XMShareObject *)shareObject completionHandler:(XMShareOperationCompletionHandler)completionHandler
{
    XMShareOperation *operation = nil;
    XMShareChannelType channel = [XMShareOperation channelForPlatform:platformName];
    
    switch (channel) {
        case kXMShareChannelWeixin: {
            operation = [[XMWXOperationImpl alloc] init];
        }
            break;
            
        case kXMShareChannelQQ: {
            operation = [[XMQQOperationImpl alloc] init];
        }
            break;
            
        case kXMShareChannelSinaWeibo: {
            operation = [[XMWBOperationImpl alloc] init];
        }
            break;
            
        case kXMShareChannelBaiduHi: {
            
        }
            break;
            
        default: {
            operation = [[XMShareOperation alloc] init];
        }
            break;
    }
    operation.operationID = [[NSUUID UUID] UUIDString];
    operation.channel = channel;
    operation.platformName = platformName;
    operation.platformType = [XMShareOperation platformTypeForPlatformName:platformName];
    operation.shareObject = [operation newShareObject:shareObject forPlatform:platformName];
    operation.completionHandler = completionHandler;
    
    return operation;
}


+ (XMShareOperation *)operationForChannel:(NSUInteger)channel SSOResponseHandler:(XMSSOResponseHandler)handler fromViewController:(UIViewController *)viewController
{
    XMShareOperation *operation = nil;
    switch (channel) {
        case kXMShareChannelWeixin: {
            operation = [[XMWXOperationImpl alloc] init];
        }
            break;
            
        case kXMShareChannelQQ: {
            operation = [[XMQQOperationImpl alloc] init];
        }
            break;
            
        case kXMShareChannelSinaWeibo: {
            operation = [[XMWBOperationImpl alloc] init];
        }
            break;
            
        case kXMShareChannelBaiduHi: {
            
        }
            break;
            
        default: {
            operation = [[XMShareOperation alloc] init];
        }
            break;
    }
    operation.isSSOForLogin = YES;
    operation.channel = channel;
    operation.ssoCallback = handler;

    return operation;
}


- (void)commitSSOAuth
{
    [self sendSSOAuth];
}


- (void)sendSSOAuth
{
    
}


- (void)getAccessTokenWithSSOObject:(XMSSOResponseObject *)respObj
{
    
}


- (void)getUserInfoWithSSOObject:(XMSSOResponseObject *)respObj
{
    
}


- (XMShareObject *)newShareObject:(XMShareObject *)shareObject forPlatform:(nonnull NSString *)platform
{
    if ([platform length] <= 0) {
        return shareObject;
    }
    
    XMShareObject *newObject = [shareObject copy];
    XMShareObject *platformObject = [shareObject.platformDictionary objectForKey:platform];
    
    if (platformObject.title && [platformObject.title length] > 0) {
        newObject.title = platformObject.title;
    }
    
    if (platformObject.content && [platformObject.content length] > 0) {
        newObject.content = platformObject.content;
    }
    
    if (platformObject.webpageUrl && [platformObject.webpageUrl length] > 0) {
        newObject.webpageUrl = platformObject.webpageUrl;
    }
    
    if (platformObject.thumbImageObject && platformObject.thumbImageObject != newObject.thumbImageObject) {
        newObject.thumbImageObject = platformObject.thumbImageObject;
    }
    
    if (platformObject.imageObject && platformObject.imageObject != newObject.imageObject) {
        newObject.imageObject = platformObject.imageObject;
    }
    
    if (platformObject.extInfo && ![platformObject.extInfo isEqualToDictionary:newObject.extInfo]) {
        newObject.extInfo = platformObject.extInfo;
    }
    
    return newObject;
}


#pragma mark - private method for check and format shareObject

/**
 *  检查将分享的参数，如果不存在则赋默认值，若不合法将返回NO
 *
 *  @return 是否包含不合法的参数
 */
- (BOOL)checkParametersForPlatform:(XMSharePlatform)platform
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (self.shareObject.title == nil || [self.shareObject.title length] == 0) {
        self.shareObject.title = [mainBundle localizedStringForKey:kXMShareDefaultTitleKey value:nil table:kXMTableStringFileName];
        
        if (self.shareObject.title == nil) {
            return NO;
        }
    }
    
    if (self.shareObject.content == nil || [self.shareObject.content length] == 0) {
        self.shareObject.content = [mainBundle localizedStringForKey:kXMShareDefaultContentKey value:nil table:kXMTableStringFileName];
        
        if (self.shareObject.content == nil) {
            return NO;
        }
    }
    
    // 自定义：分享至新浪微博，目前不支持linkCard，分享时分享webpage形式以image形式展示
    if (platform == kXMSharePlatformSinaWeibo && self.shareObject.type == kXMShareObjectTypeWebpage) {
        self.shareObject.type = kXMShareObjectTypeImage;
        self.shareObject.content = [self.shareObject.content stringByAppendingFormat:@"%@", (self.shareObject.webpageUrl ? self.shareObject.webpageUrl : @"")]; //因PM要求，不显示标题，且链接拼在后面
        self.shareObject.imageObject = self.shareObject.thumbImageObject;
    }
    
    if (self.shareObject.type == kXMShareObjectTypeWebpage || self.shareObject.type == kXMShareObjectTypeAudio) {
        if (self.shareObject.webpageUrl == nil || [self.shareObject.webpageUrl length] == 0) {
            self.shareObject.webpageUrl = [mainBundle localizedStringForKey:kXMShareDefaultURLKey value:nil table:kXMTableStringFileName];
            
            if (self.shareObject.webpageUrl == nil) {
                return NO;
            }
        }
    }
    
    if (self.shareObject.type == kXMShareObjectTypeImage || self.shareObject.type == kXMShareObjectTypeWebpage || self.shareObject.type == kXMShareObjectTypeAudio) {
        if (self.shareObject.thumbImageObject == nil) {
            self.shareObject.thumbImageObject = [XMShareImageObject imageObjectWithImage:[UIImage imageNamed:kXMShareDefaultThumbImageName]];
        }
        
        if (self.shareObject.thumbImageObject.imageUrl == nil && self.shareObject.thumbImageObject.image == nil) {
            self.shareObject.thumbImageObject.image = [UIImage imageNamed:kXMShareDefaultThumbImageName];
        }
        
        if (self.shareObject.thumbImageObject.imageUrl && self.shareObject.thumbImageObject.image == nil && [self isNeedDownloadImage] == YES) {
            self.shareObject.thumbImageObject.image = [UIImage imageNamed:kXMShareDefaultThumbImageName];
        }
    }
    
//    音频分享检测
//    if (self.shareObject.type == kXMShareObjectTypeAudio) {
//        if (self.shareObject.audioUrl != nil) {
//            return [XMShareUtility isAudioUrlStringValid:self.shareObject.audioUrl forPlatform:platform];
//        }
//    }
    
    // 大图分享检测
    if (self.shareObject.type == kXMShareObjectTypeImage) {
        if (self.shareObject.imageObject == nil) {
            self.shareObject.imageObject = [XMShareImageObject imageObjectWithImage:[UIImage imageNamed:kXMShareDefaultThumbImageName]];
        }
        
        if (self.shareObject.imageObject.imageUrl == nil && self.shareObject.imageObject.image == nil) {
            self.shareObject.imageObject.image = [UIImage imageNamed:kXMShareDefaultThumbImageName];
        }
        
        if (self.shareObject.imageObject.imageUrl && self.shareObject.imageObject.image == nil && [self isNeedDownloadImage] == YES) {
            self.shareObject.imageObject.image = [UIImage imageNamed:kXMShareDefaultThumbImageName];
        }
    }
    
    return YES;
}


/**
 *  将数据规范为当前分享平台的数据格式
 *
 *  @return 当前数据是否是符合当前平台的数据格式规范
 */
- (BOOL)normalizedShareObjectParameters
{
    if (![self checkParametersForPlatform:self.platformType]) {
        return NO;
    }
    
    self.shareObject.title = [XMShareUtility normalizedTitleString:self.shareObject.title forPlatform:self.platformType forType:self.shareObject.type];
    self.shareObject.content = [XMShareUtility normalizedContentString:self.shareObject.content forPlatform:self.platformType forType:self.shareObject.type];
    self.shareObject.thumbImageObject = [XMShareUtility normalizedImageObject:self.shareObject.thumbImageObject forPlatform:self.platformType isThumbImage:YES];
    self.shareObject.imageObject = [XMShareUtility normalizedImageObject:self.shareObject.imageObject forPlatform:self.platformType isThumbImage:NO];
    
    return YES;
}


#pragma mark - register/unregister notifications

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloadCompletion:) name:kXMShareImageDownloadCompletionKey object:nil];
}


- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMShareImageDownloadCompletionKey object:nil];
}


#pragma mark - event for notifications

- (void)imageDownloadCompletion:(NSNotification *)not
{
    if (not.userInfo) {
        NSString *imageDownloaderOperationID = [not.userInfo objectForKey:kXMShareImageDownloadForOperationKey];
        if (imageDownloaderOperationID && ![imageDownloaderOperationID isEqualToString:self.operationID]) {
            return;
        }
        
        XMImageDownloadProgress downloadProgress = [[not.userInfo objectForKey:kXMShareImageDownloadProgressKey] integerValue];
        switch (downloadProgress) {
            case kXMImageDownloadCompleted: {
                if (![self.shareObject isImageDownloading]) {
                    XM_SHARE_LOG(@"kXMImageDownloadCompleted");
                    [self.HUD hide:YES];
                }
            }
                break;
                
            case kXMImageDownloadFailed: {
                XM_SHARE_LOG(@"kXMImageDownloadFailed");
                [self.HUD hide:YES];
            }
                break;
                
            default: {
                
            }
                break;
        }
    } else {
        if (![self.shareObject isImageDownloading]) {
            // hide progressHUD and commitOperation
            XM_SHARE_LOG(@"kXMImageDownloadCompleted");
            [self.HUD hide:YES];
        }
    }
}


/**
 *  【微信】
 *  1. webpage类型
 *  缩略图发送，不支持imageUrl
 *  2. 图片类型
 *  缩略图发送，不支持imageUrl
 *  图片发送，支持imageUrl
 *  3. audio类型
 *  缩略图发送，不支持imageUrl
 *
 *  【qq】
 *  1. webpage类型
 *  缩略图发送，支持imageUrl
 *  2. 图片类型
 *  缩略图发送，支持imageUrl
 *  图片发送，支持imageUrl
 *  3. audio类型
 *  缩略图发送，支持imageUrl
 *
 *  【微博】
 *  1. webpage类型
 *  缩略图发送，不支持imageUrl
 *  2. 图片类型
 *  缩略图发送，不支持imageUrl
 *  图片发送，不支持imageUrl
 *  3. audio类型
 *  缩略图发送，不支持imageUrl
 */
- (BOOL)isNeedDownloadImage
{
    BOOL isNeedDownload = [self.shareObject isImageDownloading];
    
    if (self.shareObject.type == kXMShareObjectTypeText ||
        self.shareObject.type == kXMShareObjectTypeUnknown) {
        isNeedDownload = isNeedDownload && NO;
    }
    
    switch (self.platformType) {
        case kXMSharePlatformQQZone:
        case kXMSharePlatformQQFriend: {
            isNeedDownload = isNeedDownload && NO;
        }
            break;
            
        case kXMSharePlatformWeixinSession:
        case kXMSharePlatformWeixinTimeline: {
            isNeedDownload = isNeedDownload && YES;
            
            if (self.shareObject.type == kXMShareObjectTypeWebpage && self.shareObject.thumbImageObject.image) {
                isNeedDownload = isNeedDownload && NO;
            }
            
            if (self.shareObject.type == kXMShareObjectTypeAudio && self.shareObject.thumbImageObject.image) {
                isNeedDownload = isNeedDownload && NO;
            }
            
            if (self.shareObject.type == kXMShareObjectTypeImage && self.shareObject.thumbImageObject.image && (self.shareObject.imageObject.image || self.shareObject.imageObject.imageUrl)) {
                isNeedDownload = isNeedDownload && NO;
            }
        }
            break;
            
        case kXMSharePlatformSinaWeibo: {
            isNeedDownload = isNeedDownload && YES;
        }
            break;
        
        case kXMSharePlatformEmail: {
            isNeedDownload = isNeedDownload && YES;
        }
            break;
            
        case kXMSharePlatformSMS:
        case kXMSharePlatformBaiduHi:
        case kXMSharePlatformCopyLink:
        case kXMSharePlatformUnSupported: {
            isNeedDownload = isNeedDownload && NO;
        }
            break;
            
        case kXMSharePlatformMoreOptions:
        default: {
            isNeedDownload = isNeedDownload && YES;
        }
            break;
    }
    
    return isNeedDownload;
}


- (BOOL)isNetworkOperation
{
    BOOL isNetworkOp = YES;
    
    if (self.platformType == kXMSharePlatformCopyLink ||
        self.platformType == kXMSharePlatformSMS ||
        self.platformType == kXMSharePlatformEmail ||
        self.platformType == kXMSharePlatformMoreOptions ||
        self.platformType == kXMSharePlatformUnSupported) {
        isNetworkOp = NO;
    }
    
    return isNetworkOp;
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    /**
     * Remove HUD from screen when the HUD was hidded
     * Commit share operation
     */
    if (self.HUD == hud) {
        [self.HUD removeFromSuperview];
        self.HUD = nil;
        
        [self commitOperation];
    }
}


#pragma mark - getter/setter property

- (void)setShareObject:(XMShareObject *)shareObject
{
    _shareObject = shareObject;
    _shareObject.thumbImageObject.operationID = self.operationID;
    _shareObject.imageObject.operationID = self.operationID;
}


- (NSString *)errMessageString {
    if (self.errCode < kXMErrorCodeCount) {
        return [NSString stringWithCString:errMessages[self.errCode] encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}


#pragma mark - commit operation

- (void)commitOperation
{
    BOOL isValidObject = [self normalizedShareObjectParameters];
    
    XM_SHARE_LOG(@"shareObject = \n{ %@ \n}", self.shareObject);
    
    if (!isValidObject) {
        self.errCode = kXMErrorCodeParametersInvalid;
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeParametersInvalid");
        [self responseShareCompletionHandler];
    } else {
        switch (self.platformType) {
            case kXMSharePlatformQQFriend: {
                [self shareToQQFriend];
            }
                break;
                
            case kXMSharePlatformQQZone: {
                [self shareToQQZone];
            }
                break;
                
            case kXMSharePlatformWeixinSession: {
                [self shareToWeixinSession];
            }
                break;
                
            case kXMSharePlatformWeixinTimeline: {
                [self shareToWeixinTimeline];
            }
                break;
                
            case kXMSharePlatformSinaWeibo: {
                [self shareToSinaWeibo];
            }
                break;
                
            case kXMSharePlatformCopyLink: {
                [self shareToCopyLink];
            }
                break;
                
            case kXMSharePlatformSMS: {
                [self shareToSMS];
            }
                break;
                
            case kXMSharePlatformEmail: {
                [self shareToEmail];
            }
                break;
                
            case kXMSharePlatformBaiduHi: {
                [self shareToBaiduHi];
            }
                break;
                
            case kXMSharePlatformMoreOptions: {
                [self shareToMore];
            }
                break;
                
            default: {
                self.errCode = kXMErrorCodePlatformTypeUnknown;
                XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodePlatformTypeUnknown");
                [self responseShareCompletionHandler];
            }
                break;
        }
    }
}


- (void)commitOperationWithProgressHUD:(BOOL)showHUD
{
    if ([self isNetworkOperation] && !XM_IsNetworkReachability) {
        [self setErrCode:kXMErrorCodeNetworkUnReachability];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeNetworkUnReachability");
        [self responseShareCompletionHandler];
    } else if (self.channel == kXMShareChannelWeixin && ![WXApi isWXAppInstalled]) {
        [self setErrCode:kXMErrorCodeAppNotInstalled];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeAppNotInstalled for Weixin");
        [self responseShareCompletionHandler];
    } else if (self.channel == kXMShareChannelSinaWeibo && ![self canWBH5Auth] && ![WeiboSDK isWeiboAppInstalled]) {
        [self setErrCode:kXMErrorCodeAppNotInstalled];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeAppNotInstalled for Weibo");
        [self responseShareCompletionHandler];
    }  else if (self.channel == kXMShareChannelQQ && ![self canQQH5Auth] && (![QQApiInterface isQQSupportApi] || ![QQApiInterface isQQInstalled])) {
        [self setErrCode:kXMErrorCodeAppNotInstalled];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeAppNotInstalled for QQ");
        [self responseShareCompletionHandler];
    } else {
        if (showHUD) {
            if ([self isNeedDownloadImage]) {
                // show download progress HUD
                self.HUD = [[MBProgressHUD alloc] initWithView:self.currentViewController.view];
                self.HUD.delegate = self;
                self.HUD.labelText = @"加载中...";
                self.HUD.removeFromSuperViewOnHide = YES;
                [self.currentViewController.view addSubview:self.HUD];
                [self.HUD show:YES];
            } else {
                [self commitOperation];
            }
        } else {
            [self commitOperation];
        }
    }
}


#pragma mark - share to appointed platform

- (void)shareToWeixinSession
{
    SendMessageToWXReq *weixinRequest = [self.shareObject weixinRequestObject];
    
    if (weixinRequest) {
        weixinRequest.scene = WXSceneSession;
        
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"Begin send Request");
        BOOL isSendSuccess = [WXApi sendReq:weixinRequest];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"End send Request");
        
//        if (!isSendSuccess) {
//            self.errCode = kXMErrorCodeSendRequestFailed;
//            XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeSendRequestFailed for WeixinSession");
//            [self responseShareCompletionHandler];
//        }
        XM_SHARE_VLOG(self.errCode, [self errMessageString], ([NSString stringWithFormat:@"分享至微信好友是否成功--%d", isSendSuccess]));
    } else {
        self.errCode = kXMErrorCodeObjectAllocFailed;
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeObjectAllocFailed for WeixinSession");
        [self responseShareCompletionHandler];
    }
}


/**
 *  分享到微信朋友圈，当分享类型为webpage时，实际显示的是title，并没有显示description内容，为了显示标题加描述，将内容追加至title后面
 */
- (void)shareToWeixinTimeline
{
    SendMessageToWXReq *weixinRequest = [self.shareObject weixinRequestObject];
    
    if (weixinRequest) {
        weixinRequest.scene = WXSceneTimeline;
        
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"Begin send Request");
        BOOL isSendSuccess = [WXApi sendReq:weixinRequest];
        NSString *otherMsg = [NSString stringWithFormat:@"isSendSuccess = %ld \nEnd send Request", (long)isSendSuccess];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], otherMsg);
        
//        if (!isSendSuccess) {
//            self.errCode = kXMErrorCodeSendRequestFailed;
//            XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeSendRequestFailed for WeixinTimeline");
//            [self responseShareCompletionHandler];
//        }
        XM_SHARE_VLOG(self.errCode, [self errMessageString], ([NSString stringWithFormat:@"分享至微信朋友圈是否成功--%d", isSendSuccess]));
    } else {
        self.errCode = kXMErrorCodeObjectAllocFailed;
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeObjectAllocFailed for WeixinTimeline");
        [self responseShareCompletionHandler];
    }
}


- (BOOL)_canJumpToWeixinAppForRequest:(SendMessageToWXReq *)request
{
    if (!request) {
        return NO;
    }
    
    if (request.bText) {
        return ([request.text length] > 0);
    }
    
    id mediaObject = request.message.mediaObject;
    if ([mediaObject isKindOfClass:[WXWebpageObject class]]) {
        return ([((WXWebpageObject *)mediaObject).webpageUrl length] > 0);
    } else if ([mediaObject isKindOfClass:[WXImageObject class]]) {
        return (([((WXImageObject *)mediaObject).imageUrl length] > 0) || ((WXImageObject *)mediaObject).imageData);
    } else if ([mediaObject isKindOfClass:[WXMusicObject class]]) {
        return ([((WXMusicObject *)mediaObject).musicUrl length] > 0);
    }
    
    return NO;
}


- (void)shareToQQFriend
{
    QQApiObject *qqRequestObject = [self.shareObject qqRequestObject];
    
    if (qqRequestObject) {
        SendMessageToQQReq *qqRequest = [SendMessageToQQReq reqWithContent:qqRequestObject];
        QQApiSendResultCode QQResultCode = [QQApiInterface sendReq:qqRequest];
        [self _handleQQRequestResultCode:QQResultCode];
    } else {
        self.errCode = kXMErrorCodeObjectAllocFailed;
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeObjectAllocFailed for QQFriend");
        [self responseShareCompletionHandler];
    }
}


- (void)shareToQQZone
{
    QQApiObject *qqRequestObject = [self.shareObject qqRequestObject];
    
    if (qqRequestObject) {
        SendMessageToQQReq *qqRequest = [SendMessageToQQReq reqWithContent:qqRequestObject];
        QQApiSendResultCode QQResultCode = [QQApiInterface SendReqToQZone:qqRequest];
        [self _handleQQRequestResultCode:QQResultCode];
    } else {
        self.errCode = kXMErrorCodeObjectAllocFailed;
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeObjectAllocFailed for QQZone");
        [self responseShareCompletionHandler];
    }
}


/**
 *  对QQ分享的错误码进行处理
 *
 *  @param qqResultCode QQ分享返回状态码
 */
- (void)_handleQQRequestResultCode:(QQApiSendResultCode)qqResultCode
{
    XMShareErrorCode errorCode = kXMErrorCodeUnknown;
    
    switch (qqResultCode) {
        case EQQAPISENDSUCESS: {
            errorCode = kXMErrorCodeSuccess;
        }
            break;
            
        case EQQAPISENDFAILD: {
            errorCode = kXMErrorCodeFailed;
        }
            break;
            
        case EQQAPIQQNOTINSTALLED: {
            errorCode = kXMErrorCodeAppNotInstalled;
        }
            break;
            
        case EQQAPIMESSAGETYPEINVALID: {
            errorCode = kXMErrorCodeShareObjectTypeUnknown;
        }
            break;
            
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGECONTENTINVALID: {
            errorCode = kXMErrorCodeParametersInvalid;
        }
            break;
            
        case EQQAPIQZONENOTSUPPORTTEXT:
        case EQQAPIQZONENOTSUPPORTIMAGE: {
            errorCode = kXMErrorCodeShareObjectInvalid;
        }
            break;
            
        case EQQAPIAPPNOTREGISTED: {
            errorCode = kXMErrorCodeAppNotRegistered;
        }
            break;
            
        case EQQAPIAPPSHAREASYNC: {
            errorCode = kXMErrorCodeUnknown;
        }
            break;
            
        case EQQAPIQQNOTSUPPORTAPI: {
            errorCode = kXMErrorCodeAppNotInstalled;
        }
            break;
            
        default: {
            errorCode = kXMErrorCodeUnknown;
        }
            break;
    }
    
    self.errCode = errorCode;
    if (errorCode != EQQAPISENDSUCESS) {
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"QQSendRequestResultCode is not success");
        [self responseShareCompletionHandler];
    }
}


static NSString * const wbRedirectURI = @"http://www.m.nuomi.com";

- (void)shareToSinaWeibo
{
    WBMessageObject *wbMsgObject = [self.shareObject weiboRequestObject];
    
    if (wbMsgObject) {
        WBSendMessageToWeiboRequest *weiboRequest = nil;
        
        if (self.canWBH5Auth) {
            NSString *weiboRedirectURI = wbRedirectURI;
            WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
            authRequest.redirectURI = weiboRedirectURI;
            authRequest.scope = @"all";
            
            weiboRequest = [WBSendMessageToWeiboRequest requestWithMessage:wbMsgObject authInfo:authRequest access_token:wbAccessToken];
        } else {
            weiboRequest = [WBSendMessageToWeiboRequest requestWithMessage:wbMsgObject];
        }
        
        BOOL isSendSuccess = [WeiboSDK sendRequest:weiboRequest];

        if(!isSendSuccess) {
            self.errCode = kXMErrorCodeSendRequestFailed;
            XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeSendRequestFailed for Weibo");
            [self responseShareCompletionHandler];
        }
        XM_SHARE_VLOG(self.errCode, [self errMessageString], ([NSString stringWithFormat:@"分享至微博是否成功--%d", isSendSuccess]));
    } else {
        self.errCode = kXMErrorCodeObjectAllocFailed;
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"kXMErrorCodeObjectAllocFailed for Weibo");
        [self responseShareCompletionHandler];
    }
}


- (BOOL)_canJumpToWeiboAppForRequest:(WBSendMessageToWeiboRequest *)request
{
    return NO;
}


- (void)shareToSMS
{
    if (![MFMessageComposeViewController canSendText]) {
        self.errCode = kXMErrorCodeDeviceUnSupported;
        [self responseShareCompletionHandler];
    } else {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        
        NSString *messageBody = nil;
        if (self.shareObject.title) {
            // 因PM要求，短信不需要title
//            messageBody = [NSString stringWithFormat:@"%@\n", self.shareObject.title];
        }
        
        if (self.shareObject.content) {
            messageBody = messageBody ? [NSString stringWithFormat:@"%@ %@", messageBody, self.shareObject.content] : self.shareObject.content;
        }
        
        if (self.shareObject.webpageUrl && [self.shareObject.webpageUrl length] != 0) {
            messageBody = messageBody ? [NSString stringWithFormat:@"%@ %@", messageBody, self.shareObject.webpageUrl] : self.shareObject.webpageUrl;
        }
        
        if ([MFMessageComposeViewController canSendText]) {
            [messageController setBody:messageBody];
        }
        
        if ([MFMessageComposeViewController canSendSubject]) {
            [messageController setSubject:self.shareObject.title];
        }
        
        if (self.currentViewController && [self.currentViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [self.currentViewController presentViewController:messageController animated:YES completion:nil];
        }
    }
}


#pragma mark - delegate for sending SMS

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultFailed: {
            self.errCode = kXMErrorCodeFailed;
        }
            break;
            
        case MessageComposeResultCancelled: {
            self.errCode = kXMErrorCodeCanceled;
        }
            break;
            
        case MessageComposeResultSent: {
            self.errCode = kXMErrorCodeSuccess;
        }
            break;
            
        default: {
            self.errCode = kXMErrorCodeUnknown;
        }
            break;
    }
    
    if (self.currentViewController && [self.currentViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        __weak typeof(self) weakSelf = self;
        [self.currentViewController dismissViewControllerAnimated:YES completion:^{
            [weakSelf responseShareCompletionHandler];
        }];
    } else {
        [self responseShareCompletionHandler];
    }
}


- (void)shareToEmail
{
    if (![MFMailComposeViewController canSendMail]) {
        self.errCode = kXMErrorCodeDeviceUnSupported;
        [self responseShareCompletionHandler];
    } else {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        
        NSString *subjectString = nil;
        NSString *contentString = nil;
        if (self.shareObject.title) {
            subjectString = self.shareObject.title;
        } else {
            subjectString = @"百度糯米";
        }
        
        if (self.shareObject.content) {
            contentString = self.shareObject.content;
        }
        
        if (self.shareObject.webpageUrl && [self.shareObject.webpageUrl length] != 0) {
            contentString = contentString ? [NSString stringWithFormat:@"%@ %@", contentString, self.shareObject.webpageUrl] : self.shareObject.webpageUrl;
        }
        
        [mailController setSubject:subjectString];
        [mailController setMessageBody:contentString isHTML:YES];
        
        if ([MFMessageComposeViewController canSendAttachments]) {
            if (self.shareObject.thumbImageObject) {
                [mailController addAttachmentData:UIImageJPEGRepresentation(self.shareObject.thumbImageObject.image, 1.0f) mimeType:@"" fileName:@"image.jpg"];
            }
            
            if (self.shareObject.imageObject) {
                [mailController addAttachmentData:UIImageJPEGRepresentation(self.shareObject.imageObject.image, 1.0f) mimeType:@"" fileName:@"image.jpg"];
            }
        }
        
        if (self.currentViewController && [self.currentViewController respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            [self.currentViewController presentViewController:mailController animated:YES completion:nil];
        }
    }
}


#pragma mark - delegate for sending mail

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultFailed: {
            self.errCode = kXMErrorCodeFailed;
        }
            break;
         
        case MFMailComposeResultSaved:
        case MFMailComposeResultCancelled: {
            self.errCode = kXMErrorCodeCanceled;
        }
            break;
            
        case MFMailComposeResultSent: {
            self.errCode = kXMErrorCodeSuccess;
        }
            break;
            
        default: {
            self.errCode = kXMErrorCodeUnknown;
        }
            break;
    }
    
    if (self.currentViewController && [self.currentViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        __weak typeof(self) weakSelf = self;
        [self.currentViewController dismissViewControllerAnimated:YES completion:^{
            [weakSelf responseShareCompletionHandler];
        }];
    } else {
        [self responseShareCompletionHandler];
    }
}


- (void)shareToCopyLink
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (!self.shareObject.webpageUrl || [self.shareObject.webpageUrl length] == 0) {
        self.errCode = kXMErrorCodeParametersInvalid;
    } else {
        [pasteboard setString:self.shareObject.webpageUrl];
        
        if (pasteboard.string == nil) {
            self.errCode = kXMErrorCodeCanceled;
        } else if ([pasteboard.string isEqualToString:self.shareObject.webpageUrl]) {
            self.errCode = kXMErrorCodeSuccess;
        } else {
            self.errCode = kXMErrorCodeFailed;
        }
    }
    
    [self responseShareCompletionHandler];
}


- (void)shareToBaiduHi
{
    
}


- (void)shareToMore
{
    
}


#pragma mark - response completion Handler

- (void)responseShareCompletionHandler
{
    // show toast and log
    XM_SHARE_PLOG(self.errCode, [self errMessageString]);
    
    switch (self.errCode) {
        case kXMErrorCodeNetworkUnReachability: {
            [[BTMToast sharedInstance] showToast:@"网络连接失败"];
        }
            break;
            
        case kXMErrorCodeAppNotInstalled: {
            if (self.channel == kXMShareChannelWeixin) {
                 [[BTMToast sharedInstance] showToast:@"您未安装微信客户端，\n请安装后再试"];
            } else if (self.channel == kXMShareChannelSinaWeibo) {
                [[BTMToast sharedInstance] showToast:@"您未安装微博客户端，\n请安装后再试"];
            } else if (self.channel == kXMShareChannelQQ) {
                [[BTMToast sharedInstance] showToast:@"您未安装QQ客户端或版本太低，\n请安装后再试"];
            }
        }
            break;
            
        case kXMErrorCodeDeviceUnSupported: {
            if (self.platformType == kXMSharePlatformSMS) {
                [[BTMToast sharedInstance] showToast:@"您的设备不支持发送短信"];
            } else if (self.platformType == kXMSharePlatformEmail) {
                [[BTMToast sharedInstance] showToast:@"您的设备没有配置邮箱账户\n或不支持发送邮件"];
            }
        }
            break;
            
        default: {
            if (self.completionHandler) {
                XMShareResultCode errCode = kXMShareFailed;
                
                switch (self.errCode) {
                    case kXMErrorCodeSuccess: {
                        errCode = kXMShareSuccess;
                    }
                        break;
                        
                    case kXMErrorCodeCanceled: {
                        errCode = kXMShareCanceled;
                    }
                        break;
                        
                    default: {
                        errCode = kXMShareFailed;
                    }
                        break;
                }
                
                NSString *otherMsg = [NSString stringWithFormat:@"At file: %s, function: %s, line: %d", __FILE__, __FUNCTION__, __LINE__];
                XM_SHARE_VLOG(self.errCode, [self errMessageString], otherMsg);
                
                NSError *error = [NSError errorWithDomain:kXMShareErrorDomainKey
                                                     code:errCode
                                                 userInfo:@{
                                                            kXMSharePlatformKey:self.platformName,
                                                            kXMShareErrorCodeKey:@(self.errCode),
                                                            kXMShareErrorMessageKey:[NSString stringWithCString:errMessages[self.errCode] encoding:NSUTF8StringEncoding],
                                                            kXMShareErrorOtherMessageKey:otherMsg
                                                            }];
                self.completionHandler(self, errCode, self.platformName, nil, error);
            }
        }
            break;
    }
}


#pragma mark - delegate for third channel

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}


- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    
}


- (void)onReq:(QQBaseReq *)req
{
    
}


- (void)onResp:(QQBaseResp *)resp
{
    
}


- (void)isOnlineResponse:(NSDictionary *)response
{
    
}


#pragma mark - private method for helper
/**
 *  通过平台名称获得分享的渠道
 *
 *  @return 渠道类型
 */
+ (XMShareChannelType)channelForPlatform:(NSString *)platformName
{
    XMShareChannelType channel = kXMShareChannelUnknown;
    
    if ([platformName isEqualToString:kXM_SHARE_PLATFORM_QQ_FRIEND]) {
        channel = kXMShareChannelQQ;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_QQ_ZONE]) {
        channel = kXMShareChannelQQ;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_WEIXIN_SESSION]) {
        channel = kXMShareChannelWeixin;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_WEIXIN_TIMELINE]) {
        channel = kXMShareChannelWeixin;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_SINAWEIBO]) {
        channel = kXMShareChannelSinaWeibo;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_BAIDUHI]) {
        channel = kXMShareChannelBaiduHi;
    } else {
        channel = kXMShareChannelUnknown;
    }
    
    return channel;
}


+ (XMSharePlatform)platformTypeForPlatformName:(NSString *)platformName
{
    XMSharePlatform platformType = kXMSharePlatformUnSupported;
    
    if ([platformName isEqualToString:kXM_SHARE_PLATFORM_QQ_FRIEND]) {
        platformType = kXMSharePlatformQQFriend;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_QQ_ZONE]) {
        platformType = kXMSharePlatformQQZone;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_WEIXIN_SESSION]) {
        platformType = kXMSharePlatformWeixinSession;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_WEIXIN_TIMELINE]) {
        platformType = kXMSharePlatformWeixinTimeline;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_SINAWEIBO]) {
        platformType = kXMSharePlatformSinaWeibo;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_BAIDUHI]) {
        platformType = kXMSharePlatformBaiduHi;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_SMS]) {
        platformType = kXMSharePlatformSMS;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_EMAIL]) {
        platformType = kXMSharePlatformEmail;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_COPY_LINK]) {
        platformType = kXMSharePlatformCopyLink;
    } else if ([platformName isEqualToString:kXM_SHARE_PLATFORM_MORE_OPTIONS]) {
        platformType = kXMSharePlatformMoreOptions;
    } else {
        platformType = kXMSharePlatformUnSupported;
    }
    
    return platformType;
}

@end





#pragma mark - Weixin , QQ, Weibo delegate Implementation

/**
 *  微信WXApiDelegate代理实现
 */
@implementation XMWXOperationImpl {
    NSString *_code;
    NSString *_accessToken;
    NSString *_openId;
}


- (void)sendSSOAuth
{
    if (![WXApi isWXAppInstalled]) {
        [[BTMToast sharedInstance] showToast:@"您未安装微信客户端，\n请安装后再试"];
        return;
    }

    _code = nil;
    _accessToken = nil;
    _openId = nil;
    
    SendAuthReq *req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"0744" ;
    
    if ([WXApi sendReq:req]) {
        XM_SHARE_LOG(@"Success: [WXApi sendReq]");
    } else {
        XM_SHARE_LOG(@"Error: [WXApi sendReq]");
    }
}


- (void)getAccessTokenWithSSOObject:(XMSSOResponseObject *)respObj
{
    if (!_code) {
        self.ssoCallback ? self.ssoCallback(respObj) : nil;
        return;
    }
    
    // https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", kXMShareWeixinAppID, kXMShareWeixinAppSecret, _code];
        NSString *accessTokenString = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [accessTokenString dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                _accessToken = [dic objectForKey:@"access_token"];
                _openId = [dic objectForKey:@"openid"];
            } else {
                respObj.errCode = kXMSSOErrorCodeGetTokenFailure;
            }
            
            // get user infomation
            [self getUserInfoWithSSOObject:respObj];
        });
    });
}


- (void)getUserInfoWithSSOObject:(XMSSOResponseObject *)respObj
{
    if (!_accessToken || !_openId) {
        self.ssoCallback ? self.ssoCallback(respObj) : nil;
        return;
    }
    
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", _accessToken, _openId];
        NSString *userInfoString = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [userInfoString dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
                XMUserObject *userObj = [[XMUserObject alloc] init];
                userObj.nickName = [dic objectForKey:@"nickname"];;
                userObj.headImgUrl = [dic objectForKey:@"headimgurl"];
                userObj.openId = _openId;
                
                respObj.userObject = userObj;
                respObj.errCode = kXMSSOErrorCodeSuccess;
            } else {
                respObj.errCode = kXMSSOErrorCodeGetUserInfoFailure;
            }
            
            self.ssoCallback ? self.ssoCallback(respObj) : nil;
        });
    });
}


#pragma mark - weixin delegate

- (void)onReq:(BaseReq *)req
{
    
}


- (void)onResp:(BaseResp *)resp
{
    XMShareErrorCode errorCode = self.errCode;
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        self.isShareCtl = YES;
        
        switch (resp.errCode) {
            case WXSuccess: {
                errorCode = kXMErrorCodeSuccess;
            }
                break;
                
            case WXErrCodeUserCancel: {
                errorCode = kXMErrorCodeCanceled;
            }
                break;
                
            case WXErrCodeSentFail: {
                errorCode= kXMErrorCodeFailed;
            }
                break;
                
            case WXErrCodeAuthDeny: {
                errorCode = kXMErrorCodeAuthDeny;
            }
                break;
                
            case WXErrCodeUnsupport: {
                errorCode = kXMErrorCodeUnSupported; //分享渠道不支持
            }
                break;
                
            case WXErrCodeCommon: {
                errorCode = kXMErrorCodeParametersInvalid;
            }
                break;
                
            default: {
                errorCode = kXMErrorCodeUnknown;
            }
                break;
        }
        
        [self setErrCode:errorCode];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"from Weixin onResp");
        [self responseShareCompletionHandler];
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        // 1. get code
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.errCode == 0) {
            _code = authResp.code;
        }
        
        XMSSOResponseObject<SendAuthResp *> *respObj = [[XMSSOResponseObject alloc] init];
        respObj.respObj = authResp;
        respObj.errCode = (authResp.errCode == 0) ? kXMSSOErrorCodeUnknown : kXMSSOErrorCodeAuthFailure;
        
        // 2. get accessToken and openId
        [self getAccessTokenWithSSOObject:respObj];
    }
}

@end


/**
 *  腾讯QQApiInterfaceDelegate代理实现
 */
@implementation XMQQOperationImpl

#pragma mark - QQ delegate

- (void)isOnlineResponse:(NSDictionary *)response
{
    [super isOnlineResponse:response];
}


- (void)onReq:(QQBaseReq *)req
{

}


- (void)onResp:(QQBaseResp *)resp
{
    XMShareErrorCode errorCode = self.errCode;
    
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        self.isShareCtl = YES;
        
        if (resp.result && [resp.result length] != 0) {
            if ([resp.result isEqualToString:@"0"]) {
                errorCode = kXMErrorCodeSuccess;
            } else if ([resp.result isEqualToString:@"-1"]) {
                errorCode = kXMErrorCodeParametersInvalid;
            } else if ([resp.result isEqualToString:@"-2"]) {
                errorCode = kXMErrorCodeUnknown;
            } else if ([resp.result isEqualToString:@"-3"]) {
                errorCode = kXMErrorCodeSendRequestFailed;
            } else if ([resp.result isEqualToString:@"-4"]) {
                errorCode = kXMErrorCodeCanceled;
            } else if ([resp.result isEqualToString:@"-5"]) {
                errorCode = kXMErrorCodeSendRequestFailed;
            }
        }
        
        [self setErrCode:errorCode];
        XM_SHARE_VLOG(self.errCode, [self errMessageString], @"from QQ onResp");
        [self responseShareCompletionHandler];
    }
}

@end



/**
 *  微博WeiboSDKDelegate代理实现
 */
@implementation XMWBOperationImpl

#pragma mark - weibo SDK delegate

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    [super didReceiveWeiboResponse:response];
    
    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        self.isShareCtl = YES;
        
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        wbAccessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        wbCurrentUserID = [sendMessageToWeiboResponse.authResponse userID];
        wbRefreshToken = [sendMessageToWeiboResponse.authResponse refreshToken];
        
    } else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        wbAccessToken = [authResponse accessToken];
        wbCurrentUserID = [authResponse userID];
        wbRefreshToken = [authResponse refreshToken];
    }

    XMShareErrorCode errorCode = self.errCode;
    switch (response.statusCode) {
        case WeiboSDKResponseStatusCodeSuccess: {
            errorCode = kXMErrorCodeSuccess;
        }
            break;
            
        case WeiboSDKResponseStatusCodeUserCancel: {
            errorCode = kXMErrorCodeCanceled;
        }
            break;
            
        case WeiboSDKResponseStatusCodeSentFail: {
            errorCode = kXMErrorCodeSendRequestFailed;
        }
            break;
            
        case WeiboSDKResponseStatusCodeShareInSDKFailed: {
            errorCode = kXMErrorCodeFailed;
        }
            break;
            
        case WeiboSDKResponseStatusCodeAuthDeny: {
            errorCode = kXMErrorCodeAuthDeny;
        }
            break;
            
        case WeiboSDKResponseStatusCodeUnsupport: {
            errorCode = kXMErrorCodeUnSupported;
        }
            break;
            
        case WeiboSDKResponseStatusCodeUserCancelInstall: {
            errorCode = kXMErrorCodeAppNotInstalled;
        }
            break;
            
        case WeiboSDKResponseStatusCodePayFail:
        case WeiboSDKResponseStatusCodeUnknown: {
            errorCode = kXMErrorCodeUnknown;
        }
            break;
            
        default: {
            errorCode = kXMErrorCodeUnknown;
        }
            break;
    }
    
    [self setErrCode:errorCode];
     XM_SHARE_VLOG(self.errCode, [self errMessageString], @"from Weibo didReceiveWeiboResponse");
    [self responseShareCompletionHandler];
}


- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    [super didReceiveWeiboRequest:request];
}

@end
