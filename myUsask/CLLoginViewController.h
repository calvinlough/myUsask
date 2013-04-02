//
//  CLLoginViewController.h
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLViewController;

@interface CLLoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) CLViewController *viewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *NSIDTextField;
@property (strong, nonatomic) UITextField *passwordTextField;

- (void)doLogin:(id)sender;

@end
