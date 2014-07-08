//
//  CBService+SCPCoreBluetoothManager.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 21/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "SCPCoreBluetoothManagerBlocks.h"

@interface CBService (SCPCoreBluetoothManager)

- (void)discoverCharacteristics:(NSArray *)characteristics success:(DidDiscoverCharacteristicsForServiceSuccess)success failure:(DidDiscoverCharacteristicsForServiceFailure)failure;

@end
