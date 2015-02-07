//
//  CBPeripheral+SCPCoreBluetoothManager.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 21/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "CBPeripheral+SCPCoreBluetoothManager.h"
#import "SCPCoreBluetoothCentralManager.h"

static NSString *centralMangerKey = @"me.ste.centralManagerKey";

@implementation CBPeripheral (SCPCoreBluetoothManager)

- (void)connectSuccess:(ConnectToPeripheralSuccess)success failure:(ConnectToPeripheralFailure)failure
{
    [self.centralManager connectToPeripheral:self
                                     success:^(CBPeripheral *peripheral) {
                                         if(success)
                                         {
                                             success(peripheral);
                                         }
                                     }
                                     failure:^(CBPeripheral *peripheral, NSError *error) {
                                         if(failure)
                                         {
                                             failure(peripheral, error);
                                         }
                                     }];
}

- (void)discoverServices:(NSArray *)services success:(DidDiscoverServicesSuccess)success failure:(DidDiscoverServicesFailure)failure
{
    [self.centralManager discoverServices:services
                            ForPeripheral:self
                                  success:^(NSArray *discoveredServices) {
                                      if(success)
                                      {
                                          success(discoveredServices);
                                      }
                                  }
                                  failure:^(NSError *error) {
                                      if(failure)
                                      {
                                          failure(error);
                                      }
                                  }];
}

- (void)setDidWriteValueForCharacteristicBlock:(DidWriteValueForCharacteristic)didWriteValueForCharacteristicBlock
{
    [[self centralManager] setDidWriteValueForCharacteristicBlock:didWriteValueForCharacteristicBlock];
}

- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic
{
    [self writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)disconnect
{
    [self.centralManager disconnectFromPeripheral:self];
}

- (void)setCentralManager:(SCPCoreBluetoothCentralManager *)centralManager
{
    objc_setAssociatedObject(self, &centralMangerKey, centralManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SCPCoreBluetoothCentralManager *)centralManager
{
    return objc_getAssociatedObject(self, &centralMangerKey);
}

@end
