//
//  XMPPDemoFont.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XMPPDemoFontWeight) {
    XMPPDEMO_FONT_WEIGHT_THIN = 0,
    XMPPDEMO_FONT_WEIGHT_LIGHT,
    XMPPDEMO_FONT_WEIGHT_REGULAR,
    XMPPDEMO_FONT_WEIGHT_MEDIUM,
    XMPPDEMO_FONT_WEIGHT_BOLD,
    XMPPDEMO_FONT_WEIGHT_HEAVY,
};

@interface XMPPDemoFont : NSObject

@property (nonatomic, strong, readonly) UIFont *font;
@property (nonatomic, strong, readonly) UIColor *color;

+ (instancetype)fontWithColor:(UIColor *)color fontWeight:(XMPPDemoFontWeight)weight andFontSize:(NSInteger)size;
+ (instancetype)wb14;

@end
