//
//  XMPPDemoAddNewFriendViewController.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoAddNewFriendViewController.h"
#import "XMPPHelper.h"
#import "NSString+XMPPDemo.h"
#import "XMPPDemoToast.h"
#import "XMPPUserCoreDataStorageObject.h"

static CGFloat const kHeightOfTextField = 40.0;

@interface XMPPDemoAddNewFriendViewController ()

@property (nonatomic, strong) UITextField *usernameField;

@end

@implementation XMPPDemoAddNewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self uiConfig];
}

- (void)uiConfig {
    self.navigationItem.title = @"Add friend";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(commitAddAction)];
    
    self.usernameField = [[UITextField alloc]initWithFrame:CGRectMake(0.0, 25.0, self.view.frame.size.width, kHeightOfTextField)];
    self.usernameField.borderStyle = UITextBorderStyleNone;
    self.usernameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.usernameField.layer.borderWidth = 0.5;
    self.usernameField.textAlignment = NSTextAlignmentCenter;
    self.usernameField.font = [UIFont systemFontOfSize:15.0];
    self.usernameField.placeholder = @"Username";
    [self.view addSubview:self.usernameField];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)commitAddAction {
    NSString *username = [self.usernameField.text trim];
    for (XMPPUserCoreDataStorageObject *user in [XMPPHelper sharedInstance].allFriends) {
        if ([username isEqualToString:user.jid.user]) {
            [XMPPDemoToast showToastWithMessage:[NSString stringWithFormat:@"“%@” is already your friend.", username]];
            return;
        }
    }
    [[XMPPHelper sharedInstance] addNewFriend:[self.usernameField.text trim] withCallback:^() {
        [XMPPDemoToast showToastWithMessage:@"Friend request has been sent."];
    }];
}

@end
