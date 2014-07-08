//
//  NSString+SCPCoreBluetoothManager.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 06/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "NSString+SCPCoreBluetoothManager.h"

@implementation NSString (SCPCoreBluetoothManager)

+ (NSString *)stringFromHexString:(NSString *)hexString
{
	NSMutableString * string = [[NSMutableString alloc] init];
	
	NSInteger i = 0;
	
	while (i < [hexString length] - 1)
	{
		NSString * hexChar = [hexString substringWithRange: NSMakeRange(i, 2)];
		NSInteger value = 0;
		sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
		[string appendFormat:@"%c", (char)value];
		i+=2;
	}
	
	return string;
}

- (NSString *)ASCIIStringFromHexString
{
	NSMutableString * string = [[NSMutableString alloc] init];
	
	NSInteger i = 0;
	
	while (i < [self length] - 1)
	{
		NSString * hexChar = [self substringWithRange: NSMakeRange(i, 2)];
		NSInteger value = 0;
		sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
		[string appendFormat:@"%c", (char)value];
		i+=2;
	}
	
	return string;
}

@end
