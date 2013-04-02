//
//  CLEmailViewController.m
//  myUsask
//
//  Created by Calvin Lough on 1/3/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import "CLEmailViewController.h"
#import "GTMNSString+HTML.h"

@implementation CLEmailViewController

@synthesize email;
@synthesize subject;
@synthesize from;
@synthesize date;
@synthesize separator;
@synthesize body;
@synthesize popoverController;

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
	
	if (email == nil) {
		subject.hidden = YES;
		from.hidden = YES;
		date.hidden = YES;
		separator.hidden = YES;
		body.hidden = YES;
		return;
	}
	
	[self updateView];
}

- (void)updateView {
	subject.hidden = NO;
	from.hidden = NO;
	date.hidden = NO;
	separator.hidden = NO;
	body.hidden = NO;
	
	subject.text = [[email objectForKey:@"fullSubject"] gtm_stringByUnescapingFromHTML];
	from.text = [[email objectForKey:@"fullFrom"] gtm_stringByUnescapingFromHTML];
	date.text = [email objectForKey:@"date"];
	
	NSString *processedBody = [email objectForKey:@"body"];
	
	processedBody = [processedBody stringByReplacingOccurrencesOfString:@" <BR>" withString:@" "];
	
	if ([processedBody hasPrefix:@"<BR>"]) {
		processedBody = [processedBody substringFromIndex:4];
	}
	
	BOOL didChange;
	
	do {
		NSString *newBody = [processedBody stringByReplacingOccurrencesOfString:@"  " withString:@" "];
		didChange = NO;
		
		if (![processedBody isEqualToString:newBody]) {
			didChange = YES;
		}
		
		processedBody = newBody;
	} while (didChange);
	
	NSString *formattedString = [NSString stringWithFormat:@"<html><head><style>body {font: 15px \"Helvetica Neue\", Helvetica, sans-serif}</style></head><body>%@</body></html>", processedBody];
	[body loadHTMLString:formattedString baseURL:nil];
	
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
	barButtonItem.title = @"Inbox";
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
