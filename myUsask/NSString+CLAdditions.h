//
//  NSString+CLAdditions.h
//  myUsask
//
//  Created by Calvin Lough on 1/1/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (CLAdditions)

- (NSString *)clTrimmedString;
- (NSString *)clPlainTextString;
- (NSString *)clURLEncodedParameterString;
- (NSString *)clRelativeDate;

@end
