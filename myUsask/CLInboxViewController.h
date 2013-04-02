//
//  CLInboxViewController.h
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLURLRequestDelegate.h"

@class CLEmailViewController;
@class CLURLRequest;
@class MBProgressHUD;

@interface CLInboxViewController : UITableViewController <CLURLRequestDelegate>

@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) UISplitViewController *splitViewController;
@property (weak, nonatomic) CLEmailViewController *emailViewController;
@property (strong, nonatomic) NSArray *inboxData;
@property (strong, nonatomic) NSRegularExpression *messagePattern;
@property (strong, nonatomic) CLURLRequest *activeURLRequest;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableViewCell;
@property (assign, nonatomic) NSInteger clickedRow;
@property (strong, nonatomic) MBProgressHUD *loadingHUD;

- (void)updateDetailBasedOnSelectedRow:(NSUInteger)selectedRow;

@end
