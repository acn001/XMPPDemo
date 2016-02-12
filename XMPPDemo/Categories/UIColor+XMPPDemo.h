//
//  UIColor+XMPPDemo.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import <UIKit/UIKit.h>

#define XMPPDEMO_COLOR_BLACK [UIColor colorWithHexString:@"333333"]
#define XMPPDEMO_COLOR_WHITE [UIColor colorWithHexString:@"FFFFFF"]

@interface UIColor (XMPPDemo)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
