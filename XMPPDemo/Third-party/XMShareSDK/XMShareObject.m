//
//  XMShareObject.m
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import <objc/runtime.h>
#import "XMShareObject.h"
#import "SDWebImageManager.h"


NSString * const kXMShareImageDownloadCompletionKey   = @"XMShareImageDownloadCompletion";
NSString * const kXMShareImageDownloadProgressKey     = @"XMShareImageDownloadProgress";
NSString * const kXMShareImageDownloadForOperationKey = @"XMShareImageDownloadForOperation";


/**
 * 定义所有平台的将分享数据的限制
 */
#define kMaxTitleStringDataLengthOfWeixin   (512)
#define kMaxTitleStringLengthOfQQ           (128)
#define kMaxTitleStringLengthOfWeibo        (140 * 2)

#define kMaxContentStringDataLengthOfWeixin (1024)
#define kMaxContentStringLengthOfQQ         (512) // 官网：512字符
#define kMaxContentStringLengthOfWeibo      (140 * 2) // 官网：140个汉字，经大量测试，为280字节

#define kMaxImageDataLengthOfWeixin         (10 * 1024 * 1024)
#define kMaxImageDataLengthOfQQ             (5 * 1024 * 1024)
#define kMaxImageDataLengthOfWeibo          (10 * 1024 * 1024)

#define kMaxThumbImageDataLengthOfWeixin    (32 * 1024)
#define kMaxThumbImageDataLengthOfQQ        (1 * 1024 * 1024)
#define kMaxThumbImageDataLengthOfWeibo     (32 * 1024)

#define kMaxUrlStringDataLengthOfWeixin     (1024)
#define kMaxUrlStringLengthOfQQ             (512)
#define kMaxUrlStringLengthOfWeibo          (255)

#define kMaxMediaTitleStringLengthOfWeibo   (1 * 1024)
#define kMaxMediaContentStringLengthOfWeibo (1 * 1024)



/**
 *  Extension Of XMShareImageObject
 */
@interface XMShareImageObject ()
//<
//NSCopying
//>

/**
 *  图片数据
 */
@property (nonatomic, strong) NSData *imageData;

/**
 *  是否正在下载图片
 */
@property (nonatomic, assign) XMImageDownloadProgress isImageDownloading;

@end


@implementation XMShareImageObject

- (NSString *)description
{
    NSString *despString = nil;
    if (self.imageUrl) {
        despString = [NSString stringWithFormat:@"imageUrl = %@", self.imageUrl];
    } else {
       despString = [NSString stringWithFormat:@"image = %@", self.image];
    }
    return despString;
}


+ (XMShareImageObject *)imageObjectWithImageName:(NSString *)imageName
{
    if (!imageName) {
        return nil;
    } else {
        return [XMShareImageObject imageObjectWithImage:[UIImage imageNamed:imageName]];
    }
}


+ (XMShareImageObject *)imageObjectWithImage:(UIImage *)image
{
    return [XMShareImageObject imageObjectWithImage:image imageUrl:nil imageData:nil];
}


+ (XMShareImageObject *)imageObjectWithImageUrl:(NSString *)imageUrl
{
    return [XMShareImageObject imageObjectWithImage:nil imageUrl:imageUrl imageData:nil];
}


+ (XMShareImageObject *)imageObjectWithImageData:(NSData *)imageData
{
    return [XMShareImageObject imageObjectWithImage:nil imageUrl:nil imageData:imageData];
}


+ (XMShareImageObject *)imageObjectWithImage:(UIImage *)image imageUrl:(NSString *)imageUrl imageData:(NSData *)imageData
{
    XMShareImageObject *imageObject = [XMShareImageObject new];
    imageObject.isImageDownloading = kXMImageDownloadNoTask;
    imageObject.image = image;
    imageObject.imageUrl = imageUrl;
    imageObject.imageData = imageData;
    return imageObject;
}


#pragma mark - setter property

