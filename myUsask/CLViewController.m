//
//  CLViewController.m
//  myUsask
//
//  Created by Calvin Lough on 12/30/11.
//  Copyright (c) 2011 Calvin Lough. All rights reserved.
//

#import "CLBulletinsViewController.h"
#import "CLClassesViewController.h"
#import "CLClassMembersViewController.h"
#import "CLEmailViewController.h"
#import "CLInboxViewController.h"
#import "CLLoginViewController.h"
#import "CLReadBulletinViewController.h"
#import "CLURLRequest.h"
#import "CLViewController.h"
#import "IntelligentSplitViewController.h"
#import "MBProgressHUD.h"
#import "NSString+CLAdditions.h"

enum {
	URL_REQUEST_LOGIN_FIRST = 1,
	URL_REQUEST_LOGIN_SECOND,
	URL_REQUEST_LOGIN_THIRD,
	URL_REQUEST_INBOX,
	URL_REQUEST_CLASSES
};

@implementation CLViewController

@synthesize tabBarController;
@synthesize loginNavigationController;
@synthesize loginViewController;
@synthesize inboxViewController;
@synthesize classesViewController;
@synthesize bulletinsViewController;
@synthesize loadingHUD;
@synthesize activeURLRequest;
@synthesize NSID;
@synthesize password;
@synthesize inboxPattern;
@synthesize classesPattern;
@synthesize bulletinsPattern;
@synthesize inbox;

