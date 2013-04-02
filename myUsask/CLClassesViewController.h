//
//  CLClassesViewController.h
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLURLRequestDelegate.h"

@class CLClassMembersViewController;
@class CLURLRequest;
@class MBProgressHUD;

@interface CLClassesViewController : UITableViewController <CLURLRequestDelegate>

@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) UISplitViewController *splitViewController;
@property (weak, nonatomic) CLClassMembersViewController *membersViewController;
@property (strong, nonatomic) NSArray *classesData;
@property (strong, nonatomic) NSRegularExpression *membersPattern;
@property (strong, nonatomic) CLURLRequest *activeURLRequest;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableViewCell;
@property (assign, nonatomic) NSInteger clickedRow;
@property (strong, nonatomic) MBProgressHUD *loadingHUD;

- (void)updateDetailBasedOnSelectedRow:(NSUInteger)selectedRow;

@end
