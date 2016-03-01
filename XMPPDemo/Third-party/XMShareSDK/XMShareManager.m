//
//  XMShareManager.m
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import "XMShareManager.h"
#import "XMShareObject.h"
#import "XMShareView.h"
#import "XMTranslucencyView.h"
#import "XMShareOperation.h"
#import "BTMToast.h"


/**
 *  Extension for XMShareManager
 */
@interface XMShareManager ()
<
XMSharePanelDelegate
>

@property (nonatomic, assign) BOOL canWBH5Auth; //默认不打开
@property (nonatomic, strong) TencentOAuth *QQAuth;
@property (nonatomic, strong) XMSharePanel *sharePanel;

/**
 *  分享操作实例字典，每个分享渠道一次只能有一个shareOperation（不能并行），否则后面会替换掉前面的
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, XMShareOperation *> *operationInsts;

@end



/**
 * 分享管理器
 */
@implementation XMShareManager

#pragma mark - singleton
/**
 *  分享管理器单例
 *
 *  @return 分享管理器实例
 */
+ (XMShareManager *)sharedManager
{
    static XMShareManager *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInst) {
            sharedInst = [[XMShareManager alloc] init];
        }
    });
    return sharedInst;
}


- (instancetype)init
{
    if ((self = [super init])) {
        self.canWBH5Auth = NO;
        self.operationInsts = [NSMutableDictionary<NSNumber *, XMShareOperation *> dictionaryWithCapacity:3];
    }
    return self;
}


+ (BOOL)registerChannelAppId
{
    BOOL successRegister = YES;
    
    successRegister = successRegister && [[XMShareManager sharedManager] registerAppID:kXMShareWeixinAppID forChannel:kXMShareChannelWeixin];
    successRegister = successRegister && [[XMShareManager sharedManager] registerAppID:kXMShareQQAppID forChannel:kXMShareChannelQQ];
    successRegister = successRegister &&  [[XMShareManager sharedManager] registerAppID:kXMShareWeiboAppID forChannel:kXMShareChannelSinaWeibo];
    
    return successRegister;
}


- (BOOL)registerAppID:(NSString *)appID forChannel:(XMShareChannelType)channel
{
    BOOL successRegister = NO;
    
    switch (channel) {
        case kXMShareChannelWeixin: {
            successRegister = [WXApi registerApp:appID withDescription:@"XMShareSDKForWeixin"];
        }
            break;
            
        case kXMShareChannelQQ: {
            self.QQAuth = [[TencentOAuth alloc] initWithAppId:appID andDelegate:nil];
            if (self.QQAuth) {
                successRegister = YES;
            }
        }
            break;
            
        case kXMShareChannelBaiduHi: {
            successRegister = NO;
        }
            break;
            
        case kXMShareChannelSinaWeibo: {
#if DEBUG
            [WeiboSDK enableDebugMode:YES];
#else
            [WeiboSDK enableDebugMode:NO];
#endif
            successRegister = [WeiboSDK registerApp:appID];
        }
            break;
            
        default:
            break;
    }
    
    return successRegister;
}


#pragma mark - open schemaUrl

- (BOOL)handleOpenURL:(NSURL *)url
{
    BOOL isHandled = NO;
    for (XMShareOperation *shareOperation in [self.operationInsts allValues]) {

        switch (shareOperation.channel) {
            case kXMShareChannelWeixin: {
                isHandled = [WXApi handleOpenURL:url delegate:shareOperation];
            }
                break;
                
            case kXMShareChannelQQ: {
                //#if __QQAPI_ENABLE__
                isHandled = [QQApiInterface handleOpenURL:url delegate:shareOperation];
                //#endif
                //            if ([TencentOAuth CanHandleOpenURL:url] == YES) {
                //                isHandled = [TencentOAuth HandleOpenURL:url];
                //            }
            }
                break;
                
            case kXMShareChannelSinaWeibo: {
                isHandled = [WeiboSDK handleOpenURL:url delegate:shareOperation];
            }
                break;
                
            case kXMShareChannelBaiduHi: {
                
            }
                break;
                
            default: {
                
            }
                break;
        }
        isHandled = isHandled && shareOperation.isShareCtl;
        
        XM_SHARE_LOG(@"shareChannel = %ld, url = %@, isHandled = %d", (long)shareOperation.channel, [url absoluteString], isHandled);
        
        if (isHandled) {
            [self.operationInsts removeObjectForKey:@(shareOperation.channel)];
            break;
        }
    }
    
    return isHandled;
}


- (void)openWBAuthShare:(BOOL)opened
{
    self.canWBH5Auth = opened;
}


#pragma mark - setter/getter property

- (void)setAlphaColor:(UIColor *)alphaColor
{
    _alphaColor = alphaColor;
}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
}


- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
}


- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
}


#pragma mark - XMSharePanelDelegate
/**
 *  响应可见面板中分享平台的点击事件
 *
 *  @param aView 显示的面板
 *  @param index 面板中被点击平台的索引，第一个平台索引为0，依次类推...
 */
