//
//  XMSSOObject.m
//  XMPPDemo
//
//  Created by zuopengl on 3/1/16.
//  Copyright © 2016 zhuyue. All rights reserved.
//

#import "XMSSOObject.h"


@implementation XMSSOObject

@end


/**
 *  获取到的用户信息
 */
@implementation XMUserObject

- (NSString *)description {
    return [NSString stringWithFormat:@"nickName = %@", _nickName];
}

@end


/**
 *  授权登陆响应类型
 */
@implementation XMSSOResponseObject
@synthesize respObj = _respObj;

- (NSString *)channelString {
    NSString *channelName = @"Unknown";
    switch (_channel) {
        case kXMShareChannelQQ: {
            channelName = @"QQ";
        }
            break;
            
        case kXMShareChannelWeixin: {
            channelName = @"Weixin";
        }
            break;
            
        case kXMShareChannelSinaWeibo: {
            channelName = @"SinaWeibo";
        }
            break;
            
        default:
            break;
    }
    return channelName;
}


- (NSString *)description {
    NSString *despString = nil;
    
    despString = [NSString stringWithFormat:@"errCode = %ld", (long)_errCode];
    despString = [despString stringByAppendingString:[NSString stringWithFormat:@"\nchannel = %@", [self channelString]]];
    despString = [despString stringByAppendingString:[NSString stringWithFormat:@"\nuserInfo = %@", _userObject]];
    
    return despString;
}

@end