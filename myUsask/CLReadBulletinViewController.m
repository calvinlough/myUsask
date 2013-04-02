//
//  CLReadBulletinViewController.m
//  myUsask
//
//  Created by Calvin Lough on 1/6/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import "CLReadBulletinViewController.h"
#import "GTMNSString+HTML.h"

@implementation CLReadBulletinViewController

@synthesize bulletin;
@synthesize titleLabel;
@synthesize separator;
@synthesize body;
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Item";
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	body.backgroundColor = [UIColor clearColor];
	
	for (UIView *subview in [body subviews]) {
		if ([subview isKindOfClass:[UIScrollView class]]) {
			for (UIView *shadowView in [subview subviews]) {
				if ([shadowView isKindOfClass:[UIImageView class]]) {
					[shadowView setHidden:YES];
				}
			}
		}
	}
	
	if (bulletin == nil) {
		titleLabel.hidden = YES;
		separator.hidden = YES;
		body.hidden = YES;
		return;
	}
	
	[self updateView];
}

- (void)updateView {
	titleLabel.hidden = NO;
	separator.hidden = NO;
	body.hidden = NO;
	
	titleLabel.text = [[bulletin objectForKey:@"title"] gtm_stringByUnescapingFromHTML];
	
	NSString *formattedString = [NSString stringWithFormat:@"<html><head><style>body {font: 15px \"Helvetica Neue\", Helvetica, sans-serif}</style></head><body>%@</body></html>", [bulletin objectForKey:@"body"]];
	[body loadHTMLString:formattedString baseURL:nil];
	
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
	barButtonItem.title = @"Bulletins";
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.popoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	return YES;
}

@end
