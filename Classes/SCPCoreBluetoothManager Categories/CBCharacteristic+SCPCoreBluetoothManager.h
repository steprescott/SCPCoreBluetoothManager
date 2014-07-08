//
//  CBCharacteristic+SCPCoreBluetoothManager.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 22/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "SCPCoreBluetoothManagerBlocks.h"

@interface CBCharacteristic (SCPCoreBluetoothManager)

- (void)setDidUpdateValueBlock:(DidUpdateValueForCharacteristic)didUpdateValueBlock;
- (void)readValue;

@end