- (void)setImageUrl:(NSString *)imageUrl
{
    if (imageUrl) {
        _imageUrl = imageUrl;
        self.isImageDownloading = kXMImageDownloading;
        
        __weak typeof(self) wself = self;
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            // begin progressBar
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            // load image and stop progressBar
            
            if (finished &&[image isKindOfClass:[UIImage class]]) {
                wself.image = image;
                wself.isImageDownloading = kXMImageDownloadCompleted;
            } else {
                wself.isImageDownloading = kXMImageDownloadFailed;
            }
            
            XM_SHARE_LOG(@"<Source : shareSDK>\t finished = %d, cacheType = %ld, error = %@", finished, (long)cacheType, error);
            
            NSMutableDictionary *userInfo = [@{kXMShareImageDownloadProgressKey:@(wself.isImageDownloading)} mutableCopy];
            if ([wself.operationID length] != 0) {
                userInfo[kXMShareImageDownloadForOperationKey] = wself.operationID;
            }
                                                  
            [[NSNotificationCenter defaultCenter] postNotificationName:kXMShareImageDownloadCompletionKey object:nil userInfo:userInfo];
        }];
    }
}


- (void)setImage:(UIImage *)image
{
    if (image) {
        _image     = image;
        _imageData = UIImageJPEGRepresentation(image, 1.f);
    }
}


- (void)setImageData:(NSData *)imageData
{
    if (imageData) {
        _imageData = imageData;
        _image     = [UIImage imageWithData:imageData];
    }
}

@end




/**
 *  Extension Of XMShareObject
 */
@interface XMShareObject ()
<
NSCopying
>

@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, XMShareObject *> *platformDictionary;

@end


/**
 * Implementation Of XMShareObject
 */
#pragma mark - XMShareObject

@implementation XMShareObject


- (instancetype)init
{
    if ((self = [super init])) {
        [self _baseInit];
    }
    return self;
}


- (void)_baseInit
{
    _type = kXMShareObjectTypeWebpage;
    _title = nil;
    _content = nil;
    _webpageUrl = nil;
    _thumbImageObject = nil;
    _imageObject = nil;
    _audioUrl = nil;
    _extInfo = nil;
    _platformDictionary = nil;
}


- (NSString *)description
{
    NSString *despString = [NSString stringWithFormat:@"type = %lu,\ntitle = %@,\ncontent = %@,\nwebpageUrl = %@,\naudioUrl = %@,\nthumbImageObject =  [%@],\nimageObject = [%@]", (unsigned long)self.type, self.title, self.content, self.webpageUrl, self.audioUrl, self.thumbImageObject, self.imageObject];
    return despString;
}


+ (XMShareObject *)objectWithRawData:(NSDictionary *)data
{
    if (!data) {
        return nil;
    }
    
    // parse Dictionary
    NSNumber *shareType = data[@"type"];
    NSString *shareTitle = data[@"title"];
    NSString *shareContent = data[@"content"];
    NSString *shareWebpageUrl = data[@"url"];
    NSString *shareThumbImageUrl = data[@"imgUrl"];
    NSString *shareImageUrl = data[@"imageobjecturl"];
    NSString *shareAudioUrl = data[@"audiourl"];
   
    XMShareImageObject *thumbImageObject = nil;
    XMShareImageObject *imageObject = nil;
    
    if (!shareType) {
        shareType = @(kXMShareObjectTypeWebpage);
    }
    
    if (shareThumbImageUrl) {
        thumbImageObject = [XMShareImageObject imageObjectWithImageUrl:shareThumbImageUrl];
    }
    
    if (shareImageUrl) {
        imageObject = [XMShareImageObject imageObjectWithImageUrl:shareImageUrl];
    }
    
    return [XMShareObject p_shareObjectWithType:[shareType integerValue]
                                           title:shareTitle
                                         content:shareContent
                                      webpageURL:shareWebpageUrl
                                      thumbImage:thumbImageObject
                                           image:imageObject
                                        audioURL:shareAudioUrl];
}


+ (XMShareObject *)textObjectWithTitle:(NSString *)title
                                content:(NSString *)content
{
    return [XMShareObject p_shareObjectWithType:kXMShareObjectTypeText
                                           title:title
                                         content:content
                                      webpageURL:nil
                                      thumbImage:nil
                                           image:nil
                                        audioURL:nil];
}


