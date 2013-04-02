//
//  CLURLRequest.h
//  myUsask
//
//  Created by Calvin Lough on 1/1/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLURLRequestDelegate.h"

@interface CLURLRequest : NSObject

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSData *postData;
@property (assign, nonatomic) id <CLURLRequestDelegate> delegate;
@property (assign, nonatomic) NSInteger tag;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (strong, nonatomic) NSMutableData *receivedData;

- (void)startConnection;
- (void)stopConnection;

@end
