//
//  CLBulletinsViewController.m
//  myUsask
//
//  Created by Calvin Lough on 1/5/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import "CLBulletinsViewController.h"
#import "CLReadBulletinViewController.h"
#import "GTMNSString+HTML.h"
#import "NSString+CLAdditions.h"

@implementation CLBulletinsViewController

@synthesize navigationController;
@synthesize splitViewController;
@synthesize bulletinViewController;
@synthesize bulletinsData;
@synthesize tableViewCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Bulletins";
		
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
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		CLReadBulletinViewController *bulletinController = [[CLReadBulletinViewController alloc] initWithNibName:@"CLReadBulletinViewController" bundle:nil];
		bulletinController.bulletin = [self.bulletinsData objectAtIndex:selectedRow];
		
		[navigationController pushViewController:bulletinController animated:YES];
	} else {
		self.bulletinViewController.bulletin = [self.bulletinsData objectAtIndex:selectedRow];
		[self.bulletinViewController updateView];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"BulletinsCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CLBulletinsViewControllerCell" owner:self options:nil];
        cell = tableViewCell;
        self.tableViewCell = nil;
	}
	
	UILabel *label;
	label = (UILabel *)[cell viewWithTag:1];
	label.text = [[[self.bulletinsData objectAtIndex:indexPath.row] objectForKey:@"title"] gtm_stringByUnescapingFromHTML];
	
	label = (UILabel *)[cell viewWithTag:2];
	label.text = [[[[self.bulletinsData objectAtIndex:indexPath.row] objectForKey:@"body"] gtm_stringByUnescapingFromHTML] clPlainTextString];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 74.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.bulletinsData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self updateDetailBasedOnSelectedRow:indexPath.row];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
