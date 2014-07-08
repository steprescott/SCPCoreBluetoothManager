//
//  NSData+SCPCoreBluetoothManager.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 02/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "NSData+SCPCoreBluetoothManager.h"

@implementation NSData (SCPCoreBluetoothManager)

+ (NSString *)hexStringFromNSData:(NSData *)data
{
    NSUInteger capacity = [data length] * 2;
	
    NSMutableString *string = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [data bytes];
	
    for (NSUInteger i = 0; i < [data length]; ++i)
    {
        [string appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }
	
	return string;
}

- (NSString *)hexString
{
    NSUInteger capacity = [self length] * 2;
	
    NSMutableString *string = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *dataBuffer = [self bytes];
	
    for (NSUInteger i = 0; i < [self length]; ++i)
    {
        [string appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    }

	return string;
}

@end
