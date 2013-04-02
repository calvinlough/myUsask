//
//  CLEmailViewController.h
//  myUsask
//
//  Created by Calvin Lough on 1/3/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLEmailViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) NSDictionary *email;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UILabel *from;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIWebView *body;
@property (strong, nonatomic) UIPopoverController *popoverController;

- (void)updateView;

@end
