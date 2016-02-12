//
//  AppDelegate.m
//  XMPPDemo
//
//  Created by zhuyue on 16/2/12.
//  Copyright © 2016年 zhuyue. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPDemoLoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"HomeDirectory:\n%@", NSHomeDirectory());
    
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

@end
