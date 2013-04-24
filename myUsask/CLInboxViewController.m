//
//  CLInboxViewController.m
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import "CLComposeViewController.h"
#import "CLEmailViewController.h"
#import "CLInboxViewController.h"
#import "CLURLRequest.h"
#import "GTMNSString+HTML.h"
#import "MBProgressHUD.h"
#import "NSString+CLAdditions.h"

@implementation CLInboxViewController

@synthesize navigationController;
@synthesize splitViewController;
@synthesize emailViewController;
@synthesize inboxData;
@synthesize messagePattern;
@synthesize activeURLRequest;
@synthesize tableViewCell;
@synthesize clickedRow;
@synthesize loadingHUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = @"Inbox";
		self.messagePattern = [NSRegularExpression regularExpressionWithPattern:@"id=\"from_object\" onMouseover=\"window\\.status=''; return true;\">(.*?)</a>.*?<span class=\"text12\" id=\"subject\">&nbsp;<b>(.*?)</b></span>.*?<td><span class=\"text12\" id=\"msg_txt\">(.*?)</span></td>"
																		options:(NSRegularExpressionCaseInsensitive |  NSRegularExpressionDotMatchesLineSeparators)
																		  error:nil];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		    self.clearsSelectionOnViewWillAppear = NO;
		    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		}
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
		[self updateDetailBasedOnSelectedRow:0];
	}
}

- (void)updateDetailBasedOnSelectedRow:(NSUInteger)selectedRow {
	self.clickedRow = selectedRow;
	
	if (CL_FAKE_NETWORK_DATA == 0) {
		NSString *msgId = [[self.inboxData objectAtIndex:selectedRow] objectForKey:@"msgId"];
		
		UIView *parentView;
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			parentView = self.navigationController.view;
		} else {
			parentView = self.splitViewController.view;
		}
		
		self.loadingHUD = [[MBProgressHUD alloc] initWithView:parentView];
		self.loadingHUD.labelText = @"Loading";
		[parentView addSubview:loadingHUD];
		[self.loadingHUD show:YES];
		
		CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
		[URLRequest setUrlString:[NSString stringWithFormat:@"http://paws.usask.ca/cp/email/message?msgId=%@", msgId]];
		[URLRequest setDelegate:self];
		[URLRequest startConnection];
		
		self.activeURLRequest = URLRequest;
	} else {
		NSMutableDictionary *clickedMessage = [NSMutableDictionary dictionaryWithDictionary:[self.inboxData objectAtIndex:clickedRow]];
		[clickedMessage setValue:@"Hey, just wondering if you are interested in grabbing lunch on Friday? There is that new sushi place downtown that I want to check out. I forget what it's called, but it's right across the street from Hudson's." forKey:@"body"];
		[clickedMessage setValue:[clickedMessage valueForKey:@"from"] forKey:@"fullFrom"];
		[clickedMessage setValue:[clickedMessage valueForKey:@"subject"] forKey:@"fullSubject"];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			CLEmailViewController *emailController = [[CLEmailViewController alloc] initWithNibName:@"CLEmailViewController" bundle:nil];
			emailController.email = clickedMessage;
			
			UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(doCompose:)];
			[[emailController navigationItem] setRightBarButtonItem:composeButton animated:YES];
			
			[navigationController pushViewController:emailController animated:YES];
		} else {
			emailViewController.email = clickedMessage;
			[emailViewController updateView];
		}
	}
}

- (void)URLRequest:(CLURLRequest *)URLRequest didFinishWithString:(NSString *)string {
	NSMutableDictionary *clickedMessage = [NSMutableDictionary dictionaryWithDictionary:[self.inboxData objectAtIndex:clickedRow]];
	NSArray *inboxMatches = [messagePattern matchesInString:string options:0 range:NSMakeRange(0, [string length])];
	
	if ([inboxMatches count] > 0) {
		NSTextCheckingResult *match = [inboxMatches objectAtIndex:0];
		NSString *fullFrom = [string substringWithRange:[match rangeAtIndex:1]];
		NSString *fullSubject = [string substringWithRange:[match rangeAtIndex:2]];
		NSString *body = [string substringWithRange:[match rangeAtIndex:3]];
		
		[clickedMessage setValue:fullFrom forKey:@"fullFrom"];
		[clickedMessage setValue:fullSubject forKey:@"fullSubject"];
		[clickedMessage setValue:body forKey:@"body"];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			CLEmailViewController *emailController = [[CLEmailViewController alloc] initWithNibName:@"CLEmailViewController" bundle:nil];
			emailController.email = clickedMessage;
			
			[navigationController pushViewController:emailController animated:YES];
		} else {
			emailViewController.email = clickedMessage;
			[emailViewController updateView];
		}
	}
	
	[self.loadingHUD hide:YES];
	self.loadingHUD = nil;
	
	self.activeURLRequest = nil;
}

- (void)doCompose:(id)sender {
	CLComposeViewController *composeViewController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		composeViewController = [[CLComposeViewController alloc] initWithNibName:@"CLComposeViewController_iPhone" bundle:nil];
	} else {
		composeViewController = [[CLComposeViewController alloc] initWithNibName:@"CLComposeViewController_iPad" bundle:nil];
	}
	
	UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:composeViewController action:@selector(doSend:)];
	[[composeViewController navigationItem] setRightBarButtonItem:sendButton animated:YES];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:composeViewController action:@selector(doCancel:)];
	[[composeViewController navigationItem] setLeftBarButtonItem:cancelButton animated:YES];
	
	UINavigationController *composeNavigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
	[composeViewController setNavigationController:composeNavigationController];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		composeNavigationController.modalPresentationStyle = UIModalPresentationPageSheet;
	}
	
	[self presentModalViewController:composeNavigationController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
	static NSString *cellIdentifier = @"InboxCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CLInboxViewControllerCell" owner:self options:nil];
        cell = tableViewCell;
        self.tableViewCell = nil;
	}
	
	UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = [[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"subject"] gtm_stringByUnescapingFromHTML];
	
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"from"] gtm_stringByUnescapingFromHTML];
	
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"date"] clRelativeDate];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 54.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.inboxData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self updateDetailBasedOnSelectedRow:indexPath.row];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
