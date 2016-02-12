//
//  NSString+XMPPDemo.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "NSString+XMPPDemo.h"

@implementation NSString (XMPPDemo)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isEmpty {
    return self.trim.length == 0;
}

@end
