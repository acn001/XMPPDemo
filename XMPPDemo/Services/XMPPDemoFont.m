//
//  XMPPDemoFont.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoFont.h"
#import "UIColor+XMPPDemo.h"

#define XMPPDEMO_FONT_THIN @".HelveticaNeueInterface-Thin"
#define XMPPDEMO_FONT_LIGHT @".HelveticaNeueInterface-Light"
#define XMPPDEMO_FONT_REGULAR @".HelveticaNeueInterface-Regular"
#define XMPPDEMO_FONT_MEDIUM @".HelveticaNeueInterface-Medium"
#define XMPPDEMO_FONT_BOLD @".HelveticaNeueInterface-Bold"
#define XMPPDEMO_FONT_HEAVY @".HelveticaNeueInterface-Heavy"

#define XMPPDEMO_FONT_THIN2 @"HelveticaNeue-Thin"
#define XMPPDEMO_FONT_LIGHT2 @"HelveticaNeue-Light"
#define XMPPDEMO_FONT_REGULAR2 @"HelveticaNeue"
#define XMPPDEMO_FONT_MEDIUM2 @"HelveticaNeue-Medium"
#define XMPPDEMO_FONT_BOLD2 @"HelveticaNeue-Bold"
// no heavy font of HelveticaNeue, use bold instead
#define XMPPDEMO_FONT_HEAVY2 @"HelveticaNeue-Bold"

@implementation XMPPDemoFont

- (instancetype)initWithFontWeight:(XMPPDemoFontWeight)fontWeight size:(CGFloat)size color:(UIColor *)color {
    if (self = [super init]) {
        if ([UIFont.class respondsToSelector:@selector(systemFontOfSize:weight:)]) {
            CGFloat weight = 0;
            switch (fontWeight) {
                case XMPPDEMO_FONT_WEIGHT_THIN:
                    weight = UIFontWeightThin;
                    break;
                case XMPPDEMO_FONT_WEIGHT_LIGHT:
                    weight = UIFontWeightLight;
                    break;
                case XMPPDEMO_FONT_WEIGHT_REGULAR:
                    weight = UIFontWeightRegular;
                    break;
                case XMPPDEMO_FONT_WEIGHT_MEDIUM:
                    weight = UIFontWeightMedium;
                    break;
                case XMPPDEMO_FONT_WEIGHT_BOLD:
                    weight = UIFontWeightBold;
                    break;
                case XMPPDEMO_FONT_WEIGHT_HEAVY:
                    weight = UIFontWeightHeavy;
                    break;
                default:
                    break;
            }
            UIFont *font = [UIFont systemFontOfSize:size weight:weight];
            _font = font;
        } else {
            NSString *fontName = nil;
            switch (fontWeight) {
                case XMPPDEMO_FONT_WEIGHT_THIN:
                    fontName = XMPPDEMO_FONT_THIN;
                    break;
                case XMPPDEMO_FONT_WEIGHT_LIGHT:
                    fontName = XMPPDEMO_FONT_LIGHT;
                    break;
                case XMPPDEMO_FONT_WEIGHT_REGULAR:
                    fontName = XMPPDEMO_FONT_REGULAR;
                    break;
                case XMPPDEMO_FONT_WEIGHT_MEDIUM:
                    fontName = XMPPDEMO_FONT_MEDIUM;
                    break;
                case XMPPDEMO_FONT_WEIGHT_BOLD:
                    fontName = XMPPDEMO_FONT_BOLD;
                    break;
                case XMPPDEMO_FONT_WEIGHT_HEAVY:
                    fontName = XMPPDEMO_FONT_HEAVY;
                    break;
                default:
                    break;
            }
            UIFont *font = [UIFont fontWithName:fontName size:size];
            if (font == nil) {
                switch (fontWeight) {
                    case XMPPDEMO_FONT_WEIGHT_THIN:
                        fontName = XMPPDEMO_FONT_THIN2;
                        break;
                    case XMPPDEMO_FONT_WEIGHT_LIGHT:
                        fontName = XMPPDEMO_FONT_LIGHT2;
                        break;
                    case XMPPDEMO_FONT_WEIGHT_REGULAR:
                        fontName = XMPPDEMO_FONT_REGULAR2;
                        break;
                    case XMPPDEMO_FONT_WEIGHT_MEDIUM:
                        fontName = XMPPDEMO_FONT_MEDIUM2;
                        break;
                    case XMPPDEMO_FONT_WEIGHT_BOLD:
                        fontName = XMPPDEMO_FONT_BOLD2;
                        break;
                    case XMPPDEMO_FONT_WEIGHT_HEAVY:
                        fontName = XMPPDEMO_FONT_HEAVY2;
                        break;
                    default:
                        break;
                }
                font = [UIFont fontWithName:fontName size:size];
                if (font == nil) {
                    switch (fontWeight) {
                        case XMPPDEMO_FONT_WEIGHT_THIN:
                        case XMPPDEMO_FONT_WEIGHT_LIGHT:
                        case XMPPDEMO_FONT_WEIGHT_REGULAR:
                            font = [UIFont systemFontOfSize:size];
                            break;
                        case XMPPDEMO_FONT_WEIGHT_MEDIUM:
                        case XMPPDEMO_FONT_WEIGHT_BOLD:
                        case XMPPDEMO_FONT_WEIGHT_HEAVY:
                            font = [UIFont boldSystemFontOfSize:size];
                            break;
                        default:
                            break;
                    }
                }
            }
            _font = font;
        }
        _color = color;
    }
    return self;
}

+ (instancetype)fontWithColor:(UIColor *)color fontWeight:(XMPPDemoFontWeight)weight andFontSize:(NSInteger)size {
    return [[self alloc] initWithFontWeight:weight size:(CGFloat)size color:color];
}

+ (instancetype)wb14 {
    return [[self alloc] initWithFontWeight:XMPPDEMO_FONT_WEIGHT_BOLD size:14.0 color:XMPPDEMO_COLOR_WHITE];
}

@end