- (void)sharePanel:(XMSharePanel *)sharePanel didTapWithPlatformIndex:(NSUInteger)tappedIndex
{
    __weak typeof(self) weakSelf = self;
    XMAnimationCompletionHandler dismissCompletionHandler = ^(BOOL finished) {
        // commit share operation
        XM_SHARE_LOG(@"tappedIndex = %ld", (long)tappedIndex);
        
        __weak typeof(weakSelf) strongSelf = weakSelf;
        XMShareOperation *shareOperation = [XMShareOperation operationWithPlatform:sharePanel.platforms[tappedIndex] shareObject:sharePanel.shareObject completionHandler:sharePanel.completionHandler];
        [shareOperation setCanWBH5Auth:self.canWBH5Auth];
        [shareOperation commitOperationWithProgressHUD:YES];
        
        strongSelf.operationInsts[@(shareOperation.channel)] = shareOperation;
        strongSelf.sharePanel = nil;
    };
    
    [sharePanel dismissWithCompletionHandler:dismissCompletionHandler];
}

@end



@implementation XMShareManager (XMSharePanel)

- (XMShareView *)shareViewWithPanel:(XMSharePanelStyle)panel shareObject:(XMShareObject *)shareObject platforms:(NSArray<NSString *> *)platforms
{
    return [[XMSharePanel sharePanelWithStyle:panel] containerView];
}


#pragma mark - show share panel

- (void)showWithShareObject:(XMShareObject *)shareObject completionHandler:(XMShareOperationCompletionHandler)completionHandler
{
    NSArray *defaultPlatforms = @[
                                  kXM_SHARE_PLATFORM_WEIXIN_SESSION,
                                  kXM_SHARE_PLATFORM_WEIXIN_TIMELINE,
                                  kXM_SHARE_PLATFORM_QQ_FRIEND,
                                  kXM_SHARE_PLATFORM_QQ_ZONE,
                                  kXM_SHARE_PLATFORM_SINAWEIBO,
                                  kXM_SHARE_PLATFORM_COPY_LINK,
                                  kXM_SHARE_PLATFORM_SMS,
                                  kXM_SHARE_PLATFORM_EMAIL,
                                  ];
////     TEST:
//    NSInteger random = arc4random() % 20;
//    NSMutableArray *platforms = [NSMutableArray array];
//    for (NSInteger i = 0; i < random; i++) {
//        [platforms addObject:kXM_SHARE_PLATFORM_WEIXIN_SESSION];
//    }
//    for (NSInteger i = 0; i < random; i++) {
//        [platforms addObject:kXM_SHARE_PLATFORM_SMS];
//    }
    [self showWithShareObject:shareObject platforms:defaultPlatforms completionHandler:completionHandler];
}




- (void)showWithShareObject:(XMShareObject *)shareObject platforms:(NSArray<NSString *> *)platforms completionHandler:(XMShareOperationCompletionHandler)completionHandler
{
    [self showWithPanel:kXMSharePanelDefault shareObject:shareObject platforms:platforms completionHandler:completionHandler];
}


- (void)showWithPanel:(XMSharePanelStyle)panel shareObject:(XMShareObject *)shareObject platforms:(NSArray<NSString *> *)platforms completionHandler:(XMShareOperationCompletionHandler)completionHandler
{
    if (!XM_IsNetworkReachability) {
        XM_SHARE_LOG(@"网络连接失败不呼出分享模块");
        [[BTMToast sharedInstance] showToast:@"网络连接失败不呼\n出分享模块"];
        return;
    }
    
    if ([XMSharePanel isShowing]) {
        return;
    }
    
    XMSharePanel *sharePanel = [XMSharePanel sharePanelWithStyle:panel];
    [sharePanel setDelegate:self];
    [sharePanel setCompletionHandler:completionHandler];
    [sharePanel setWillBeDisplayedPlatforms:platforms shareObject:shareObject];

    if (self.sharePanel) {
        __weak typeof(self) weakSelf = self;
        [self.sharePanel dismissWithCompletionHandler:^(BOOL finished) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [sharePanel showWithCompletionHandler:nil];
            strongSelf.sharePanel = sharePanel;
        }];
    } else {
        [sharePanel showWithCompletionHandler:nil];
         self.sharePanel = sharePanel;
    }
}


- (void)closeSharePanel {
    __weak typeof(self) weakSelf = self;
    [self.sharePanel dismissWithCompletionHandler:^(BOOL finished) {
        weakSelf.sharePanel = nil;
    }];
}

@end


@implementation XMShareManager (SSOAuthLogin)

- (void)weixinSSOWithResponse:(XMSSOResponseHandler)respBlock {
    XMShareOperation *shareOperation = [XMShareOperation operationForChannel:kXMShareChannelWeixin SSOResponseHandler:respBlock fromViewController:nil];
    self.operationInsts[@(shareOperation.channel)] = shareOperation;
    
    [shareOperation commitSSOAuth];
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//                                    END XMShareManager
//
////////////////////////////////////////////////////////////////////////////////////////////////////////