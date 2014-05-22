//
//  SCPTableViewController.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 03/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SCPPeripheralsTableViewController.h"
#import "SCPServicesTableViewController.h"

#import "SCPCoreBluetoothCentralManager.h"

static NSString *cellIdentifier = @"cell";

@interface SCPPeripheralsTableViewController ()

@property (nonatomic, strong) SCPCoreBluetoothCentralManager *centralManger;
@property (nonatomic, strong) NSMutableArray *discoveredPeripherals;
@property (nonatomic, strong) NSMutableArray *peripheralsRSSI;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

@end

@implementation SCPPeripheralsTableViewController

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
	
    //Weak self to avoid retain cycle when using self inside a block
	__weak SCPPeripheralsTableViewController *weakSelf = self;
	
    //Init the properties
	self.centralManger = [[SCPCoreBluetoothCentralManager alloc] init];
	self.discoveredPeripherals = [@[] mutableCopy];
	self.peripheralsRSSI = [@[] mutableCopy];
	
    //Start up the central manager
	[_centralManger startUpSuccess:^{
		NSLog(@"Core bluetooth manager successfully started.");
		
        //Once the central manager is successfully started, start scanning for peripherals
		[weakSelf scanForPeripherals];
        
	} failure:^(CBCentralManagerState CBCentralManagerState) {
        
        //Handel the error.
        
        NSString *message;
        
        switch (CBCentralManagerState) {
            case CBCentralManagerStateUnknown:
            {
                message = @"Unknown state";
                break;
            }
            case CBCentralManagerStateResetting:
            {
                message = @"Central manager is resetting";
                break;
            }
            case CBCentralManagerStateUnsupported:
            {
                message = @"Your device is not supported";
                NSLog(@"Please note it will not work on a simulator");
                break;
            }
            case CBCentralManagerStateUnauthorized:
            {
                message = @"Unauthorized";
                break;
            }
            case CBCentralManagerStatePoweredOff:
            {
                message = @"Bluetooth is switched off";
                break;
            }
            default:
            {
                //Empty default to remove switch warning
                break;
            }
        }
        
        //Remove any previously found peripheral
        [weakSelf.discoveredPeripherals removeAllObjects];
        [weakSelf.peripheralsRSSI removeAllObjects];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
			[SVProgressHUD showErrorWithStatus:message];
            [weakSelf.tableView reloadData];
		});
        
		NSLog(@"Error %d", CBCentralManagerState);
	}];
    
    //Set the did disconnect block to handel if the peripheral disconnects anytime during the app
	[_centralManger setDidDisconnectFromPeripheralBlock:^(CBPeripheral *peripheral) {
		NSLog(@"Did disconnect");
        
        //Remove any previously found peripheral
        [weakSelf.discoveredPeripherals removeAllObjects];
        [weakSelf.peripheralsRSSI removeAllObjects];
        
        //Call it on the main thread to pop to root view
		dispatch_sync(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"Disconnected from\nperipheral"];
			[[weakSelf navigationController] popToRootViewControllerAnimated:YES];
            [weakSelf.tableView reloadData];
            [weakSelf performSelector:@selector(scanForPeripherals) withObject:nil afterDelay:1.0];
		});
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    //Clean up ensures that we are disconnected and unsubsribed
	[_centralManger cleanup];
}

- (void)scanForPeripherals
{
    [SVProgressHUD showWithStatus:@"Searching for peripherals"];
	__weak SCPPeripheralsTableViewController *weakSelf = self;
	
    //Remove any previously found peripheral
	[_discoveredPeripherals removeAllObjects];
	[_peripheralsRSSI removeAllObjects];
	[self.tableView reloadData];
	
    //Check that the central manager is ready to scan
	if([_centralManger isReady])
	{
        //Tell the central manager to start scanning
		[_centralManger scanForPeripheralsWithServices:nil //If an array of CBUUIDs is given it will only look for the peripherals with that CBUUID
											 allowDuplicates:NO
									   didDiscoverPeripheral:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
                                           //A peripheral has been found
										   NSLog(@"Discovered Peripheral '%@' with RSSI of %@", [peripheral name], RSSI);
										   
                                           //To ensure we don't have duplicates
										   if(![weakSelf.discoveredPeripherals containsObject:peripheral])
										   {
                                               //Add it to the discoveredPeripherals array and update the UI on the main thread
											   [weakSelf.discoveredPeripherals addObject:peripheral];
											   [weakSelf.peripheralsRSSI addObject:RSSI];
											   dispatch_sync(dispatch_get_main_queue(), ^{
												   [weakSelf.tableView reloadData];
                                                   [SVProgressHUD dismiss];
											   });
										   }
									   }];
		NSLog(@"Scanning started");
	}
    else
    {
        NSLog(@"Central manager not ready to scan");
    }
}

