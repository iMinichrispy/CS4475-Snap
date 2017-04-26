//
//  AppDelegate.m
//  Snap
//
//  Created by Alex Perez on 4/20/17.
//  Copyright © 2017 Alex Perez. All rights reserved.
//

#import "SPAppDelegate.h"

#import "SPHomeViewController.h"

@implementation SPAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SPHomeViewController *homeViewController = [[SPHomeViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = homeViewController;
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window makeKeyAndVisible];
    return YES;
}

@end
