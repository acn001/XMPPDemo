//
//  UILabel+XMPPDemo.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "UILabel+XMPPDemo.h"
#import "XMPPDemoFont.h"

@implementation UILabel (XMPPDemo)

- (void)setXMPPDemoFont:(XMPPDemoFont *)aXMPPDemoFont {
    self.font = aXMPPDemoFont.font;
    self.textColor = aXMPPDemoFont.color;
}

@end
