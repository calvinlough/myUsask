//
//  CLClassesViewController.m
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import "CLClassesViewController.h"
#import "CLClassMembersViewController.h"
#import "CLURLRequest.h"
#import "GTMNSString+HTML.h"
#import "MBProgressHUD.h"

enum {
	URL_REQUEST_MEMBERS_FIRST = 1,
	URL_REQUEST_MEMBERS_SECOND
};

@implementation CLClassesViewController

@synthesize navigationController;
@synthesize splitViewController;
@synthesize membersViewController;
@synthesize classesData;
@synthesize membersPattern;
@synthesize activeURLRequest;
@synthesize tableViewCell;
@synthesize clickedRow;
@synthesize loadingHUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Classes";
		self.membersPattern = [NSRegularExpression regularExpressionWithPattern:@"<span id=\"membername\"><a href=\".*?userID=([a-z0-9]+).*?>(.*?)</a></span>"
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
		NSString *courseId = [[self.classesData objectAtIndex:selectedRow] objectForKey:@"courseId"];
		
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
		[URLRequest setUrlString:[NSString stringWithFormat:@"http://paws.usask.ca/jsp/grouptools/group/GroupRedirect.jsp?courseID=%@", courseId]];
		[URLRequest setTag:URL_REQUEST_MEMBERS_FIRST];
		[URLRequest setDelegate:self];
		[URLRequest startConnection];
		
		self.activeURLRequest = URLRequest;
	} else {
		NSMutableArray *membersData = [NSMutableArray array];
		NSDictionary *member;
		
		member = [NSDictionary dictionaryWithObjectsAndKeys:@"abc123", @"nsid", @"Smith, John", @"name", nil];
		[membersData addObject:member];
		member = [NSDictionary dictionaryWithObjectsAndKeys:@"abc123", @"nsid", @"Smith, Jane", @"name", nil];
		[membersData addObject:member];
		member = [NSDictionary dictionaryWithObjectsAndKeys:@"abc123", @"nsid", @"Smith, Mike", @"name", nil];
		[membersData addObject:member];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			CLClassMembersViewController *memberController = [[CLClassMembersViewController alloc] initWithNibName:@"CLClassMembersViewController" bundle:nil];
			memberController.membersData = membersData;
			
			[navigationController pushViewController:memberController animated:YES];
		} else {
			membersViewController.membersData = membersData;
			[membersViewController updateView];
		}
	}
}

- (void)URLRequest:(CLURLRequest *)URLRequest didFinishWithString:(NSString *)string {
	self.activeURLRequest = nil;
	
	if ([URLRequest tag] == URL_REQUEST_MEMBERS_FIRST) {
		NSString *groupId = [[URLRequest urlString] substringFromIndex:([[URLRequest urlString] rangeOfString:@"=" options:NSBackwardsSearch].location + 1)];
		
		CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
		[URLRequest setUrlString:[NSString stringWithFormat:@"http://paws.usask.ca/jsp/grouptools/member/MemberHome.jsp?groupID=%@", groupId]];
		[URLRequest setTag:URL_REQUEST_MEMBERS_SECOND];
		[URLRequest setDelegate:self];
		[URLRequest startConnection];
		
		self.activeURLRequest = URLRequest;
		
	} else if ([URLRequest tag] == URL_REQUEST_MEMBERS_SECOND) {
		NSMutableArray *membersData = [NSMutableArray array];
		NSArray *membersMatches = [membersPattern matchesInString:string options:0 range:NSMakeRange(0, [string length])];
		
		for (NSTextCheckingResult *match in membersMatches) {
			NSString *nsid = [string substringWithRange:[match rangeAtIndex:1]];
			NSString *name = [string substringWithRange:[match rangeAtIndex:2]];
			
			NSDictionary *member = [NSDictionary dictionaryWithObjectsAndKeys:nsid, @"nsid", name, @"name", nil];
			[membersData addObject:member];
		}
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			CLClassMembersViewController *memberController = [[CLClassMembersViewController alloc] initWithNibName:@"CLClassMembersViewController" bundle:nil];
			memberController.membersData = membersData;
			
			[navigationController pushViewController:memberController animated:YES];
		} else {
			membersViewController.membersData = membersData;
			[membersViewController updateView];
		}
		
		[self.loadingHUD hide:YES];
		self.loadingHUD = nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
	static NSString *cellIdentifier = @"ClassesCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CLClassesViewControllerCell" owner:self options:nil];
        cell = tableViewCell;
        self.tableViewCell = nil;
	}
	
	UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = [[[self.classesData objectAtIndex:indexPath.row] objectForKey:@"name"] gtm_stringByUnescapingFromHTML];
	
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [[[self.classesData objectAtIndex:indexPath.row] objectForKey:@"courseNumber"] gtm_stringByUnescapingFromHTML];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 53.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.classesData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self updateDetailBasedOnSelectedRow:indexPath.row];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
