//
//  CLReadBulletinViewController.h
//  myUsask
//
//  Created by Calvin Lough on 1/6/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLReadBulletinViewController : UIViewController <UISplitViewControllerDelegate, UIWebViewDelegate>

@property (strong, nonatomic) NSDictionary *bulletin;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIWebView *body;
@property (strong, nonatomic) UIPopoverController *popoverController;

- (void)updateView;

@end
