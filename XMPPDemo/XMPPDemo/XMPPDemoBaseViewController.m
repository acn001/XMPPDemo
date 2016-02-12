//
//  XMPPDemoBaseViewController.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoBaseViewController.h"
#import "UIColor+XMPPDemo.h"

@interface XMPPDemoBaseViewController ()

@end

@implementation XMPPDemoBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barTintColor = XMPPDEMO_COLOR_BLACK;
    self.navigationController.navigationBar.tintColor = XMPPDEMO_COLOR_WHITE;
    
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
