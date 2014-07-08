# SCPCoreBluetoothManager [![Version](https://img.shields.io/cocoapods/v/SCPCoreBluetoothManager.svg?style=flat)](http://cocoadocs.org/docsets/SCPCoreBluetoothManager)

Block based wrapper around the Core Bluetooth framework. This is only v1.0 and only includes the Central Manager part, the Peripheral Manager part is still in development.

##Required frameworks
Core Bluetooth

## Installation

### Pod
SCPCoreBluetoothManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod 'SCPCoreBluetoothManager'

### Submodule
Note the demo uses cocoapods to include the SVProgressHUD dependency so you need to run the `pod install` command via terminal.
1. Add this repo as a submodule or download it as a .zip
2. Within the demo project you will see a folder named **SCPCoreBluetoothManager**. This folder contains all the required files.
3. Include this folder into your project.
4. When you wish to use the framework, import the framework into your implementation with `#import "SCPCoreBluetoothManger.h"`

##The basics
A basic understanding of how transmission between two Bluetooth Low Energy (BLE) devices. One of the devices should act as a **central manager** and another being the **peripheral**.

The central manager handles the listening of peripherals and reads data from them, the peripheral manager deals with the broadcasting of services, characteristics and their values.

The three steps to retrieving data is

1. Central manager searches for any peripherals (devices) that are broadcasting a service.
2. The central manager connects to the peripheral and then requests its services.
3. Once a service is chosen to be connected to, it will then ask for the services characteristics.
4. You then request to read the value of the characteristic. A characteristic can be one of a set of types. eg Read, Write, Notify. If it is a read value you will be given its value. If it is a Notify you will subscribe to it and later receive its value.

It is worth noting that a peripheral can have one or many services. A service can have one or many characteristic.

This framework is split into two parts, SCPCoreBluetoothCentralManager and SCPCoreBluetoothPeripheralManager. SCPCoreBluetoothPeripheralManager is still in development.

**PLEASE NOTE**
All calls happen in a background thread and any UI updates must happen on the main thread. To do this within the blocks simple enclose your UI code within the code below.
```
dispatch_sync(dispatch_get_main_queue(), ^{
        //If you need to do any UI updates it must be performed on the main thread
        //Add UI code here such as reloading table view data.
    });
```

##SCPCoreBluetoothCentralManager
This 1st part focuses on the reading of peripherals, services and characteristics.

###Usage
=========
You first need to start up the central manager.
Add a property of SCPCoreBluetoothCentralManager to your class and init up a new instance. `self.centralManger = [[SCPCoreBluetoothCentralManager alloc] init];`

You now need to start up the central manager. Call the instance method `- (void)startUpSuccess:(StartUpSuccess)success failure:(StartUpFailure)failure;`
This takes two blocks. The first is called if the central manager is started successfully, the second if there was a problem. 
The failure block will return a CBCentralManagerState that can be used to determine the problem.

######Example
```
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
            message = @"Unauthorised";
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

    dispatch_sync(dispatch_get_main_queue(), ^{
        //Add UI code here such as reloading table view data.
    });
    
    NSLog(@"Error %d", message);
}];
```

Once the central manager is started successfully then you can now search for peripherals using this method `- (void)scanForPeripheralsWithServices:(NSArray *)services allowDuplicates:(BOOL)allowDuplicates didDiscoverPeripheral:(DidDiscoverPeripheral)didDiscoverPeripheral;`.
If an array of 'CBUUID's is given it will only return peripherals that are broadcasting a service with one of the 'CBUUID's. If 'nil' is passed then it will search for all of them.
The allowDuplicates BOOL specifies whether the scan should run without duplicate filtering.
Finally a block that will be called when a new peripheral is found. This will return the peripheral, its advertisement data and its RSSI.
RSSI is the current received signal strength indicator (RSSI) of the peripheral, in decibels.

######Example
```
//Check that the central manager is ready to scan
if([_centralManger isReady])
{
    //Tell the central manager to start scanning
    [_centralManger scanForPeripheralsWithServices:nil //If an array of CBUUIDs is given it will only look for the peripherals with that CBUUID
                                         allowDuplicates:NO
                                   didDiscoverPeripheral:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
                                       //A peripheral has been found
                                       NSLog(@"Discovered Peripheral '%@' with RSSI of %@", [peripheral name], RSSI);
                                   }];
    NSLog(@"Scanning started");
}
else
{
    NSLog(@"Central manager not ready to scan");
}
```