- (id)init {
	self = [super init];
	
	if (self) {
		inboxPattern = [NSRegularExpression regularExpressionWithPattern:@"<input name=\"checkedMsgIds\" value=\"(.*?)\" type=\"checkbox\" />.*?<span id=\"msgfrom_txt\">(.*?)</span>.*?<span id=\"msgsubject_txt\"><a .*?>(.*?)</a>.*?<span id=\"msgdate_txt\">(.*?)&nbsp;</span>"
																 options:(NSRegularExpressionCaseInsensitive |  NSRegularExpressionDotMatchesLineSeparators)
																   error:nil];
		classesPattern = [NSRegularExpression regularExpressionWithPattern:@"=([0-9]{5}\\.[0-9]{6})\" onClick=\"\" onMouseOver=\"window.status=''; return true;\">(.*?)</a>.*?<span id=\"sclasssection_txt\">(.*?)</span>"
																   options:(NSRegularExpressionCaseInsensitive |  NSRegularExpressionDotMatchesLineSeparators)
																	 error:nil];
		bulletinsPattern = [NSRegularExpression regularExpressionWithPattern:@"<span class=\"uportal-text\">Title:</span></td>\\s+<td align=\"Left\" valign=\"top\"><span class=\"uportal-text\" colspan=\"2\">(.*?)</span></td>\\s+</tr>\\s+</table>\\s+</div>\\s+<div class=\"uportal-text\" style=\"padding: 3px 3px 3px 3px;\">(.*?)</div>\\s+</div>\\s+</td>"
																	 options:(NSRegularExpressionCaseInsensitive |  NSRegularExpressionDotMatchesLineSeparators)
																	   error:nil];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			self.loginViewController = [[CLLoginViewController alloc] initWithNibName:@"CLLoginViewController_iPhone" bundle:nil];
		} else {
			self.loginViewController = [[CLLoginViewController alloc] initWithNibName:@"CLLoginViewController_iPad" bundle:nil];
		}
		
		[loginViewController setViewController:self];
		loginViewController.title = @"myUsask";
		self.loginNavigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
		
		UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:loginViewController action:@selector(doLogin:)];
		[[loginViewController navigationItem] setRightBarButtonItem:loginButton animated:YES];
		
		UIViewController *inboxController;
		self.inboxViewController = [[CLInboxViewController alloc] initWithNibName:@"CLInboxViewController" bundle:nil];
		UINavigationController *inboxNavigationController = [[UINavigationController alloc] initWithRootViewController:inboxViewController];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			[inboxViewController setNavigationController:inboxNavigationController];
			inboxController = inboxNavigationController;
			
			UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:inboxViewController action:@selector(doCompose:)];
			[[inboxViewController navigationItem] setRightBarButtonItem:composeButton animated:YES];
		} else {
			CLEmailViewController *emailViewController = [[CLEmailViewController alloc] initWithNibName:@"CLEmailViewController" bundle:nil];
			emailViewController.title = @"Message";
			UINavigationController *emailNavigationController = [[UINavigationController alloc] initWithRootViewController:emailViewController];
			
			UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:inboxViewController action:@selector(doCompose:)];
			[[emailViewController navigationItem] setRightBarButtonItem:composeButton animated:YES];
			
			IntelligentSplitViewController *inboxSplitController = [[IntelligentSplitViewController alloc] init];
			inboxSplitController.delegate = emailViewController;
			inboxSplitController.viewControllers = [NSArray arrayWithObjects:inboxNavigationController, emailNavigationController, nil];
			
			[inboxViewController setEmailViewController:emailViewController];
			[inboxViewController setSplitViewController:inboxSplitController];
			
			inboxController = inboxSplitController;
		}
		
		inboxController.title = @"Inbox";
		inboxController.tabBarItem.image = [UIImage imageNamed:@"40-inbox"];
		
		UIViewController *classesController;
		self.classesViewController = [[CLClassesViewController alloc] initWithNibName:@"CLClassesViewController" bundle:nil];
		UINavigationController *classesNavigationController = [[UINavigationController alloc] initWithRootViewController:classesViewController];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			[classesViewController setNavigationController:classesNavigationController];
			classesController = classesNavigationController;
		} else {
			CLClassMembersViewController *classMembersViewController = [[CLClassMembersViewController alloc] initWithNibName:@"CLClassMembersViewController" bundle:nil];
			classMembersViewController.title = @"Members";
			UINavigationController *classMembersNavigationController = [[UINavigationController alloc] initWithRootViewController:classMembersViewController];
			
			IntelligentSplitViewController *classesSplitController = [[IntelligentSplitViewController alloc] init];
			classesSplitController.delegate = classMembersViewController;
			classesSplitController.viewControllers = [NSArray arrayWithObjects:classesNavigationController, classMembersNavigationController, nil];
			
			[classesViewController setMembersViewController:classMembersViewController];
			[classesViewController setSplitViewController:classesSplitController];
			
			classesController = classesSplitController;
		}
		
		classesController.title = @"Classes";
		classesController.tabBarItem.image = [UIImage imageNamed:@"96-book"];
		
		UIViewController *bulletinsController;
		self.bulletinsViewController = [[CLBulletinsViewController alloc] initWithNibName:@"CLBulletinsViewController" bundle:nil];
		UINavigationController *bulletinsNavigationController = [[UINavigationController alloc] initWithRootViewController:bulletinsViewController];
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
			[bulletinsViewController setNavigationController:bulletinsNavigationController];
			bulletinsController = bulletinsNavigationController;
		} else {
			CLReadBulletinViewController *readBulletinViewController = [[CLReadBulletinViewController alloc] initWithNibName:@"CLReadBulletinViewController" bundle:nil];
			readBulletinViewController.title = @"Item";
			UINavigationController *readBulletinNavigationController = [[UINavigationController alloc] initWithRootViewController:readBulletinViewController];
			
			IntelligentSplitViewController *bulletinsSplitController = [[IntelligentSplitViewController alloc] init];
			bulletinsSplitController.delegate = readBulletinViewController;
			bulletinsSplitController.viewControllers = [NSArray arrayWithObjects:bulletinsNavigationController, readBulletinNavigationController, nil];
			
			[bulletinsViewController setBulletinViewController:readBulletinViewController];
			[bulletinsViewController setSplitViewController:bulletinsSplitController];
			
			bulletinsController = bulletinsSplitController;
		}
		
		bulletinsController.title = @"Bulletins";
		bulletinsController.tabBarItem.image = [UIImage imageNamed:@"166-newspaper"];
		
		self.tabBarController = [[UITabBarController alloc] init];
		self.tabBarController.viewControllers = [NSArray arrayWithObjects:inboxController, classesController, bulletinsController, nil];
		
		[self addChildViewController:self.loginNavigationController];
		[self addChildViewController:self.tabBarController];
		[self.view addSubview:self.loginNavigationController.view];
	}
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)URLRequest:(CLURLRequest *)URLRequest didFinishWithString:(NSString *)string {
	if ([URLRequest tag] == URL_REQUEST_LOGIN_FIRST) {
		[self continueLoginUsingString:string];
	} else if ([URLRequest tag] == URL_REQUEST_LOGIN_SECOND) {
		[self checkLoginUsingString:string];
	} else if ([URLRequest tag] == URL_REQUEST_LOGIN_THIRD) {
		[self finishLoginUsingString:string];
	} else if ([URLRequest tag] == URL_REQUEST_INBOX) {
		[self processInboxUsingString:string];
	} else if ([URLRequest tag] == URL_REQUEST_CLASSES) {
		[self processClassesUsingString:string];
	}
	
	self.activeURLRequest = nil;
}

