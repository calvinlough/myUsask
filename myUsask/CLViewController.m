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
	self.loadingHUD = [[MBProgressHUD alloc] initWithView:self.view];
	self.loadingHUD.labelText = @"Loading";
	[self.view addSubview:loadingHUD];
	[self.loadingHUD show:YES];
	
	if (CL_FAKE_NETWORK_DATA == 0) {
		self.NSID = aNSID;
		self.password = aPassword;
		
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
		
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"Build Your Communication Talent: Toastmasters", @"title", @"Build your Communication Talent:  Summer Fun with Public Speaking<br /><br />Campus Howlers Toastmasters Club<br /><br />May Open House,  Guests Welcome.<br /><br />Coffee and Breakfast Treats Provided.<br /><br />Come and check out a great place for you to develop your communication and leadership skills. Campus Howlers Toastmasters Club welcomes all guests to their upcoming Open House. Toastmasters International is a world leader in communication and leadership development. Members have many opportunities to practice public speaking, work on skills valuable for that next interview, and learn valuable leadership tools. A Toastmasters meeting is a learn-by-doing workshop with a no-pressure atmosphere. Invest in your future: check out a meeting near you. Campus Howlers Toastmasters has an Open House meeting, specially geared to show our guests how a Toastmasters Club can help.<br /><br />Wednesday May 1, 2013<br /><br />7:15 AM – 8:15 AM         Room 2D21 College of Agriculture<br /><br />For more information, contact:<br />campushowlers.toastmastersclubs.org/<br />or<br />contact-7536@toastmastersclubs.org", @"body", nil];
		[bulletinsData addObject:bulletin];
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"Public Lecture", @"title", @"Dr. Julie Gibbings (University of Manitoba) is giving a public lecture at the Frances Morrison Library on Thursday April 25th at 6pm. The lecture is entitled \"The Work That History Does: Race, Labour, and Postcolonial Nationalism in Guatemala, 1860-1930. After the lecture, Dr. Gibbings will be joined by five university students to discuss the more general issue of access to history in terms of sources, teaching, and writing style. Questions from the audience will be welcome.", @"body", nil];
		[bulletinsData addObject:bulletin];
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"English Grad Banquet! Buy Tickets Soon!", @"title", @"Greetings, the EUS is proud to host the first annual year-end banquet during the evening of May 24th at Marquis Hall. We'll be offering a buffet style dinner, with a small program to compliment the evening's festivities.", @"body", nil];
		[bulletinsData addObject:bulletin];
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"P.G. Sorenson Distinguished Graduate Lecture", @"title", @"The field of educational assessment benefits from contributions in several domains including: cognitive science, measurement science, computer science, and instructional science. Dr. Zapata-Rivera will describe how his early research at the ARIES lab has informed his work on designing, implementing, and evaluating new generation assessments over the past ten years.", @"body", nil];
		[bulletinsData addObject:bulletin];
		bulletin = [NSDictionary dictionaryWithObjectsAndKeys:@"Seeking Women Aged 18 – 30", @"title", @"To participate in a research study that will assist in the development of a testing procedure that may help improve the treatment of women with stress urinary incontinence.", @"body", nil];
		[bulletinsData addObject:bulletin];
		
		[bulletinsViewController setBulletinsData:bulletinsData];
		
		// inbox
		NSMutableArray *inboxData = [NSMutableArray array];
		NSDictionary *msg;
		
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"msgId", @"Esther Petty", @"from", @"Class tomorrow", @"subject", @"04/23/13 02:36 PM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"msgId", @"Brittany McCarley", @"from", @"Assignment #3", @"subject", @"04/23/13 11:02 AM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"msgId", @"Thomas Finley", @"from", @"Re: Lunch friday?", @"subject", @"04/22/13 11:51 PM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"4", @"msgId", @"Daniel Dunlap", @"from", @"Hey", @"subject", @"04/22/13 01:19 PM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"5", @"msgId", @"Scott Koury", @"from", @"(no subject)", @"subject", @"04/21/13 01:19 PM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"6", @"msgId", @"Thomas Finley", @"from", @"Lunch friday?", @"subject", @"04/20/13 01:19 PM", @"date", nil];
		[inboxData addObject:msg];
		msg = [NSDictionary dictionaryWithObjectsAndKeys:@"7", @"msgId", @"Williams McGhie", @"from", @"Finals", @"subject", @"04/18/13 01:19 PM", @"date", nil];
		[inboxData addObject:msg];
		
		[inboxViewController setInboxData:inboxData];
		
		// classes
		NSMutableArray *classesData = [NSMutableArray array];
		NSDictionary *class;
		
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"courseId", @"Physics and the Universe", @"name", @"PHYS 115.3", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"courseId", @"General Chemistry I", @"name", @"CHEM 112.3", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"courseId", @"Calculus I", @"name", @"MATH 110.3", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"4", @"courseId", @"Introduction to Computer Science and Programming", @"name", @"CMPT 111.3", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"5", @"courseId", @"Literature and Composition", @"name", @"ENG 110.6", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"6", @"courseId", @"Introduction to Philosophy", @"name", @"PHIL 110.6", @"courseNumber", nil];
		[classesData addObject:class];
		class = [NSDictionary dictionaryWithObjectsAndKeys:@"7", @"courseId", @"The Nature of Life", @"name", @"BIOL 120.3", @"courseNumber", nil];
		[classesData addObject:class];
		
		[classesViewController setClassesData:classesData];
		
		[self performSelector:@selector(transitionFinishedLoading) withObject:nil afterDelay:5.0];
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
	
	[self transitionFinishedLoading];
}

- (void)transitionFinishedLoading {
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
