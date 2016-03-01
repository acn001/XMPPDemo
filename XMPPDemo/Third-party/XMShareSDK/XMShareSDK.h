//
//  XMShareSDK.h
//  XMShareSDK
//
//  Created by liuzuopeng01 on 15/9/4.
//  Copyright (c) 2015年 liuzuopeng01. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  引入分享SDK的常量定义
 */
#import "XMShareDef.h"

/**
 *  引入分享SDK的分享对象定义
 */
#import "XMShareObject.h"
#import "XMSSOObject.h"

/**
 *  分享面板内容视图
 */
#import "XMShareView.h"

/**
 *  引入分享SDK的分享api文件定义
 */
#import "XMShareManager.h"



#pragma mark - macros for toast message

#define kXMShareToastMsgOfCopyLinkForSuccess   (@"已成功复制链接")
#define kXMShareToastMsgOfCopyLinkForFailed    (@"复制链接失败")
#define kXMShareToastMsgOfCopyLinkForCanceled  (@"取消复制")

#define kXMShareToastMsgForSuccess             (@"分享成功")
#define kXMShareToastMsgForFailed              (@"分享失败")
#define kXMShareToastMsgForCanceled            (@"取消分享")