+ (XMShareObject *)webpageObjectWithTitle:(NSString *)title
                                   content:(NSString *)content
                                thumbImage:(XMShareImageObject *)thumbImageObject
                                webpageURL:(NSString *)webpageUrl
{
    return [XMShareObject p_shareObjectWithType:kXMShareObjectTypeWebpage
                                           title:title
                                         content:content
                                      webpageURL:webpageUrl
                                      thumbImage:thumbImageObject
                                           image:nil
                                        audioURL:nil];
}


+ (XMShareObject *)imageObjectWithTitle:(NSString *)title
                                 content:(NSString *)content
                              thumbImage:(XMShareImageObject *)thumbImageObject
                                   image:(XMShareImageObject *)imageObject
{
    return [XMShareObject p_shareObjectWithType:kXMShareObjectTypeImage
                                           title:title
                                         content:content
                                      webpageURL:nil
                                      thumbImage:thumbImageObject
                                           image:imageObject
                                        audioURL:nil];
}


+ (XMShareObject *)audioObjectWithTitle:(NSString *)title
                                 content:(NSString *)content
                              thumbImage:(XMShareImageObject *)thumbImageObject
                              webpageURL:(NSString *)webpageUrl
                                audioURL:(NSString *)audioUrl
{
    return [XMShareObject p_shareObjectWithType:kXMShareObjectTypeAudio
                                           title:title
                                         content:content
                                      webpageURL:webpageUrl
                                      thumbImage:thumbImageObject
                                           image:nil
                                        audioURL:audioUrl];
}


- (BOOL)isImageDownloading
{
    BOOL isImageDownloading = NO;
    
    if (self.thumbImageObject) {
        isImageDownloading = isImageDownloading || (self.thumbImageObject.isImageDownloading == kXMImageDownloading);
    }
    
    if (self.imageObject) {
        isImageDownloading = isImageDownloading || (self.imageObject.isImageDownloading == kXMImageDownloading);
    }
    
    return isImageDownloading;
}


- (id)copyWithZone:(NSZone *)zone
{
    XMShareObject *newObject = [[XMShareObject alloc] init];
    
    newObject.type = self.type;
    newObject.title = self.title;
    newObject.content = self.content;
    newObject.webpageUrl = self.webpageUrl;
    newObject.thumbImageObject = self.thumbImageObject;
    newObject.imageObject = self.imageObject;
    newObject.extInfo = self.extInfo;
    newObject.platformDictionary = self.platformDictionary;
    
    return newObject;
}


#pragma mark - private method

+ (XMShareObject *)p_shareObjectWithType:(XMShareObjectType)objectType
                                    title:(NSString *)title
                                  content:(NSString *)content
                               webpageURL:(NSString *)webpageUrl
                               thumbImage:(XMShareImageObject *)thumbImageObject
                                    image:(XMShareImageObject *)imageObject
                                 audioURL:(NSString *)audioUrl
{
    XMShareObject *shareObject = [[XMShareObject alloc] init];
    
    shareObject.type = objectType;
    shareObject.title = title;
    shareObject.content = content;
    shareObject.webpageUrl = webpageUrl;
    shareObject.thumbImageObject = thumbImageObject;
    shareObject.imageObject = imageObject;
    shareObject.audioUrl = audioUrl;
    
    return shareObject;
}


/**
 *  对某个具体的平台设置分享内容
 *
 *  @param shareObject 分享内容
 *  @param platform    平台名
 */
- (void)addShareObject:(XMShareObject *)shareObject forPlatform:(NSString *)platform
{
    if (shareObject && platform) {
        [self.platformDictionary setObject:shareObject forKey:platform];
    }
}


#pragma mark - setter/getter property

- (NSMutableDictionary<NSString *, XMShareObject *> *)platformDictionary
{
    if (!_platformDictionary) {
        _platformDictionary = [NSMutableDictionary<NSString *, XMShareObject *> dictionary];
    }
    return _platformDictionary;
}


