//
//  XMPPDemoLoginViewController.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoLoginViewController.h"
#import "XMPPHelper.h"
#import "NSString+XMPPDemo.h"
#import "XMPPDemoLoadingIndicatorView.h"
#import "XMPPDemoToast.h"
#import "XMPPDemoRegisterViewController.h"
#import "XMPPDemoFriendsViewController.h"
#import "XMShareSDK.h"

static CGFloat const kHeightOfTextField = 40.0;
static NSString * const kUsernameKey = @"USERNAME_KEY";

@interface XMPPDemoLoginViewController ()

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, assign) BOOL isInLogin;

@end

@implementation XMPPDemoLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self uiConfig];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)uiConfig {
    self.navigationItem.title = NSLocalizedString(@"Login", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Register", nil) style:(UIBarButtonItemStylePlain) target:self action:@selector(registerAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Login", nil) style:UIBarButtonItemStylePlain target:self action:@selector(loginAction)];
    
    self.usernameField = [[UITextField alloc]initWithFrame:CGRectMake(0.0, 25.0, self.view.frame.size.width, kHeightOfTextField)];
    self.usernameField.borderStyle = UITextBorderStyleNone;
    self.usernameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.usernameField.layer.borderWidth = 0.5;
    self.usernameField.textAlignment = NSTextAlignmentCenter;
    self.usernameField.font = [UIFont systemFontOfSize:15.0];
    self.usernameField.placeholder = NSLocalizedString(@"Username", nil);
    [self.view addSubview:self.usernameField];
    
    self.passwordField = [[UITextField alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.usernameField.frame) - 0.5, self.view.frame.size.width, kHeightOfTextField)];
    self.passwordField.borderStyle = UITextBorderStyleNone;
    self.passwordField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.passwordField.layer.borderWidth = 0.5;
    self.passwordField.secureTextEntry  = YES;
    self.passwordField.textAlignment = NSTextAlignmentCenter;
    self.passwordField.font = [UIFont systemFontOfSize:15.0];
    self.passwordField.placeholder = NSLocalizedString(@"Password", nil);
    [self.view addSubview:self.passwordField];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kUsernameKey];
    if (username.length > 0) {
        self.usernameField.text = username;
    }
    
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.frame = CGRectMake(0, 150, self.view.frame.size.width, 30);
    testButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [testButton setTitle:@"test Weixin SSO Login" forState:UIControlStateNormal];
    [testButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [testButton addTarget:self action:@selector(testWeixinSSOLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testButton];
}


- (void)testWeixinSSOLogin:(id)sender {
    [[XMShareManager sharedManager] weixinSSOWithResponse:^(XMSSOResponseObject *respObject) {
        NSLog(@"execute responseObject, %@", respObject);
    }];
}

- (void)registerAction {
    XMPPDemoRegisterViewController *registerViewController = [[XMPPDemoRegisterViewController alloc] initWithUsername:[self.usernameField.text isEmpty] ? nil : [self.usernameField.text trim]];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (void)loginAction {
    if (self.isInLogin) {
        return;
    }
    [self.view endEditing:YES];
    if ([self isLoginInfoValid]) {
        self.isInLogin = YES;
        [XMPPDemoLoadingIndicatorView showModal];
        [[XMPPHelper sharedInstance]loginWithUsername:[self.usernameField.text trim] password:self.passwordField.text callback:^(BOOL success, NSError *error) {
            [XMPPDemoLoadingIndicatorView hideModal];
            if (success) {
                XMPPDemoFriendsViewController *friendsViewController = [[XMPPDemoFriendsViewController alloc]init];
                [self.navigationController pushViewController:friendsViewController animated:YES];
                
                [XMPPDemoToast showToastWithMessage:NSLocalizedString(@"Login success.", nil)];
                self.passwordField.text = nil;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [[NSUserDefaults standardUserDefaults] setObject:[self.usernameField.text trim] forKey:kUsernameKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                });
            } else {
                NSLog(@"%@", error.localizedDescription);
                self.passwordField.text = @"";
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Incorrect username or password, please retry.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alertView show];
            }
            self.isInLogin = NO;
        }];
    }
}

- (BOOL)isLoginInfoValid {
    if (![self.usernameField.text isEmpty] && ![self.passwordField.text isEmpty]) {
        return YES;
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Username or password cannot be null.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
    }
    return NO;
}

@end
