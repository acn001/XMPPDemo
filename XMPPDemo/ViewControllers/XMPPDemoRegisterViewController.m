//
//  XMPPDemoRegisterViewController.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "XMPPDemoRegisterViewController.h"
#import "XMPPHelper.h"
#import "NSString+XMPPDemo.h"
#import "XMPPDemoLoadingIndicatorView.h"
#import "XMPPDemoToast.h"

static CGFloat const kHeightOfTextField = 40.0;

@interface XMPPDemoRegisterViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField1;
@property (nonatomic, strong) UITextField *passwordField2;

@property (nonatomic, assign) BOOL isInRegistring;

@end

@implementation XMPPDemoRegisterViewController

- (instancetype)initWithUsername:(NSString *)username {
    if (self = [super init]) {
        self->_username = [username copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self uiConfig];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)uiConfig {
    self.navigationItem.title = NSLocalizedString(@"Register", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back", nil) style:(UIBarButtonItemStylePlain) target:self action:@selector(backAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Register", nil) style:UIBarButtonItemStylePlain target:self action:@selector(commitRegisterAction)];
    
    self.usernameField = [[UITextField alloc]initWithFrame:CGRectMake(0.0, 25.0, self.view.frame.size.width, kHeightOfTextField)];
    self.usernameField.borderStyle = UITextBorderStyleNone;
    self.usernameField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.usernameField.layer.borderWidth = 0.5;
    self.usernameField.textAlignment = NSTextAlignmentCenter;
    self.usernameField.font = [UIFont systemFontOfSize:15.0];
    self.usernameField.placeholder = NSLocalizedString(@"Username", nil);
    if (self.username != nil) {
        self.usernameField.text = self.username;
    }
    [self.view addSubview:self.usernameField];
    
    self.passwordField1 = [[UITextField alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.usernameField.frame) - 0.5, self.view.frame.size.width, kHeightOfTextField)];
    self.passwordField1.borderStyle = UITextBorderStyleNone;
    self.passwordField1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.passwordField1.layer.borderWidth = 0.5;
    self.passwordField1.secureTextEntry  = YES;
    self.passwordField1.textAlignment = NSTextAlignmentCenter;
    self.passwordField1.font = [UIFont systemFontOfSize:15.0];
    self.passwordField1.placeholder = NSLocalizedString(@"Password", nil);
    self.passwordField1.delegate = self;
    [self.view addSubview:self.passwordField1];
    
    self.passwordField2 = [[UITextField alloc]initWithFrame:CGRectMake(0.0, CGRectGetMaxY(self.passwordField1.frame) - 0.5, self.view.frame.size.width, kHeightOfTextField)];
    self.passwordField2.borderStyle = UITextBorderStyleNone;
    self.passwordField2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.passwordField2.layer.borderWidth = 0.5;
    self.passwordField2.secureTextEntry = YES;
    self.passwordField2.textAlignment = NSTextAlignmentCenter;
    self.passwordField2.font = [UIFont systemFontOfSize:15.0];
    self.passwordField2.placeholder = NSLocalizedString(@"Repeat Password", nil);
    [self.view addSubview:self.passwordField2];
}

- (void)backAction {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)commitRegisterAction {
    if (self.isInRegistring) {
        return;
    }
    [self.view endEditing:YES];
    if ([self isLoginInfoValid]) {
        self.isInRegistring = YES;
        [XMPPDemoLoadingIndicatorView showModal];
        [[XMPPHelper sharedInstance]registerWithUsername:[self.usernameField.text trim] password:self.passwordField1.text withCallback:^(BOOL success, NSError *error) {
            [XMPPDemoLoadingIndicatorView hideModal];
            if (success) {
                self.passwordField1.text = self.passwordField2.text = @"";
                
                [XMPPDemoToast showToastWithMessage:@"Register success."];
            } else {
                NSLog(@"Register fail: %@", error.localizedDescription);
                self.passwordField1.text = self.passwordField2.text = @"";
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"This username has been used, please try with another username.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alertView show];
            }
            self.isInRegistring = NO;
        }];
    }
}

- (BOOL)isLoginInfoValid {
    if (![self.usernameField.text isEmpty] && ![self.passwordField1.text isEmpty] && ![self.passwordField2.text isEmpty]) {
        if (![self.passwordField1.text isEqualToString:self.passwordField2.text]) {
            self.passwordField1.text = self.passwordField2.text = @"";
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Password not match.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alertView show];
            return NO;
        } else {
            return YES;
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Username or password cannot be null.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
}

@end
