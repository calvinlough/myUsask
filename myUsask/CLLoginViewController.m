//
//  CLLoginViewController.m
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import "CLLoginViewController.h"
#import "CLViewController.h"

@implementation CLLoginViewController

@synthesize viewController;
@synthesize tableView;
@synthesize NSIDTextField;
@synthesize passwordTextField;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.tableView.backgroundView = nil;
		
		// even though this mask is set in the nib, it gets cleared for some reason so we need to set it again
		self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	}
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (NSString *)tableView:(UITableView *)theTableView titleForHeaderInSection:(NSInteger)section {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		return @"Login";
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"LoginCell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(112, 11, 183, 30)];
		
		if ([indexPath row] == 0) {
			textField.tag = 1;
			textField.returnKeyType = UIReturnKeyNext;
			[textField becomeFirstResponder];
			
			self.NSIDTextField = textField;
		} else {
			textField.tag = 2;
			textField.returnKeyType = UIReturnKeyDone;
			textField.secureTextEntry = YES;
			
			self.passwordTextField = textField;
		}
		
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		textField.clearButtonMode = UITextFieldViewModeNever;
		textField.delegate = self;
		
		[cell addSubview:textField];
	}
	
	if ([indexPath row] == 0) {
		cell.textLabel.text = @"NSID";
	} else {
		cell.textLabel.text = @"Password";
	}
	
	return cell;    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField tag] == 1) {
		[passwordTextField becomeFirstResponder];
		return YES;
	}
	
	[self doLogin:self];
	
	return NO;
}

- (void)doLogin:(id)sender {
	NSString *NSID = [NSIDTextField text];
	NSString *password = [passwordTextField text];
	
	if (([NSID length] == 6 && [password length] > 0) || CL_FAKE_NETWORK_DATA) {
		[passwordTextField resignFirstResponder];
		[viewController doLoginWithNSID:NSID password:password];
	} else if ([NSID length] != 6) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid NSID." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
	} else if ([password length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your password." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
