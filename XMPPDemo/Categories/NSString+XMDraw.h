//
//  NSString+XMDraw.h
//  BaiduNuomiTuan
//
//  Created by BaiduSky on 9/22/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  字符串Size计算API
 */
@interface NSString (XMDraw)

- (CGSize)sizeByNuomiFont:(nonnull UIFont *)font;

- (CGSize)sizeByNuomiFont:(nonnull UIFont *)font
        constrainedToSize:(CGSize)size;

- (CGSize)sizeByNuomiFont:(nonnull UIFont *)font
        constrainedToSize:(CGSize)size
            lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)sizeByConstrainedToSize:(CGSize)size
                          options:(NSStringDrawingOptions)options
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes;

@end
