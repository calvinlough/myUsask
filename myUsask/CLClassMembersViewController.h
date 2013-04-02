//
//  CLClassMembersViewController.h
//  myUsask
//
//  Created by Calvin Lough on 1/5/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLClassMembersViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSArray *membersData;
@property (weak, nonatomic) IBOutlet UITableViewCell *tableViewCell;
@property (strong, nonatomic) UIPopoverController *popoverController;

- (void)updateView;

@end