- (void)doLoginWithNSID:(NSString *)aNSID password:(NSString *)aPassword {
	if (CL_FAKE_NETWORK_DATA == 0) {
		self.NSID = aNSID;
		self.password = aPassword;
		
		self.loadingHUD = [[MBProgressHUD alloc] initWithView:self.view];
		self.loadingHUD.labelText = @"Loading";
		[self.view addSubview:loadingHUD];
		[self.loadingHUD show:YES];
		
		CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
		[URLRequest setUrlString:@"https://paws.usask.ca/cp/home/displaylogin"];
		[URLRequest setTag:URL_REQUEST_LOGIN_FIRST];
		[URLRequest setDelegate:self];
		[URLRequest startConnection];
		
		self.activeURLRequest = URLRequest;
	} else {
		
		// bulletins
		NSMutableArray *bulletinsData = [NSMutableArray array];
		NSDictionary *bulletin;
		
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"Students: need help on an assignment?", @"title", @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", @"body", nil];
		[bulletinsData addObject:bulletin];
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"Lynda.com kiosks", @"title", @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", @"body", nil];
		[bulletinsData addObject:bulletin];
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"2012 conference", @"title", @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", @"body", nil];
		[bulletinsData addObject:bulletin];
		
		[bulletinsViewController setBulletinsData:bulletinsData];
		
		// inbox
		NSMutableArray *inboxData = [NSMutableArray array];
		NSDictionary *msg;
		
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"msgId", @"John Smith", @"from", @"testing", @"subject", @"01/18/12 09:54 AM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"msgId", @"Jane Smith", @"from", @"testing2", @"subject", @"01/17/12 01:52 PM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"msgId", @"Tyler Smith", @"from", @"testing3", @"subject", @"09/01/09 01:51 PM", @"date", nil];
		[inboxData addObject:msg];
		
		[inboxViewController setInboxData:inboxData];
		
		// classes
		NSMutableArray *classesData = [NSMutableArray array];
		NSDictionary *class;
		
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"courseId", @"Physics", @"name", @"PHYS 101", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"courseId", @"Chemistry", @"name", @"CHEM 101", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"courseId", @"Math", @"name", @"MATH 101", @"courseNumber", nil];
		[classesData addObject:class];
		
		[classesViewController setClassesData:classesData];
		
		[UIView beginAnimations:nil context:nil]; 
		[UIView setAnimationDuration:1.0]; 
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
		[self.view addSubview:self.tabBarController.view]; 
		[self.loginNavigationController.view removeFromSuperview];
		[UIView commitAnimations];
	}
}

- (void)continueLoginUsingString:(NSString *)requestString {
	NSString *escapedNSID = [NSID clURLEncodedParameterString];
	NSString *escapedPassword = [password clURLEncodedParameterString];
	NSString *postString = [NSString stringWithFormat:@"user=%@&pass=%@", escapedNSID, escapedPassword];
	NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
	
	self.NSID = nil;
	self.password = nil;
	
	CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
	[URLRequest setUrlString:@"https://paws.usask.ca/cp/home/CaptureLogin"];
	[URLRequest setPostData:postData];
	[URLRequest setTag:URL_REQUEST_LOGIN_SECOND];
	[URLRequest setDelegate:self];
	[URLRequest startConnection];
	
	self.activeURLRequest = URLRequest;
}

- (void)checkLoginUsingString:(NSString *)requestString {
	if ([requestString rangeOfString:@"loginok"].location != NSNotFound) {
		CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
		[URLRequest setUrlString:@"http://paws.usask.ca/cp/home/next"];
		[URLRequest setTag:URL_REQUEST_LOGIN_THIRD];
		[URLRequest setDelegate:self];
		[URLRequest startConnection];
		
		self.activeURLRequest = URLRequest;
	} else {
		[self.loadingHUD hide:YES];
		self.loadingHUD = nil;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		
		[[loginViewController NSIDTextField] becomeFirstResponder];
	}
}

