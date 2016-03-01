//
//  NSString+XMDraw.m
//  BaiduNuomiTuan
//
//  Created by BaiduSky on 9/22/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import "NSString+XMDraw.h"

//
@implementation NSString (XMDraw)

- (CGSize)sizeByNuomiFont:(nonnull UIFont *)font {
    return [self sizeByNuomiFont:font constrainedToSize:CGSizeZero];
}


- (CGSize)sizeByNuomiFont:(nonnull UIFont *)font
        constrainedToSize:(CGSize)size {
    return [self sizeByNuomiFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
}


- (CGSize)sizeByNuomiFont:(nonnull UIFont *)font
        constrainedToSize:(CGSize)size
            lineBreakMode:(NSLineBreakMode)lineBreakMode {
    //
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineBreakMode = lineBreakMode;
    //
    return [self sizeByConstrainedToSize:size
                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                              attributes:@{NSFontAttributeName: font,
                                           NSParagraphStyleAttributeName: ps}];
}


- (CGSize)sizeByConstrainedToSize:(CGSize)size
                          options:(NSStringDrawingOptions)options
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    return [self boundingRectWithSize:size
                              options:options
                           attributes:attributes
                              context:nil].size;
}

@end
