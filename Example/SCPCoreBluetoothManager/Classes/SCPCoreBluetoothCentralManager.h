//
//  SCPCoreBluetoothManager.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 02/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

#import "SCPCoreBluetoothManagerCategories.h"
#import "SCPCoreBluetoothManagerBlocks.h"

@interface SCPCoreBluetoothCentralManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, copy) void (^startUpSuccessBlock)();
@property (nonatomic, copy) void (^startUpFailureBlock)(CBCentralManagerState cbCentralManagerState);

@property (nonatomic, copy) void (^didDiscoverPeripheralBlock)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);

@property (nonatomic, copy) void (^connectToPeripheralSuccessBlock)(CBPeripheral *peripheral);
@property (nonatomic, copy) void (^connectToPeripheralFailureBlock)(CBPeripheral *peripheral, NSError *error);

@property (nonatomic, copy) void (^didDiscoverServicesSuccessBlock)(NSArray *discoveredServices);
@property (nonatomic, copy) void (^didDiscoverServicesFailureBlock)(NSError *error);

@property (nonatomic, copy) void (^didDiscoverCharacteristicsForServiceSuccessBlock)(NSArray *discoveredCharacteristics);
@property (nonatomic, copy) void (^didDiscoverCharacteristicsForServiceFailureBlock)(NSError *error);

@property (nonatomic, copy) void (^didUpdateNotificationStateForCharacteristicBlock)(BOOL isNotifying);
@property (nonatomic, copy) void (^didUpdateValueForCharacteristicBlock)(NSData *updatedValue);
@property (nonatomic, copy) void (^characteristicSubscriptionFailureBlock)(NSError *error);

@property (nonatomic, copy) void (^didWriteValueForCharacteristicBlock)(NSData *returnedValue);

@property (nonatomic, copy) void (^didDisconnectFromPeripheralBlock)(CBPeripheral *peripheral);

@property (nonatomic, assign) BOOL isReady;

- (void)startUpSuccess:(StartUpSuccess)success failure:(StartUpFailure)failure;

- (void)scanForPeripheralsWithServices:(NSArray *)services allowDuplicates:(BOOL)allowDuplicates didDiscoverPeripheral:(DidDiscoverPeripheral)didDiscoverPeripheral;

- (void)connectToPeripheral:(CBPeripheral *)peripheral success:(ConnectToPeripheralSuccess)success failure:(ConnectToPeripheralFailure)failure;
- (void)disconnectFromPeripheral:(CBPeripheral *)peripheral;

- (void)discoverServices:(NSArray *)services ForPeripheral:(CBPeripheral *)peripheral success:(DidDiscoverServicesSuccess)success failure:(DidDiscoverServicesFailure)failure;

- (void)discoverCharacteristics:(NSArray *)characteristics forService:(CBService *)service withPeripheral:(CBPeripheral *)peripheral success:(DidDiscoverCharacteristicsForServiceSuccess)success failure:(DidDiscoverCharacteristicsForServiceFailure)failure;

- (void)subscribeToNotificationsForCharacteristic:(CBCharacteristic *)characteristic didUpdateNotificationStateForCharacteristic:(DidUpdateNotificationStateForCharacteristic)updateNotificationBlock didUpdateValueForCharacteristic:(DidUpdateValueForCharacteristic)updateValueBlock failure:(CharacteristicSubscriptionFailure)failure;

- (void)stopScanning;
- (void)cleanup;

- (void)setStartUpSuccessBlock:(void (^)())startUpSuccessBlock;
- (void)setStartUpFailureBlock:(void (^)(CBCentralManagerState cbCentralManagerState))startUpFailureBlock;
- (void)setDidDiscoverPeripheralBlock:(void (^)(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI))didDiscoverPeripheralBlock;
- (void)setConnectToPeripheralSuccessBlock:(void (^)(CBPeripheral *peripheral))connectToPeripheralSuccessBlock;
- (void)setConnectToPeripheralFailureBlock:(void (^)(CBPeripheral *peripheral, NSError *error))connectToPeripheralFailureBlock;
- (void)setDidDiscoverServicesSuccessBlock:(void (^)(NSArray *discoveredServices))didDiscoverServicesSuccessBlock;
- (void)setDidDiscoverServicesFailureBlock:(void (^)(NSError *error))didDiscoverServicesFailureBlock;
- (void)setDidDiscoverCharacteristicsForServiceSuccessBlock:(void (^)(NSArray *discoveredCharacteristics))didDiscoverCharacteristicsForServiceSuccess;
- (void)setDidDiscoverCharacteristicsForServiceFailureBlock:(void (^)(NSError *error))didDiscoverCharacteristicsForServiceFailure;
- (void)setDidUpdateNotificationStateForCharacteristicBlock:(void (^)(BOOL isNotifying))didUpdateNotificationStateForCharacteristic;
- (void)setDidUpdateValueForCharacteristicBlock:(void (^)(NSData *updatedValue))didUpdateValueForCharacteristic;
- (void)setCharacteristicSubscriptionFailureBlock:(void (^)(NSError *error))characteristicSubscriptionFailure;
- (void)setDidDisconnectFromPeripheralBlock:(void (^)(CBPeripheral *peripheral))didDisconnectFromPeripheral;
- (void)setDidWriteValueForCharacteristicBlock:(void (^)(NSData *))didWriteValueForCharacteristic;

@end
