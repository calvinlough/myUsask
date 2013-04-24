//
//  CLURLRequest.m
//  myUsask
//
//  Created by Calvin Lough on 1/1/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import "CLURLRequest.h"

@implementation CLURLRequest

@synthesize urlString;
@synthesize postData;
@synthesize delegate;
@synthesize tag;
@synthesize urlConnection;
@synthesize receivedData;

- (id)init {
	self = [super init];
	if (self != nil) {
		[self setReceivedData:[NSMutableData data]];
	}
	return self;
}

- (void)dealloc {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)startConnection {
	NSLog(@"starting connection for %@", urlString);
	
	[receivedData setLength:0];
	[self setUrlConnection:nil];
	
	if (urlString == nil) {
		[delegate URLRequest:self didFinishWithString:nil];
		return;
	}
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *fetchUrlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
	[fetchUrlRequest setHTTPShouldHandleCookies:YES];
	[fetchUrlRequest setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:8.0.1) Gecko/20100101 Firefox/8.0.1" forHTTPHeaderField:@"User-Agent"];
	[fetchUrlRequest setValue:@"text/html,application/xhtml+xml,application/xml" forHTTPHeaderField:@"Accept"];
	[fetchUrlRequest setValue:@"en-us,en" forHTTPHeaderField:@"Accept-Language"];
	[fetchUrlRequest setValue:@"ISO-8859-1,utf-8" forHTTPHeaderField:@"Accept-Charset"];
	[fetchUrlRequest setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
	
	if (postData != nil) {
		[fetchUrlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[fetchUrlRequest setValue:[NSString stringWithFormat:@"%li", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
		[fetchUrlRequest setHTTPMethod:@"POST"];
		[fetchUrlRequest setHTTPBody:postData];
	} else {
		[fetchUrlRequest setHTTPMethod:@"GET"];
	}
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:fetchUrlRequest delegate:self startImmediately:YES];
	
	if (conn == nil) {
		[delegate URLRequest:self didFinishWithString:nil];
		return;
	}
	
	[self setUrlConnection:conn];
}

- (void)stopConnection {
	NSLog(@"stopping connection");
	
	[urlConnection cancel];
	
	[delegate URLRequest:self didFinishWithString:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"didReceiveResponse");
	NSLog(@"url: %@", [[response URL] absoluteString]);
	
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSLog(@"status code: %d", [(NSHTTPURLResponse *)response statusCode]);
		
		NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
		NSArray *keys = [headers allKeys];
		
		for (NSString *key in keys) {
			NSLog(@"%@: %@", key, [headers objectForKey:key]);
		}
	}
	
	NSLog(@"----------------------------");
	
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	
	if ([urlString isEqualToString:[[request URL] absoluteString]] == NO) {
		NSLog(@"got redirect from %@ to %@", urlString, [[request URL] absoluteString]);
	}
	
	self.urlString = [[request URL] absoluteString];
	
	return request;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"didFailWithError %d", [error code]);
	
	if ([error code] == -1009) {
		NSLog(@"offline... retrying soon");
		
		[self performSelector:@selector(startConnection) withObject:nil afterDelay:10];
		
		NSLog(@"timer set for retry...");
		
		return;
	}
	
	NSLog(@"after");
	
	[delegate URLRequest:self didFinishWithString:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *receivedString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
	NSLog(@"finished %@", urlString);
	NSLog(@" - - - - - - - - - - - - - - - - - - - - - - - - - - - ");
	NSLog(@"%@", receivedString);
	NSLog(@" - - - - - - - - - - - - - - - - - - - - - - - - - - - ");
	
	[delegate URLRequest:self didFinishWithString:receivedString];
}

@end