#pragma mark - UITableviewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_discoveredPeripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
	CBPeripheral *peripheral = _discoveredPeripherals[indexPath.row];
	
	NSString *peripheralName = [peripheral name] ? [peripheral name] : @"Unidentified";
	NSNumber *peripheralRSSI = _peripheralsRSSI[indexPath.row];
	
	[[cell textLabel] setText:peripheralName];
	[[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", peripheralRSSI]];

    return cell;
}

#pragma mark - UITableviewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_centralManger isReady])
    {
        __weak SCPPeripheralsTableViewController *weakSelf = self;
        
        CBPeripheral *selectedPeripheral = _discoveredPeripherals[indexPath.row];
        
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Connecting to\n%@", [selectedPeripheral name]]];
        
        //Check we have a peripheral selected
        if(selectedPeripheral)
        {
            //Attempt to connect to the peripheral
            [selectedPeripheral connectSuccess:^(CBPeripheral *peripheral) {
                //Successfuly connected
                NSLog(@"Connected to peripheral '%@'", [peripheral name]);
                weakSelf.connectedPeripheral = peripheral;
                
                //Stop the scanning as we don't need to look for anymore
                [_centralManger stopScanning];
                NSLog(@"Scanning stopped");

                dispatch_sync(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Searching for\nservices for\n%@", [peripheral name]]];
                });
                
                //Discover the services for the newly connected peripheral
                [peripheral discoverServices:nil
                                     success:^(NSArray *discoveredServices) {
                                         NSLog(@"Services found %@", discoveredServices);
                                         
                                         if([discoveredServices count] > 0)
                                         {
                                             //Move to show the services
                                             dispatch_sync(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD showSuccessWithStatus:@"Services found"];
                                                 [weakSelf performSegueWithIdentifier:@"showServices" sender:weakSelf];
                                             });
                                         }
                                         else
                                         {
                                             dispatch_sync(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD showErrorWithStatus:@"No services found"];
                                                 [peripheral performSelector:@selector(disconnect) withObject:nil afterDelay:1.0];
                                             });
                                         }
                                     }
                                     failure:^(NSError *error) {
                                         NSLog(@"Error discovering services for peripheral '%@'", [peripheral name]);
                                     }];
                
            } failure:^(CBPeripheral *peripheral, NSError *error) {
                NSLog(@"Failed connecting to Peripheral '%@'. Error : %@", [peripheral name], [error localizedDescription]);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Failed to connect to\n%@", [peripheral name]]];
                });
            }];
            
            //Below is a second way of perfoming the same taks above but using the central manager rather than the cateogry methods
//            [_centralManger connectToPeripheral:selectedPeripheral
//                                        success:^(CBPeripheral *peripheral) {
//                                            NSLog(@"Connected to peripheral '%@'", [peripheral name]);
//                                            weakSelf.connectedPeripheral = peripheral;
//                                            
//                                            [_centralManger stopScanning];
//                                            NSLog(@"Scanning stopped");
//                                            
//                                            dispatch_sync(dispatch_get_main_queue(), ^{
//                                                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Searching for services for\n%@", [peripheral name]]];
//                                            });
//                                            
//                                            [weakSelf.centralManger discoverServices:nil
//                                                                       ForPeripheral:peripheral
//                                                                             success:^(NSArray *discoveredServices) {
//                                                                                 NSLog(@"Services found %@", discoveredServices);
//                                                                                 
//                                                                                 if([discoveredServices count] > 0)
//                                                                                 {
//                                                                                     //Move to show the services
//                                                                                     dispatch_sync(dispatch_get_main_queue(), ^{
//                                                                                         [SVProgressHUD showSuccessWithStatus:@"Services found"];
//                                                                                         [weakSelf performSegueWithIdentifier:@"showServices" sender:weakSelf];
//                                                                                     });
//                                                                                 }
//                                                                                 else
//                                                                                 {
//                                                                                     dispatch_sync(dispatch_get_main_queue(), ^{
//                                                                                         [SVProgressHUD showErrorWithStatus:@"No services found"];
//                                                                                         [peripheral performSelector:@selector(disconnect) withObject:nil afterDelay:1.0];
//                                                                                     });
//                                                                                 }
//                                                                             }
//                                                                             failure:^(NSError *error) {
//                                                                                 NSLog(@"Error discovering services for peripheral '%@'", [peripheral name]);
//                                                                             }];
//                                        }
//                                        failure:^(CBPeripheral *peripheral, NSError *error) {
//                                            NSLog(@"Failed connecting to Peripheral '%@'. Error : %@", [peripheral name], [error localizedDescription]);
//                                            dispatch_sync(dispatch_get_main_queue(), ^{
//                                                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Failed to connect to\n%@", [peripheral name]]];
//                                            });
//                                        }];
        }
        else
        {
            NSLog(@"No selected peripheral");
            [SVProgressHUD showErrorWithStatus:@"No selected peripheral"];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSString *identifier = [segue identifier];
	
	if([identifier isEqualToString:@"showServices"])
	{
		SCPServicesTableViewController *servicesViewController = (SCPServicesTableViewController *)[segue destinationViewController];
		[servicesViewController setCoreBluetoothManger:_centralManger];
		[servicesViewController setConnectedPeripheral:_connectedPeripheral];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
