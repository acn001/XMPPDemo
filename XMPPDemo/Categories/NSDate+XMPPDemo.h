//
//  NSDate+XMPPDemo.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (XMPPDemo)

+ (NSDate *)dateFromTimeMillis:(int64_t)timeMillis;
+ (int64_t)currentTimeMillis;
- (int64_t)timeMillis;
- (NSString *)toStringWithFormat:(NSString *)format;

@end
