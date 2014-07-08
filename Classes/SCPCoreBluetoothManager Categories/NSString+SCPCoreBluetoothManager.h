//
//  NSString+SCPCoreBluetoothManager.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 06/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SCPCoreBluetoothManager)

+ (NSString *)stringFromHexString:(NSString *)hexString;
- (NSString *)ASCIIStringFromHexString;

@end
