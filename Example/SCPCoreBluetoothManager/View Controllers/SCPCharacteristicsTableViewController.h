//
//  SCPCharacteristicsTableViewController.h
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 04/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCPCoreBluetoothCentralManager;
@class CBService;

@interface SCPCharacteristicsTableViewController : UITableViewController

@property (nonatomic, strong) SCPCoreBluetoothCentralManager *coreBluetoothManger;
@property (nonatomic, strong) CBService *selectedService;

@end
