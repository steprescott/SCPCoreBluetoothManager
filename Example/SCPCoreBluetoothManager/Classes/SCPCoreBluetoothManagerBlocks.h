//
//  SCPCoreBluetoothManagerBlocks.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 21/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

//This file is to hold the block definitions to be used in several classes

#ifndef SCPCoreBluetoothManager_SCPCoreBluetoothManagerBlocks_h
#define SCPCoreBluetoothManager_SCPCoreBluetoothManagerBlocks_h

typedef void(^StartUpSuccess)();
typedef void(^StartUpFailure)(CBCentralManagerState cbCentralManagerState);

typedef void(^DidDiscoverPeripheral)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

typedef void(^ConnectToPeripheralSuccess)(CBPeripheral *peripheral);
typedef void(^ConnectToPeripheralFailure)(CBPeripheral *peripheral, NSError *error);

typedef void(^DidDiscoverServicesSuccess)(NSArray *discoveredServices);
typedef void(^DidDiscoverServicesFailure)(NSError *error);

typedef void(^DidDiscoverCharacteristicsForServiceSuccess)(NSArray *discoveredCharacteristics);
typedef void(^DidDiscoverCharacteristicsForServiceFailure)(NSError *error);

typedef void(^DidUpdateNotificationStateForCharacteristic)(BOOL isNotifying);
typedef void(^DidUpdateValueForCharacteristic)(NSData *updatedValue);
typedef void(^DidWriteValueForCharacteristic)(NSData *returnedValue);

typedef void(^CharacteristicSubscriptionFailure)(NSError *error);

typedef void(^DidDisconnectFromPeripheral)(CBPeripheral *peripheral);

#endif
