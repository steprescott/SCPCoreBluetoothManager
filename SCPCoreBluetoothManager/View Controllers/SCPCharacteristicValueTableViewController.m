//
//  SCPCharacteristicValueTableViewController.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 10/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SCPCharacteristicValueTableViewController.h"

#import "SCPCoreBluetoothCentralManager.h"

#import "CBCharacteristic+SCPCoreBluetoothManager.h"
#import "NSData+SCPCoreBluetoothManager.h"
#import "NSString+SCPCoreBluetoothManager.h"

typedef NS_ENUM(NSUInteger, TableViewSection) {
    TableViewSectionHexString = 0,
    TableViewSectionASCIIString,
};

@interface SCPCharacteristicValueTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *hexStringTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *asciiStringTableViewCell;

@property (nonatomic, strong) NSString *hexString;
@property (nonatomic, strong) NSString *asciiString;

@end

@implementation SCPCharacteristicValueTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
	
    if (self)
	{
		
    }
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	__weak SCPCharacteristicValueTableViewController *weakSelf = self;
	
    if(_characteristic)
    {
        [SVProgressHUD showWithStatus:@"Reading characteristic value"];
        
        //Set the didUpdateValueBlock to get the new values as they are broadcasted
        [_characteristic setDidUpdateValueBlock:^(NSData *updatedValue) {
            
            //As the values come bac as a data we need to convert it to a Hex string
            weakSelf.hexString = [updatedValue hexString];
            
            //Now we need to convert this Hex string into an ASCII string
            weakSelf.asciiString = [NSString stringFromHexString:[[weakSelf.characteristic value] hexString]];
            
            NSLog(@"Hex string value : %@", weakSelf.hexString);
            NSLog(@"String from Hex value : %@", weakSelf.asciiString);
            
            //Update the UI with these values
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[weakSelf.hexStringTableViewCell textLabel] setText:weakSelf.hexString];
                [[weakSelf.asciiStringTableViewCell textLabel] setText:weakSelf.asciiString];
                [SVProgressHUD showSuccessWithStatus:@"Characteristic value updated"];
            });
        }];
        
        //Again this can be done also through the central manager than by the category methods
//        [_coreBluetoothManger setDidUpdateValueForCharacteristicBlock:^(NSData *updatedValue) {
//            weakSelf.hexString = [updatedValue hexString];
//            weakSelf.asciiString = [NSString stringFromHexString:[[weakSelf.characteristic value] hexString]];
//            
//            NSLog(@"Hex string value : %@", weakSelf.hexString);
//            NSLog(@"String from Hex value : %@", weakSelf.asciiString);
//            
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [[weakSelf.hexStringTableViewCell textLabel] setText:weakSelf.hexString];
//                [[weakSelf.asciiStringTableViewCell textLabel] setText:weakSelf.asciiString];
//                [SVProgressHUD showSuccessWithStatus:@"Characteristic value updated"];
//            });
//        }];
        
        //Ask to get the value for the characteristic
        [_characteristic readValue];
        
        //Again the reading of a value can be done via the central manger
//        [[[_characteristic service] peripheral] readValueForCharacteristic:_characteristic];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
