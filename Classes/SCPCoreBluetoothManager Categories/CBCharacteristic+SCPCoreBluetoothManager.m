//
//  CBCharacteristic+SCPCoreBluetoothManager.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 22/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "CBCharacteristic+SCPCoreBluetoothManager.h"
#import "SCPCoreBluetoothCentralManager.h"

@implementation CBCharacteristic (SCPCoreBluetoothManager)

- (void)setDidUpdateValueBlock:(DidUpdateValueForCharacteristic)didUpdateValueBlock
{
    [[[[self service] peripheral] centralManager] setDidUpdateValueForCharacteristicBlock:didUpdateValueBlock];
}

- (void)readValue
{
    [[[self service] peripheral] readValueForCharacteristic:self];
}

@end
