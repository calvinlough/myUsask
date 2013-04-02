//
//  CLComposeViewController.h
//  myUsask
//
//  Created by Calvin Lough on 1/5/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLURLRequestDelegate.h"

@class CLURLRequest;
@class MBProgressHUD;

@interface CLComposeViewController : UIViewController <CLURLRequestDelegate, UITextFieldDelegate>

@property (weak, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) CLURLRequest *activeURLRequest;
@property (weak, nonatomic) IBOutlet UITextField *to;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextView *message;
@property (strong, nonatomic) MBProgressHUD *loadingHUD;

- (void)doSend:(id)sender;
- (void)doCancel:(id)sender;
- (void)hideKeyboard;

@end