#pragma mark - obtain platform request object

/**
 *  将分享对象实体转化为QQ请求对象
 *
 *  @return QQ请求实例
 */
- (QQApiObject *)qqRequestObject
{
    QQApiObject *requestObject = nil;
    switch (self.type) {
        case kXMShareObjectTypeText: {
            NSString *text = self.content;
            requestObject = [QQApiTextObject objectWithText:text];
        }
            break;
            
        case kXMShareObjectTypeWebpage: {
            if (self.thumbImageObject.imageData) {
                requestObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.webpageUrl]
                                                         title:self.title
                                                   description:self.content
                                              previewImageData:self.thumbImageObject.imageData];
            } else {
                requestObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:self.webpageUrl]
                                                         title:self.title
                                                   description:self.content
                                               previewImageURL:[NSURL URLWithString:self.thumbImageObject.imageUrl]];
            }
        }
            break;
            
        case kXMShareObjectTypeImage: {
            requestObject = [QQApiImageObject objectWithData:self.imageObject.imageData
                                            previewImageData:self.thumbImageObject.imageData
                                                       title:self.title
                                                 description:self.content];
        }
            break;
            
        case kXMShareObjectTypeAudio: {
            if (self.thumbImageObject.imageData) {
                requestObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:self.webpageUrl]
                                                          title:self.title
                                                    description:self.content
                                               previewImageData:self.thumbImageObject.imageData];
            } else {
                requestObject = [QQApiAudioObject objectWithURL:[NSURL URLWithString:self.webpageUrl]
                                                          title:self.title
                                                    description:self.content
                                                previewImageURL:[NSURL URLWithString:self.thumbImageObject.imageUrl]];
            }
        }
            break;
            
        default: {
            XM_SHARE_LOG(@"Unknown share object, unSupported ~^~");
        }
            break;
    }
    
    return requestObject;
}


/**
 *  将分享对象实体转化为微信请求对象
 *
 *  @return 微信请求实例
 */
- (SendMessageToWXReq *)weixinRequestObject
{
    SendMessageToWXReq *weixinRequest = [[SendMessageToWXReq alloc] init];
    weixinRequest.bText = (self.type == kXMShareObjectTypeText);
    
    switch (self.type) {
        case kXMShareObjectTypeText: {
            NSString *text = self.content;
            weixinRequest.text = text;
        }
            break;
            
        case kXMShareObjectTypeWebpage: {
            WXWebpageObject *webpageObject = [WXWebpageObject object];
            webpageObject.webpageUrl = self.webpageUrl ;
            
            WXMediaMessage *mediaMsg = [WXMediaMessage message];
            mediaMsg.title = self.title;
            mediaMsg.description = self.content;
            mediaMsg.thumbData = self.thumbImageObject.imageData;
            mediaMsg.mediaObject = webpageObject;
            
            weixinRequest.message = mediaMsg;
        }
            break;
            
        case kXMShareObjectTypeImage: {
            WXImageObject *imageObject = [WXImageObject object];
            imageObject.imageData = self.imageObject.imageData;
            imageObject.imageUrl = self.imageObject.imageUrl;
            
            WXMediaMessage *mediaMsg = [WXMediaMessage message];
            mediaMsg.title = self.title;
            mediaMsg.description = self.content;
            mediaMsg.messageExt = self.title;
            mediaMsg.mediaObject = imageObject;
            
            weixinRequest.message = mediaMsg;
        }
            break;
            
        case kXMShareObjectTypeAudio: {
            WXMusicObject *audioObject = [WXMusicObject object];
            audioObject.musicUrl = self.webpageUrl;
            audioObject.musicDataUrl = self.audioUrl;
            
            WXMediaMessage *mediaMsg = [WXMediaMessage message];
            mediaMsg.title = self.title;
            mediaMsg.description = self.content;
            mediaMsg.thumbData = self.thumbImageObject.imageData;
            mediaMsg.mediaObject = audioObject;
            
            weixinRequest.message = mediaMsg;
        }
            break;
            
        default: {
            XM_SHARE_LOG(@"Unknown share object, unSupported ~^~");
        }
            break;
    }
    
    return weixinRequest;
}


