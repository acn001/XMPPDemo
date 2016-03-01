//
//  XMSSOObject.h
//  XMPPDemo
//
//  Created by zuopengl on 3/1/16.
//  Copyright © 2016 zhuyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMShareDef.h"

typedef NS_ENUM(NSInteger, XMSSOErrorCode) {
    kXMSSOErrorCodeUnknown = -1,
    kXMSSOErrorCodeSuccess = 0,
    kXMSSOErrorCodeAuthFailure,
    kXMSSOErrorCodeGetTokenFailure,
    kXMSSOErrorCodeGetUserInfoFailure,
};



@interface XMSSOObject : NSObject

@end



/**
 *  获取到的用户信息
 */
@interface XMUserObject : NSObject
@property (nonatomic, copy) NSString *openId; // unique identifier for each user

@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *province;

@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *headImgUrl;
@property (nonatomic, assign) NSInteger sex;
@end


/**
 *  授权登陆响应类型
 */
@interface XMSSOResponseObject <XMSSOResponseType> : NSObject {
    XMSSOResponseType _respObj;
}
@property (nonatomic, assign) XMSSOErrorCode errCode;
@property (nonatomic, strong) XMUserObject *userObject;

//@property (nonatomic, copy) NSString *code;
//@property (nonatomic, copy) NSString *accessToken;

@property (nonatomic, assign) XMShareChannelType channel;
@property (nonatomic, strong) XMSSOResponseType respObj;

@end