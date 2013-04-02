//
//  CLBulletinsViewController.h
//  myUsask
//
//  Created by Calvin Lough on 1/5/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLReadBulletinViewController;

@interface CLBulletinsViewController : UITableViewController

@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) UISplitViewController *splitViewController;
@property (weak, nonatomic) CLReadBulletinViewController *bulletinViewController;
@property (strong, nonatomic) NSArray *bulletinsData;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableViewCell;

- (void)updateDetailBasedOnSelectedRow:(NSUInteger)selectedRow;

@end