/**
 *  将分享对象实体转化为新浪微博请求对象
 *
 *  @return 微博请求实例
 */
- (WBMessageObject *)weiboRequestObject
{
    WBMessageObject *messageObject = [WBMessageObject message];
    switch (self.type) {
        case kXMShareObjectTypeText: {
            messageObject.text = self.content;
        }
            break;
            
        case kXMShareObjectTypeWebpage: {
            WBWebpageObject *webpageObject = [WBWebpageObject object];
            webpageObject.objectID = self.webpageUrl;
            webpageObject.title = self.title;
            webpageObject.description = self.content;
            webpageObject.thumbnailData = self.thumbImageObject.imageData;
            webpageObject.webpageUrl = self.webpageUrl;
            webpageObject.scheme = self.webpageUrl;
            
            messageObject.text = self.content;
            messageObject.mediaObject = webpageObject;
        }
            break;
            
        case kXMShareObjectTypeImage: {
            WBImageObject *imageObject = [WBImageObject object];
            imageObject.imageData = self.imageObject.imageData;
    
            messageObject.text = self.content;
            messageObject.imageObject = imageObject;
        }
            break;
            
        case kXMShareObjectTypeAudio: {
            WBMusicObject *audioObject = [WBMusicObject object];
            audioObject.title = self.title;
            audioObject.description = self.content;
            audioObject.thumbnailData = self.thumbImageObject.imageData;
            audioObject.musicUrl = self.webpageUrl;
            audioObject.musicStreamUrl = self.audioUrl;
            
            messageObject.text = self.content;
            messageObject.mediaObject = audioObject;
        }
            break;
            
        default: {
            XM_SHARE_LOG(@"Unknown share object, unSupported ~^~");
        }
            break;
    }
    
    return messageObject;
}

@end



/**
 *  Implementation Of XMShareUtility
 */
@implementation XMShareUtility

#pragma mark - public method of XMShareUtility

+ (NSString *)normalizedTitleString:(NSString *)string forPlatform:(XMSharePlatform)platform forType:(XMShareObjectType)type
{
    if (!string) {
        return string;
    }
    if (string.length == 0) {
        return @"";
    }
    
    NSString *subString = [string copy];
    
    BOOL isStringCutOff = NO;
    switch (platform) {
        case kXMSharePlatformWeixinSession:
        case kXMSharePlatformWeixinTimeline: {
            NSData *stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
            while (stringData.length > kMaxTitleStringDataLengthOfWeixin) {
                NSUInteger length = (NSUInteger)(((float)kMaxTitleStringDataLengthOfWeixin / (float)stringData.length) * (float)subString.length);
                subString = [string substringToIndex:length];
                stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
                isStringCutOff = YES;
            }
            if (isStringCutOff) {
                subString = [subString substringToIndex:subString.length - 3];
                subString = [subString stringByAppendingString:@"..."];
            }
        }
            break;
        case kXMSharePlatformQQFriend:
        case kXMSharePlatformQQZone: {
            if (subString.length > kMaxTitleStringLengthOfQQ) {
                subString = [subString substringToIndex:kMaxTitleStringLengthOfQQ - 3];
                subString = [subString stringByAppendingString:@"..."];
            }
        }
            break;
        case kXMSharePlatformSinaWeibo: {
            NSUInteger maxTextLengthOfWeibo = kMaxTitleStringLengthOfWeibo;
            NSData *stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
            BOOL isStringCutOff = NO;
            
            switch (type) {
                case kXMShareObjectTypeText:
                case kXMShareObjectTypeImage: {
                    maxTextLengthOfWeibo = kMaxTitleStringLengthOfWeibo;
                }
                    break;
                    
                default: { // Other: kXMShareObjectTypeWebpage, kXMShareObjectTypeAudio
                    maxTextLengthOfWeibo = kMaxMediaTitleStringLengthOfWeibo;
                }
                    break;
            }

            while (stringData.length > maxTextLengthOfWeibo) {
                NSUInteger length = (NSUInteger)(((float)maxTextLengthOfWeibo / (float)stringData.length) * (float)subString.length);
                subString = [string substringToIndex:length];
                stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
                isStringCutOff = YES;
            }
            if (isStringCutOff) {
                subString = [subString substringToIndex:subString.length - 3];
                subString = [subString stringByAppendingString:@"..."];
            }
        }
            break;
        case kXMSharePlatformSMS:
        case kXMSharePlatformEmail:
            break;
        default:
            break;
    }
    return subString;
}


