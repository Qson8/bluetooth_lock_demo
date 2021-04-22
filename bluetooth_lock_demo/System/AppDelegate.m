//
//  AppDelegate.m
//  蓝牙
//
//  Created by Qson on 2020/5/26.
//  Copyright © 2020 Qson. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ViewController *rootVc = [[ViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootVc;
    [self.window makeKeyAndVisible];
    return YES;
}



@end
