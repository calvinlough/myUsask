//
//  CLAppDelegate.m
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import "CLAppDelegate.h"
#import "CLViewController.h"

@implementation CLAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.viewController = [[CLViewController alloc] init];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
