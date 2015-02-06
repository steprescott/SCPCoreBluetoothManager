//
//  CBPeripheral+SCPCoreBluetoothManager.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 21/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <objc/runtime.h>

#import "SCPCoreBluetoothManagerBlocks.h"

@class SCPCoreBluetoothCentralManager;

@interface CBPeripheral (SCPCoreBluetoothManager)

@property (nonatomic, strong) SCPCoreBluetoothCentralManager *centralManager;

- (void)connectSuccess:(ConnectToPeripheralSuccess)success failure:(ConnectToPeripheralFailure)failure;
- (void)discoverServices:(NSArray *)services success:(DidDiscoverServicesSuccess)success failure:(DidDiscoverServicesFailure)failure;
- (void)setDidWriteValueForCharacteristicBlock:(DidWriteValueForCharacteristic)didWriteValueForCharacteristicBlock;
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic;
- (void)disconnect;

@end
