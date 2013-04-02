//
//  NSString+CLAdditions.m
//  myUsask
//
//  Created by Calvin Lough on 1/1/12.
//  Copyright (c) 2012 Calvin Lough. All rights reserved.
//

#import "NSString+CLAdditions.h"

@interface CLPlainTextParser : NSObject<NSXMLParserDelegate> {
@private
    NSMutableArray *strings;
}

- (NSString *)getCharsFound;

@end

@implementation CLPlainTextParser

- (id)init {
	if ((self = [super init])) {
		strings = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[strings addObject:string];
}

- (NSString *)getCharsFound {
	return [[strings componentsJoinedByString:@" "] clTrimmedString];
}

@end

@implementation NSString (CLAdditions)

- (NSString *)clTrimmedString {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)clPlainTextString {
	NSString *string = [NSString stringWithFormat:@"<root>%@</root>", self];
	
	NSStringEncoding encoding = string.fastestEncoding;
	NSData *data = [string dataUsingEncoding:encoding];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	
	CLPlainTextParser *plainTextParser = [[CLPlainTextParser alloc] init];
	parser.delegate = plainTextParser;
	[parser parse];
	
	NSString *strippedString = [plainTextParser getCharsFound];
	strippedString = [strippedString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	
	BOOL didChange = YES;
	
	while (didChange) {
		NSString *newStrippedString = [strippedString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
		didChange = NO;
		
		if ([newStrippedString length] < [strippedString length]) {
			didChange = YES;
		}
		
		strippedString = newStrippedString;
	}
	
	strippedString = [strippedString clTrimmedString];
	
	return strippedString;
}

- (NSString *)clURLEncodedParameterString {
	NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, CFSTR("!*'\"();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	
	// properly encode newlines
	encodedString = [encodedString stringByReplacingOccurrencesOfString:@"%0A" withString:@"%0D%0A"];
	
	return encodedString;
}

- (NSString *)clRelativeDate {
	NSString *dayMonthYear = [self substringToIndex:[self rangeOfString:@" "].location];
	NSInteger month = [[dayMonthYear substringWithRange:NSMakeRange(0, 2)] integerValue];
	NSInteger day = [[dayMonthYear substringWithRange:NSMakeRange(3, 2)] integerValue];
	NSInteger year = [[dayMonthYear substringWithRange:NSMakeRange(6, 2)] integerValue];
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSDateComponents *currentComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate date]];
	NSInteger currentMonth = [currentComponents month];
	NSInteger currentDay = [currentComponents day];
	NSInteger currentYear = [currentComponents year] - 2000;
	
	NSString *processedDate = dayMonthYear;
	
	if (day == currentDay && month == currentMonth && year == currentYear) {
		processedDate = [[self substringFromIndex:([self rangeOfString:@" "].location + 1)] lowercaseString];
		
		if ([processedDate hasPrefix:@"0"]) {
			processedDate = [processedDate substringFromIndex:1];
		}
	} else if (year == currentYear) {
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setMonth:month];
		[components setDay:day];
		[components setYear:(year + 2000)];
		NSDate *date = [gregorian dateFromComponents:components];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM d"];
		processedDate = [dateFormatter stringFromDate:date];
	}
	
	return processedDate;
}

@end
