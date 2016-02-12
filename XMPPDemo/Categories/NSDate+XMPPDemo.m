//
//  NSDate+XMPPDemo.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "NSDate+XMPPDemo.h"

@implementation NSDate (XMPPDemo)

+ (NSDate *)dateFromTimeMillis:(int64_t)timeMillis {
    return [NSDate dateWithTimeIntervalSince1970:timeMillis / 1000.0];
}

+ (int64_t)currentTimeMillis {
    return [[self date] timeMillis];
}

- (int64_t)timeMillis {
    return (int64_t)([self timeIntervalSince1970] * 1000.0);
}

- (NSString *)toStringWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *destDateString = [dateFormatter stringFromDate:self];
    return destDateString;
}

@end
