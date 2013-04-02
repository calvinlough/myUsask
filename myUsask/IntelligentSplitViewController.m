//
//  IntelligentSplitViewController.m
//  From TexLege by Gregory S. Combs
//
//  Released under the Creative Commons Attribution 3.0 Unported License
//  Please see the included license page for more information.
//
//  In a nutshell, you can use this, just attribute this to me in your "thank you" notes or about box.
//

#import "IntelligentSplitViewController.h"
#import <objc/message.h>

@implementation IntelligentSplitViewController

- (id) init {
	self = [super init];
	if (self != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(willRotate:)
													 name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didRotate:)
													 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotate:(id)sender {
	if (![self isViewLoaded])
		return;
	
	NSNotification *notification = sender;
	if (!notification)
		return;
	
	UIInterfaceOrientation toOrientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];

	UITabBarController *tabBar = self.tabBarController;
	BOOL notModal = (!tabBar.modalViewController);
	BOOL isSelectedTab = [self.tabBarController.selectedViewController isEqual:self];
	
	NSTimeInterval duration = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
	
	if (!isSelectedTab || !notModal) {
		[super willRotateToInterfaceOrientation:toOrientation duration:duration];
		
		UIViewController *master = [self.viewControllers objectAtIndex:0];
		NSObject *theDelegate = (NSObject *)self.delegate;

		UIBarButtonItem *button = [super valueForKey:@"_barButtonItem"];
		
		if (UIInterfaceOrientationIsPortrait(toOrientation)) {
			if (theDelegate && [theDelegate respondsToSelector:@selector(splitViewController:willHideViewController:withBarButtonItem:forPopoverController:)]) {

				@try {
					UIPopoverController *popover = [super valueForKey:@"_hiddenPopoverController"];
					objc_msgSend(theDelegate, @selector(splitViewController:willHideViewController:withBarButtonItem:forPopoverController:), self, master, button, popover);
				}
				@catch (NSException * e) {
					NSLog(@"There was a nasty error while notifyng splitviewcontrollers of an orientation change: %@", [e description]);
				}
			}
		}
		else if (UIInterfaceOrientationIsLandscape(toOrientation)) {
			if (theDelegate && [theDelegate respondsToSelector:@selector(splitViewController:willShowViewController:invalidatingBarButtonItem:)]) {
				@try {
					objc_msgSend(theDelegate, @selector(splitViewController:willShowViewController:invalidatingBarButtonItem:), self, master, button);
				}
				@catch (NSException * e) {
					NSLog(@"There was a nasty error while notifyng splitviewcontrollers of an orientation change: %@", [e description]);
				}
			}
		}
	}
}

- (void)didRotate:(id)sender {
	if (![self isViewLoaded])
		return;
	
	NSNotification *notification = sender;
	if (!notification)
		return;
	UIInterfaceOrientation fromOrientation = [[notification.userInfo valueForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
	
	UITabBarController *tabBar = self.tabBarController;
	BOOL notModal = (!tabBar.modalViewController);
	BOOL isSelectedTab = [self.tabBarController.selectedViewController isEqual:self];
	
	if (!isSelectedTab || !notModal)  {
		[super didRotateFromInterfaceOrientation:fromOrientation];
	}
}

@end
