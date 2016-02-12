//
//  XMPPDemoRegisterViewController.h
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoBaseViewController.h"

@interface XMPPDemoRegisterViewController : XMPPDemoBaseViewController

@property (nonatomic, copy, readonly) NSString *username;

- (instancetype)initWithUsername:(NSString *)username;

@end
