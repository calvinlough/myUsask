//
//  CLClassMembersViewController.m
//  myUsask
//
//  Created by Calvin Lough on 1/5/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import "CLClassMembersViewController.h"
#import "GTMNSString+HTML.h"
#import "NSString+CLAdditions.h"

@implementation CLClassMembersViewController

@synthesize membersData;
@synthesize tableViewCell;
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Members";
    }
    return self;
}

- (void)updateView {
	[self.tableView reloadData];
	
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
	barButtonItem.title = @"Classes";
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.popoverController = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"MembersCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CLClassMembersViewControllerCell" owner:self options:nil];
        cell = tableViewCell;
        self.tableViewCell = nil;
	}
	
	NSString *originalName = [[[self.membersData objectAtIndex:indexPath.row] objectForKey:@"name"] gtm_stringByUnescapingFromHTML];
	NSString *firstName = [originalName substringFromIndex:([originalName rangeOfString:@", "].location + 2)];
	NSString *lastName = [originalName substringToIndex:[originalName rangeOfString:@", "].location];
	NSString *name = [[NSString stringWithFormat:@"%@ %@", firstName, lastName] clTrimmedString];
	
	UILabel *label;
	label = (UILabel *)[cell viewWithTag:1];
	label.text = name;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 37.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.membersData count];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