Now you have found the peripherals you are interested in you should now attempt to connect to it. To do so call `- (void)connectSuccess:(ConnectToPeripheralSuccess)success failure:(ConnectToPeripheralFailure)failure;` 

The fisrt block will be called upon successful connection to the peripheral and will return the peripheral that it connected to, the failure block will be called if there was ever a problem connecting to the peripheral along with the error.

######Example
```
[peripheral connectSuccess:^(CBPeripheral *peripheral) {
    NSLog(@"Connected to peripheral '%@'", [peripheral name]);
}
                   failure:^(CBPeripheral *peripheral, NSError *error) {
                       NSLog(@"Failed connecting to Peripheral '%@'. Error : %@", [peripheral name], [error localizedDescription]);
                   }];
```

You should now be connected to the peripheral and be able to discover all the services for the connected peripheral. Call `- (void)discoverServices:(NSArray *)services success:(DidDiscoverServicesSuccess)success failure:(DidDiscoverServicesFailure)failure;`

Again just like the `scanForPeripheralsWithServices` method it takes an array of `CBUUID`s. If given then it will only discover services with the given `CBUUID`s. If this is `nil` it will search for all the services for that peripheral.

The first block will be called upon discovery of all the services for the connected peripheral. If an array was provided for the 'discoverServices' parameter then this will be a filtered array only showing the services with the CBUUIDs given in the array.

The failure block will be called with an error if there was a problem.

######Example
```
//Discover the services for the newly connected peripheral
[selectedPeripheral discoverServices:nil //If an array of CBUUIDs is given it will only attempt to discover services with these CBUUIDs
                             success:^(NSArray *discoveredServices) {
                                 NSLog(@"Services found %@", discoveredServices);
                             }
                             failure:^(NSError *error) {
                                 NSLog(@"Error discovering services for peripheral '%@'", [peripheral name]);
                             }];
```

Each service has one or several characteristics, you now need to discover them. To do this call the `- (void)discoverCharacteristics:(NSArray *)characteristics success:(DidDiscoverCharacteristicsForServiceSuccess)success failure:(DidDiscoverCharacteristicsForServiceFailure)failure;` method on a CBService.

Just like other discovering methods it takes an array of `CBUUID`s. If given then it will only discover characteristics with the given `CBUUID`s. If this is `nil` it will search for all the characteristics for that service.

The second parameter is a block that will be called when the characteristics are found. What is returned in this block is an array of CBCharacteristics.

The last parameter is the failure block, for whatever reason an NSError is returned to the block.

######Example
```
[service discoverCharacteristics:nil //If an array of CBUUIDs is given it will only look for the services with that CBUUID
                         success:^(NSArray *discoveredCharacteristics) {
                             NSLog(@"Characteristics found: %@", discoveredCharacteristics);
                         }
                         failure:^(NSError *error) {
                             NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
                         }];
```

Now you have found the characteristic you are interested in you can read it's value by first subscribing to all changes to the chosen characteristic. To do this set the didUpdateValueBlock of a CBCharacteristic

This block will return NSData that can then be converted into a HEX string using the category method `hexString`.
Then this HEX string can be converted to an ASCII representation using the `ASCIIStringFromHexString` category method.

######Example
```
[characteristic setDidUpdateValueBlock:^(NSData *updatedValue) {
    NSString *hexString = [updatedValue hexString];
    NSLog(@"Hex string value : %@", hexString);
    
    NSString *ASCIIString = [hexString ASCIIStringFromHexString];
    NSLog(@"String from Hex value : %@", ASCIIString);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        //Perform any UI changes on the main thread
    });
}];
```

Once this block is set you need to request the value from the characteristic using the `readValue` method.

######Example
```
[characteristic readValue];
``` 

The updated value will be returned to the didUpdateValueBlock and can be dealt with from there.

That is it, you should now be able to discover all that is needed and read values. Testing for subscription services are ongoing as well as write characteristics as I am still building the Peripheral Manager part.

##Contact

twitter : [@ste_prescott](https://twitter.com/ste_prescott "Twitter account")

##License
This project made available under the MIT License.

Copyright (C) 2014 Ste Prescott

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
