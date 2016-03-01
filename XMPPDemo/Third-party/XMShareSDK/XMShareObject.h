//
//  XMShareObject.h
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMShareDef.h"


/**
 *  通知名, 注册该通知后, 图片下载完成将接收到该通知
 */
extern NSString * const kXMShareImageDownloadCompletionKey;

/**
 *  图片下载进度key
 */
extern NSString * const kXMShareImageDownloadProgressKey;

/**
 *  当前图片下载归属于某个opertion的Key
 */
extern NSString * const kXMShareImageDownloadForOperationKey;


/**
 *  图片下载进度标识
 */
typedef NS_ENUM(NSUInteger, XMImageDownloadProgress){
    /**
     *  没有开始下载
     */
    kXMImageDownloadNoTask = 0,
    /**
     *  下载中
     */
    kXMImageDownloading,
    /**
     *  下载完成
     */
    kXMImageDownloadCompleted,
    /**
     *  下载失败
     */
    kXMImageDownloadFailed,
    /**
     *  下载未知错误
     */
    kXMImageDownloadUnkownError,
};


/**
 *  分享内容的类型
 */
typedef NS_ENUM(NSUInteger, XMShareObjectType) {
    kXMShareObjectTypeText    = 0,
    kXMShareObjectTypeWebpage = 1,
    kXMShareObjectTypeImage   = 2,
    kXMShareObjectTypeAudio   = 3,
    kXMShareObjectTypeUnknown = 4
};


/**
 *  分享图片对象实体
 */
@interface XMShareImageObject : NSObject

/**
 *  当前图片下载归属于某次操作
 */
@property (nonatomic, copy) NSString *operationID;

/**
 *  图片对象
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  图片对象的Url地址
 */
@property (nonatomic, copy) NSString *imageUrl;


/**
 *  使用图片名称创建分享图片对象
 *
 *  @param imageName 图片名称
 *
 *  @return 分享图片对象
 */
+ (XMShareImageObject *)imageObjectWithImageName:(NSString *)imageName;


/**
 *  使用UIImage对象创建分享图片对象
 *
 *  @param image UIImage对象
 *
 *  @return 分享图片对象
 */
+ (XMShareImageObject *)imageObjectWithImage:(UIImage *)image;

/**
 *  使用图片url地址创建分享图片对象
 *
 *  @param image 图片url地址
 *
 *  @return 分享图片对象
 */
+ (XMShareImageObject *)imageObjectWithImageUrl:(NSString *)imageUrl;

/**
 *  使用图片数据创建分享图片对象
 *
 *  @param imageData 图片数据
 *
 *  @return 分享图片对象
 */
+ (XMShareImageObject *)imageObjectWithImageData:(NSData *)imageData;

@end


/**
 *  分享对象实体
 */
@interface XMShareObject : NSObject

/**
 *  当前分享内容的类型，默认值为kXMShareObjectTypeText
 */
@property (nonatomic, assign) XMShareObjectType type;


/**
 *  标题
 */
@property (nonatomic, copy) NSString  *title;


/**
 *  内容
 */
@property (nonatomic, copy) NSString  *content;


/**
 *  缩略图图片对象
 */
@property (nonatomic, strong) XMShareImageObject *thumbImageObject;


/**
 *  webpage的URL字符串
 */
@property (nonatomic, copy) NSString  *webpageUrl;


/**
 *  图片分享形式的图片对象
 */
@property (nonatomic, strong) XMShareImageObject *imageObject;


/**
 *  音频URL
 */
@property (nonatomic, copy) NSString *audioUrl;


/**
 *  字典，对不同分享平台存储不同的分享对象
 */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, XMShareObject *> *platformDictionary;


/**
 *  扩展字段，为了添加一些额外的信息，如信息来源......
 */
@property (nonatomic, strong) NSDictionary *extInfo;


/**
 *  由JS协议发起分享时，使用此方法生成一个分享对象
 *
 *  @param data 由JS协议发起分享时，嵌在URL中的数据
 *
 *  @return 分享对象
 */
+ (XMShareObject *)objectWithRawData:(NSDictionary *)data;


/**
 *  纯文本分享对象
 *
 *  @param title   分享标题
 *  @param content 分享内容
 *
 *  @return 文本分享对象
 */
+ (XMShareObject *)textObjectWithTitle:(NSString *)title
                                content:(NSString *)content;


/**
 *  网页分享
 *
 *  @param title      分享标题
 *  @param content    分享内容
 *  @param thumbImage 分享缩略图
 *  @param linkUrl    分享的链接地址
 *
 *  @return 网页分享对象
 */
+ (XMShareObject *)webpageObjectWithTitle:(NSString *)title
                                   content:(NSString *)content
                                thumbImage:(XMShareImageObject *)thumbImageObject
                                webpageURL:(NSString *)webpageUrl;


/**
 *  图片分享对象
 *
 *  @param title      分享标题
 *  @param content    分享内容
 *  @param thumbImage 分享缩略图
 *  @param image      分享的图片对象
 *
 *  @return 图片分享对象
 */
+ (XMShareObject *)imageObjectWithTitle:(NSString *)title
                                 content:(NSString *)content
                              thumbImage:(XMShareImageObject *)thumbImageObject
                                   image:(XMShareImageObject *)imageObject;


/**
 *  音频分享对象
 *
 *  @param title      分享标题
 *  @param content    分享内容
 *  @param thumbImage 分享缩略图，使用本地图片，当时用网络图片时，直接设为空，并设置thumbImageUrl
 *  @param webpageUrl 分享的网页链接
 *  @param audioUrl   分享的音频地址
 *
 *  @return 音频分享对象
 */
+ (XMShareObject *)audioObjectWithTitle:(NSString *)title
                                 content:(NSString *)content
                              thumbImage:(XMShareImageObject *)thumbImageObject
                              webpageURL:(NSString *)webpageUrl
                                audioURL:(NSString *)audioUrl;


/**
 *  对某个具体的平台设置分享内容
 *
 *  @param shareObject 分享内容
 *  @param platform    平台名
 */
- (void)addShareObject:(XMShareObject *)shareObject forPlatform:(NSString *)platform;


/**
 *  是否正在下载图片
 *
 *  @return 下载进度标志，YES表示图片正在下载中，NO表示图片已下载完成
 */
- (BOOL)isImageDownloading;


#pragma mark - helper for getting send object

- (QQApiObject *)qqRequestObject;

- (SendMessageToWXReq *)weixinRequestObject;

- (WBMessageObject *)weiboRequestObject;

@end



#pragma mark - XMShareUtility
/**
 *  分享内容规范化辅助类
 */
@interface XMShareUtility : NSObject

+ (NSString *)normalizedTitleString:(NSString *)string forPlatform:(XMSharePlatform)platform forType:(XMShareObjectType)type;
+ (NSString *)normalizedContentString:(NSString *)string forPlatform:(XMSharePlatform)platform forType:(XMShareObjectType)type;
+ (XMShareImageObject *)normalizedImageObject:(XMShareImageObject *)imageObject forPlatform:(XMSharePlatform)platform isThumbImage:(BOOL)isThumbImage;
+ (NSData *)normalizedImage:(UIImage *)image forPlatform:(XMSharePlatform)platform;
+ (NSData *)normalizedThumbImage:(UIImage *)image forPlatform:(XMSharePlatform)platform;
+ (BOOL)isWebpageUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform;
+ (BOOL)isAudioUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform;
+ (BOOL)isThumbImageUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform;
+ (BOOL)isImageUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform;

@end