+ (NSString *)normalizedContentString:(NSString *)string forPlatform:(XMSharePlatform)platform forType:(XMShareObjectType)type
{
    if (!string) {
        return string;
    }
    if (string.length == 0) {
        return @"";
    }
    
    NSString *subString = [string copy];
    
    switch (platform) {
        case kXMSharePlatformWeixinSession:
        case kXMSharePlatformWeixinTimeline: {
            NSData *stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
            BOOL isStringCutOff = NO;
            while (stringData.length > kMaxContentStringDataLengthOfWeixin) {
                NSUInteger length = (NSUInteger)(((float)kMaxContentStringDataLengthOfWeixin / (float)stringData.length) * (float)subString.length);
                subString = [string substringToIndex:length];
                stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
                isStringCutOff = YES;
            }
            if (isStringCutOff) {
                subString = [subString substringToIndex:subString.length - 3];
                subString = [subString stringByAppendingString:@"..."];
            }
        }
            break;
        case kXMSharePlatformQQFriend:
        case kXMSharePlatformQQZone: {
            if (subString.length > kMaxContentStringLengthOfQQ) {
                subString = [subString substringToIndex:kMaxContentStringLengthOfQQ - 3];
                subString = [subString stringByAppendingString:@"..."];
            }
        }
            break;
        case kXMSharePlatformSinaWeibo: {
            NSUInteger maxContentLengthOfWeibo = kMaxContentStringLengthOfWeibo;
            NSData *stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
            BOOL isStringCutOff = NO;
            
            switch (type) {
                case kXMShareObjectTypeText:
                case kXMShareObjectTypeImage: {
                    maxContentLengthOfWeibo = kMaxContentStringLengthOfWeibo;
                }
                    break;
                    
                default: { // Other: kXMShareObjectTypeWebpage, kXMShareObjectTypeAudio
                    maxContentLengthOfWeibo = kMaxMediaContentStringLengthOfWeibo;
                }
                    break;
            }
            
            while (stringData.length > maxContentLengthOfWeibo) {
                NSUInteger length = (NSUInteger)(((float)maxContentLengthOfWeibo / (float)stringData.length) * (float)subString.length);
                subString = [string substringToIndex:length];
                stringData = [subString dataUsingEncoding:NSUTF8StringEncoding];
                isStringCutOff = YES;
            }
            if (isStringCutOff) {
                subString = [subString substringToIndex:subString.length - 3];
                subString = [subString stringByAppendingString:@"..."];
            }
        }
            break;
        case kXMSharePlatformSMS:
        case kXMSharePlatformEmail:
            break;
        default:
            break;
    }
    
    return subString;
}


+ (XMShareImageObject *)normalizedImageObject:(XMShareImageObject *)imageObject forPlatform:(XMSharePlatform)platform isThumbImage:(BOOL)isThumbImage
{
    XMShareImageObject *newImageObject = imageObject;
    if (isThumbImage) {
        newImageObject.imageData = [XMShareUtility normalizedThumbImage:imageObject.image forPlatform:platform];
    } else {
        newImageObject.imageData = [XMShareUtility normalizedImage:imageObject.image forPlatform:platform];
    }
    return newImageObject;
}


