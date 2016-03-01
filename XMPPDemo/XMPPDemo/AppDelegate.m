//
//  AppDelegate.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPDemoLoginViewController.h"
#import "XMShareSDK.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"HomeDirectory:\n%@", NSHomeDirectory());
    
    [XMShareManager registerChannelAppId];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:[[XMPPDemoLoginViewController alloc] init]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self->_isForeground = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    self->_isForeground = YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    // 分享sdk
    if ([[XMShareManager sharedManager] handleOpenURL:url]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // 分享sdk
    if ([[XMShareManager sharedManager] handleOpenURL:url]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // 分享sdk
    if ([[XMShareManager sharedManager] handleOpenURL:url]) {
        return YES;
    }
    
    return NO;
}
@end
