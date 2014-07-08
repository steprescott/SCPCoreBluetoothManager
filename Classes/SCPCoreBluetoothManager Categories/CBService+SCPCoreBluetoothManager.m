//
//  CBService+SCPCoreBluetoothManager.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 21/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "CBService+SCPCoreBluetoothManager.h"

#import "SCPCoreBluetoothCentralManager.h"
#import "SCPCoreBluetoothManagerCategories.h"

@implementation CBService (SCPCoreBluetoothManager)

- (void)discoverCharacteristics:(NSArray *)characteristics success:(DidDiscoverCharacteristicsForServiceSuccess)success failure:(DidDiscoverCharacteristicsForServiceFailure)failure
{
    [[[self peripheral] centralManager] discoverCharacteristics:characteristics
                                                     forService:self
                                                 withPeripheral:[self peripheral]
                                                        success:^(NSArray *discoveredCharacteristics) {
                                                            if(success)
                                                            {
                                                                success(discoveredCharacteristics);
                                                            }
                                                        }
                                                        failure:^(NSError *error) {
                                                            if(failure)
                                                            {
                                                                failure(error);
                                                            }
                                                        }];
}

@end
