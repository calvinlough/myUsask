//
//  CLComposeViewController.m
//  myUsask
//
//  Created by Calvin Lough on 1/5/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import "CLComposeViewController.h"
#import "CLURLRequest.h"
#import "MBProgressHUD.h"
#import "NSString+CLAdditions.h"

@implementation CLComposeViewController

@synthesize navigationController;
@synthesize activeURLRequest;
@synthesize to;
@synthesize subject;
@synthesize message;
@synthesize loadingHUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Compose";
		self.tabBarItem.image = [UIImage imageNamed:@"18-envelope"];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[to becomeFirstResponder];
}

- (void)doSend:(id)sender {
	NSString *escapedTo = [[to text] clURLEncodedParameterString];
	NSString *escapedSubject = [[subject text] clURLEncodedParameterString];
	NSString *escapedMessage = [[message text] clURLEncodedParameterString];
	
	if ([escapedTo length] > 0 && [escapedSubject length] > 0 && [escapedMessage length] > 0) {
		[self hideKeyboard];
		
		NSString *postString = [NSString stringWithFormat:@"to=%@&cc=&bcc=&subject=%@&isMessageRichText=N&body=%@&body_editor=&pdsEmailSaveAllSent=on&sentFolderName=Sent&msgId=&removeMsgId=&draftMsgId=&msgType=&grouptools=false&j_encoding=UTF-8", escapedTo, escapedSubject, escapedMessage];
		NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
		
		self.loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		self.loadingHUD.labelText = @"Loading";
		[self.navigationController.view addSubview:loadingHUD];
		[self.loadingHUD show:YES];
		
		CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
		[URLRequest setUrlString:@"http://paws.usask.ca/cp/email/sendMsg"];
		[URLRequest setPostData:postData];
		[URLRequest setDelegate:self];
		[URLRequest startConnection];
		
		self.activeURLRequest = URLRequest;
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a value for all fields." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
	}
}

- (void)doCancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)hideKeyboard {
	if ([to isFirstResponder]) {
		[to resignFirstResponder];
	}
	
	if ([subject isFirstResponder]) {
		[subject resignFirstResponder];
	}
	
	if ([message isFirstResponder]) {
		[message resignFirstResponder];
	}
}

- (void)URLRequest:(CLURLRequest *)URLRequest didFinishWithString:(NSString *)string {	
	[self.loadingHUD hide:YES];
	self.loadingHUD = nil;
	
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == to) {
		[subject becomeFirstResponder];
	} else if (textField == subject) {
		[message becomeFirstResponder];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			if ([message.text isEqualToString:@"\n\nSent from my iPhone"]) {
				message.selectedRange = NSMakeRange(0, 0);
			}
		} else {
			if ([message.text isEqualToString:@"\n\nSent from my iPad"]) {
				message.selectedRange = NSMakeRange(0, 0);
			}
		}
	}
	
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
