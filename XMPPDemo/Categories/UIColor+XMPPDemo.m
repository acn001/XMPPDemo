//
//  UIColor+XMPPDemo.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "UIColor+XMPPDemo.h"

@implementation UIColor (XMPPDemo)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSRange range = NSMakeRange(0, 2);
    NSString *alpha = @"FF";
    if (hexString.length == 8) {
        alpha = [hexString substringWithRange:range];
        range = NSMakeRange(range.location + 2, 2);
    }
    NSString *red = [hexString substringWithRange:range];
    range = NSMakeRange(range.location + 2, 2);
    NSString *green = [hexString substringWithRange:range];
    range = NSMakeRange(range.location + 2, 2);
    NSString *blue = [hexString substringWithRange:range];
    
    unsigned int a, r, g, b;
    [[NSScanner scannerWithString:alpha] scanHexInt:&a];
    [[NSScanner scannerWithString:red] scanHexInt:&r];
    [[NSScanner scannerWithString:green] scanHexInt:&g];
    [[NSScanner scannerWithString:blue] scanHexInt:&b];
    
    return [self colorWithRed:(CGFloat)r / 255.0 green:(CGFloat)g / 255.0f blue:(CGFloat)b / 255.0f alpha:(CGFloat)a / 255.0f];
}

@end
