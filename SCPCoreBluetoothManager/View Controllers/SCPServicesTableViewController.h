//
//  SCPServicesTableViewController.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 03/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCPCoreBluetoothCentralManager;
@class CBPeripheral;

@interface SCPServicesTableViewController : UITableViewController

@property (nonatomic, strong) SCPCoreBluetoothCentralManager *coreBluetoothManger;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

@end
