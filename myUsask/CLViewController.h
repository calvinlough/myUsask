//
//  CLViewController.h
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLURLRequestDelegate.h"

@class CLBulletinsViewController;
@class CLClassesViewController;
@class CLInboxViewController;
@class CLLoginViewController;
@class CLURLRequest;
@class MBProgressHUD;

@interface CLViewController : UIViewController <CLURLRequestDelegate>

@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UINavigationController *loginNavigationController;
@property (strong, nonatomic) CLLoginViewController *loginViewController;
@property (strong, nonatomic) CLInboxViewController *inboxViewController;
@property (strong, nonatomic) CLClassesViewController *classesViewController;
@property (strong, nonatomic) CLBulletinsViewController *bulletinsViewController;
@property (strong, nonatomic) MBProgressHUD *loadingHUD;
@property (strong, nonatomic) CLURLRequest *activeURLRequest;
@property (strong, nonatomic) NSString *NSID;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSRegularExpression *inboxPattern;
@property (strong, nonatomic) NSRegularExpression *classesPattern;
@property (strong, nonatomic) NSRegularExpression *bulletinsPattern;
@property (strong, nonatomic) NSArray *inbox;

- (void)doLoginWithNSID:(NSString *)aNSID password:(NSString *)aPassword;
- (void)continueLoginUsingString:(NSString *)requestString;
- (void)checkLoginUsingString:(NSString *)requestString;
- (void)finishLoginUsingString:(NSString *)requestString;
- (void)processInboxUsingString:(NSString *)requestString;
- (void)processClassesUsingString:(NSString *)requestString;

@end
