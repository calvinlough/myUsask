//
//  CLURLRequestDelegate.m
//  myUsask
//
//  Created by Calvin Lough on 1/1/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

@class CLURLRequest;

@protocol CLURLRequestDelegate <NSObject>

- (void)URLRequest:(CLURLRequest *)URLRequest didFinishWithString:(NSString *)string;

@optional
- (BOOL)URLRequest:(CLURLRequest *)URLRequest didRedirectToURLString:(NSString *)urlString;

@end