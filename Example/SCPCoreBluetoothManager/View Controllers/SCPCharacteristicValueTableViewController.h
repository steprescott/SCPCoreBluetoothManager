//
//  SCPCharacteristicValueTableViewController.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 10/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCPCoreBluetoothCentralManager;
@class CBCharacteristic;

@interface SCPCharacteristicValueTableViewController : UITableViewController

@property (nonatomic, strong) SCPCoreBluetoothCentralManager *coreBluetoothManger;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@end