+ (NSData *)normalizedImage:(UIImage *)image forPlatform:(XMSharePlatform)platform
{
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    NSUInteger maxImageDataLength = imageData.length;
    switch (platform) {
        case kXMSharePlatformWeixinSession:
        case kXMSharePlatformWeixinTimeline: {
            maxImageDataLength = kMaxImageDataLengthOfWeixin;
        }
            break;
        case kXMSharePlatformQQFriend:
        case kXMSharePlatformQQZone: {
            maxImageDataLength = kMaxImageDataLengthOfQQ;
        }
            break;
        case kXMSharePlatformSinaWeibo: {
            maxImageDataLength = kMaxImageDataLengthOfWeibo;
        }
            break;
        case kXMSharePlatformSMS:
        case kXMSharePlatformEmail:
            break;
        default:
            break;
    }
    
    while (imageData.length > maxImageDataLength) {
        CGFloat scale = (CGFloat)maxImageDataLength / (CGFloat)imageData.length;
        UIImage *tempImage = [UIImage imageWithData:imageData];
        imageData = UIImageJPEGRepresentation(tempImage, scale);
        
        if (imageData.length > maxImageDataLength) {
            imageData = [XMShareUtility imageDwindle:[UIImage imageWithData:imageData]];
        }
    }
    
    return imageData;
}


+ (NSData *)normalizedThumbImage:(UIImage *)image forPlatform:(XMSharePlatform)platform
{
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    NSUInteger maxImageDataLength = imageData.length;
    switch (platform) {
        case kXMSharePlatformWeixinSession:
        case kXMSharePlatformWeixinTimeline: {
            maxImageDataLength = kMaxThumbImageDataLengthOfWeixin;
        }
            break;
        case kXMSharePlatformQQFriend:
        case kXMSharePlatformQQZone: {
            maxImageDataLength = kMaxThumbImageDataLengthOfQQ;
        }
            break;
        case kXMSharePlatformSinaWeibo: {
            maxImageDataLength = kMaxThumbImageDataLengthOfWeibo;
        }
            break;
        case kXMSharePlatformSMS:
        case kXMSharePlatformEmail:
            break;
        default:
            break;
    }
    
    while (imageData.length > maxImageDataLength) {
        CGFloat scale = (CGFloat)maxImageDataLength / (CGFloat)imageData.length;
        UIImage *tempImage = [UIImage imageWithData:imageData];
        imageData = UIImageJPEGRepresentation(tempImage, scale);
        
        if (imageData.length > maxImageDataLength) {
            imageData = [XMShareUtility imageDwindle:[UIImage imageWithData:imageData]];
        }
    }
    
    return imageData;
}


/**
 *  对图片的体积进行"缩"
 *
 *  @param sourceImage 原图像
 *  @param maxLength   图片最大长度
 *
 *  @return 压缩后的图片数据
 */
+ (NSData *)imageDwindle:(UIImage *)sourceImage
{
    CGSize  imageSize    = sourceImage.size;
    CGFloat targetWidth  = imageSize.width * .9;
    CGFloat targetHeight = (targetWidth / imageSize.width) * imageSize.height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
    return newImage ? UIImageJPEGRepresentation(newImage, 1.f): nil ;
}


+ (BOOL)isWebpageUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform
{
    NSUInteger maxUrlStringLength = 0;
    switch (platform) {
        case kXMSharePlatformWeixinSession:
        case kXMSharePlatformWeixinTimeline: {
            maxUrlStringLength = kMaxUrlStringDataLengthOfWeixin;
        }
            break;
        case kXMSharePlatformQQFriend:
        case kXMSharePlatformQQZone: {
            maxUrlStringLength = kMaxUrlStringLengthOfQQ;
        }
            break;
        case kXMSharePlatformSinaWeibo: {
            maxUrlStringLength = kMaxUrlStringLengthOfWeibo;
        }
            break;
        default: {
            maxUrlStringLength = urlString.length;
        }
            break;
    }
    
    return (urlString.length <= maxUrlStringLength);
}


//　TODO
+ (BOOL)isAudioUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform
{
    return YES;
}


+ (BOOL)isThumbImageUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform
{
    return YES;
}


+ (BOOL)isImageUrlStringValid:(NSString *)urlString forPlatform:(XMSharePlatform)platform
{
    return YES;
}

@end



