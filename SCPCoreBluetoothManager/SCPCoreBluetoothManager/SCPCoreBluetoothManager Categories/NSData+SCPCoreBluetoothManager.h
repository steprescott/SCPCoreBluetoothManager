//
//  NSData+SCPCoreBluetoothManager.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 02/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SCPCoreBluetoothManager)

+ (NSString *)hexStringFromNSData:(NSData *)data;
- (NSString *)hexString;

@end