- (void)finishLoginUsingString:(NSString *)requestString {
	CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
	[URLRequest setUrlString:@"http://paws.usask.ca/cp/email/messageList/"];
	[URLRequest setTag:URL_REQUEST_INBOX];
	[URLRequest setDelegate:self];
	[URLRequest startConnection];
	
	self.activeURLRequest = URLRequest;
	
	NSMutableArray *bulletinsData = [NSMutableArray array];
	NSArray *bulletinsMatches = [bulletinsPattern matchesInString:requestString options:0 range:NSMakeRange(0, [requestString length])];
	
	for (NSTextCheckingResult *match in bulletinsMatches) {
		NSString *title = [requestString substringWithRange:[match rangeAtIndex:1]];
		NSString *body = [requestString substringWithRange:[match rangeAtIndex:2]];
		
		body = [body stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
		
		NSDictionary *bulletin = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", body, @"body", nil];
		[bulletinsData addObject:bulletin];
	}
	
	[bulletinsViewController setBulletinsData:bulletinsData];
}

- (void)processInboxUsingString:(NSString *)requestString {
	
	CLURLRequest *URLRequest = [[CLURLRequest alloc] init];
	[URLRequest setUrlString:@"http://paws.usask.ca/cp/school/schedule"];
	[URLRequest setTag:URL_REQUEST_CLASSES];
	[URLRequest setDelegate:self];
	[URLRequest startConnection];
	
	self.activeURLRequest = URLRequest;
	
	NSMutableArray *inboxData = [NSMutableArray array];
	NSArray *inboxMatches = [inboxPattern matchesInString:requestString options:0 range:NSMakeRange(0, [requestString length])];
	
	for (NSTextCheckingResult *match in inboxMatches) {
		NSString *msgId = [requestString substringWithRange:[match rangeAtIndex:1]];
		NSString *from = [requestString substringWithRange:[match rangeAtIndex:2]];
		NSString *subject = [requestString substringWithRange:[match rangeAtIndex:3]];
		NSString *date = [requestString substringWithRange:[match rangeAtIndex:4]];
		
		// process the "from" field
		if ([from hasPrefix:@"&#034;"]) {
			from = [from substringFromIndex:6];
			
			if ([from rangeOfString:@"&#034;"].location != NSNotFound) {
				from = [from substringToIndex:[from rangeOfString:@"&#034;"].location];
			}
		}
		
		if ([from hasSuffix:@"&nbsp;"]) {
			from = [from substringToIndex:[from rangeOfString:@"&nbsp;" options:NSBackwardsSearch].location];
		}
		
		NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:msgId, @"msgId", from, @"from", subject, @"subject", date, @"date", nil];
		[inboxData addObject:msg];
	}
	
	[inboxViewController setInboxData:inboxData];
}

- (void)processClassesUsingString:(NSString *)requestString {
	NSMutableArray *classesData = [NSMutableArray array];
	NSArray *classesMatches = [classesPattern matchesInString:requestString options:0 range:NSMakeRange(0, [requestString length])];
	
	for (NSTextCheckingResult *match in classesMatches) {
		NSString *courseId = [requestString substringWithRange:[match rangeAtIndex:1]];
		NSString *name = [requestString substringWithRange:[match rangeAtIndex:2]];
		NSString *courseNumber = [requestString substringWithRange:[match rangeAtIndex:3]];
		
		unichar thirdLastCharacter = [courseNumber characterAtIndex:([courseNumber length] - 3)];
		
		if (thirdLastCharacter != 'L' && thirdLastCharacter != 'T') {
			NSDictionary *class = [NSDictionary dictionaryWithObjectsAndKeys:courseId, @"courseId", name, @"name", courseNumber, @"courseNumber", nil];
			[classesData addObject:class];
		}
	}
	
	[classesViewController setClassesData:classesData];
	
	[self.loadingHUD hide:YES];
	self.loadingHUD = nil;
	
	[UIView beginAnimations:nil context:nil]; 
	[UIView setAnimationDuration:1.0]; 
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
	[self.view addSubview:self.tabBarController.view]; 
	[self.loginNavigationController.view removeFromSuperview];
	[UIView commitAnimations];
}

@end
