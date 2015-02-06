//
//  SCPCoreBluetoothCentralManager.m
//  SCPCoreBluetoothCentralManager
//
//  Created by Ste Prescott on 02/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SCPCoreBluetoothCentralManager.h"

@interface SCPCoreBluetoothCentralManager ()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;

@end

@implementation SCPCoreBluetoothCentralManager

- (void)startUpSuccess:(StartUpSuccess)success failure:(StartUpFailure)failure
{
    //Custom bacground queue
	dispatch_queue_t backgroundQueue = dispatch_queue_create("me.ste.SCPCoreBluetoothCentralManager.queue", NULL);
	
	self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:backgroundQueue];
	self.startUpSuccessBlock = success;
	self.startUpFailureBlock = failure;
}

//This determins the state of the central manage and deals with its states
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	switch ([central state])
	{
        case CBCentralManagerStatePoweredOn:
        {
			self.isReady = YES;
			
			if(_startUpSuccessBlock)
			{
            	_startUpSuccessBlock();
			}
			break;
        }
            
        default:
        {
			self.isReady = NO;
			
			if(_startUpFailureBlock)
			{
            	_startUpFailureBlock([central state]);
			}
            break;
        }
    }
}

- (void)scanForPeripheralsWithServices:(NSArray *)services allowDuplicates:(BOOL)allowDuplicates didDiscoverPeripheral:(DidDiscoverPeripheral)didDiscoverPeripheral
{
    self.didDiscoverPeripheralBlock = didDiscoverPeripheral;
	
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:allowDuplicates]};
    
    [_centralManager scanForPeripheralsWithServices:services options:options];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //Set the central manager property of the CBPeripheral. This is to allow the category methods to use the same SCPCoreBluetoothCentralManager
    [peripheral setCentralManager:self];
    
	if(_didDiscoverPeripheralBlock)
	{
		_didDiscoverPeripheralBlock(peripheral, advertisementData, RSSI);
	}
	else
	{
		NSLog(@"Discovered Peripheral but didDiscoverPeripheralBlock not set.");
	}
}

//We've connected to the peripheral, now we need to discover the services and characteristics
- (void)connectToPeripheral:(CBPeripheral *)peripheral success:(ConnectToPeripheralSuccess)success failure:(ConnectToPeripheralFailure)failure
{
    //Check that it isn't already connected
    if(![_connectedPeripheral isEqual:peripheral])
	{
        self.connectedPeripheral = (CBPeripheral *)peripheral;
        self.connectToPeripheralSuccessBlock = success;
		self.connectToPeripheralFailureBlock = failure;
		
        //Try and connect
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	CBPeripheral *connectedPeripheral = (CBPeripheral *)peripheral;
	[connectedPeripheral setDelegate:self];
	
	if(_connectToPeripheralSuccessBlock)
	{
		_connectToPeripheralSuccessBlock(connectedPeripheral);
	}
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	[self cleanup];
	
	CBPeripheral *failedPeripheral = (CBPeripheral *)peripheral;
	
	if(_connectToPeripheralFailureBlock)
	{
		_connectToPeripheralFailureBlock(failedPeripheral, error);
	}
}

- (void)disconnectFromPeripheral:(CBPeripheral *)peripheral
{
    [_centralManager cancelPeripheralConnection:peripheral];
    [self cleanup];
}

- (void)discoverServices:(NSArray *)services ForPeripheral:(CBPeripheral *)peripheral success:(DidDiscoverServicesSuccess)success failure:(DidDiscoverServicesFailure)failure
{
	self.didDiscoverServicesSuccessBlock = success;
	self.didDiscoverServicesFailureBlock = failure;
	
    //Search only for services that match that in the array
    [peripheral discoverServices:services];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	//Deal with errors, if any
    if(error)
	{
		if(_didDiscoverServicesFailureBlock)
		{
			_didDiscoverServicesFailureBlock(error);
		}
		
		[self cleanup];
        
        return;
    }
	
	NSMutableArray *services = [@[] mutableCopy];
	
	[[peripheral services] enumerateObjectsUsingBlock:^(CBService *service, NSUInteger idx, BOOL *stop) {
		[services addObject:(CBService *)service];
	}];
	
    if(_didDiscoverServicesSuccessBlock)
	{
		_didDiscoverServicesSuccessBlock(services);
	}
}

- (void)discoverCharacteristics:(NSArray *)characteristics forService:(CBService *)service withPeripheral:(CBPeripheral *)peripheral success:(DidDiscoverCharacteristicsForServiceSuccess)success failure:(DidDiscoverCharacteristicsForServiceFailure)failure
{
	self.didDiscoverCharacteristicsForServiceSuccessBlock = success;
	self.didDiscoverCharacteristicsForServiceFailureBlock = failure;
	
    [peripheral discoverCharacteristics:characteristics forService:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error)
	{
		if(_didDiscoverCharacteristicsForServiceFailureBlock)
		{
			_didDiscoverCharacteristicsForServiceFailureBlock(error);
		}
		
        [self cleanup];
        return;
    }
    
	NSMutableArray *characteristics = [@[] mutableCopy];
	
	[[service characteristics] enumerateObjectsUsingBlock:^(CBCharacteristic *characteristic, NSUInteger idx, BOOL *stop) {
		[characteristics addObject:(CBCharacteristic *)characteristic];
	}];
	
	if(_didDiscoverCharacteristicsForServiceSuccessBlock)
	{
		_didDiscoverCharacteristicsForServiceSuccessBlock(characteristics);
	}
}

- (void)subscribeToNotificationsForCharacteristic:(CBCharacteristic *)characteristic didUpdateNotificationStateForCharacteristic:(DidUpdateNotificationStateForCharacteristic)updateNotificationBlock didUpdateValueForCharacteristic:(DidUpdateValueForCharacteristic)updateValueBlock failure:(CharacteristicSubscriptionFailure)failure
{
	self.didUpdateNotificationStateForCharacteristicBlock = updateNotificationBlock;
	self.didUpdateValueForCharacteristicBlock = updateValueBlock;
	self.characteristicSubscriptionFailureBlock = failure;
	
	[[[characteristic service] peripheral] setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	//Deal with errors (if any)
    if(error)
	{
		if(_characteristicSubscriptionFailureBlock)
		{
			_characteristicSubscriptionFailureBlock(error);
		}
		return;
    }
	
	if(_didUpdateNotificationStateForCharacteristicBlock)
	{
		_didUpdateNotificationStateForCharacteristicBlock([characteristic isNotifying]);
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
	{
		if(_characteristicSubscriptionFailureBlock)
		{
			_characteristicSubscriptionFailureBlock(error);
		}
        return;
    }
    
	if(_didUpdateValueForCharacteristicBlock)
	{
		_didUpdateValueForCharacteristicBlock([characteristic value]);
	}
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.connectedPeripheral = nil;
	
	if(_didDisconnectFromPeripheralBlock)
	{
		_didDisconnectFromPeripheralBlock((CBPeripheral *)peripheral);
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error)
    {
        if(_characteristicSubscriptionFailureBlock)
        {
            _characteristicSubscriptionFailureBlock(error);
        }
        return;
    }

    if (_didWriteValueForCharacteristicBlock) {
        _didWriteValueForCharacteristicBlock([characteristic value]);
    }
}

- (void)stopScanning
{
	[_centralManager stopScan];
}

//This is called when things either go wrong, or we are done with the connection. This cancels any subscriptions if there are any, or straight disconnects if not.
- (void)cleanup
{
	if(_connectedPeripheral)
	{
		//iOS 7 check
		if([_connectedPeripheral respondsToSelector:@selector(identifier)] && ![_connectedPeripheral identifier])
		{
			self.connectedPeripheral = nil;
			NSLog(@"Peripheral Disconnect");
			return;
		}
		//iOS 6 fallback
		else if([_connectedPeripheral respondsToSelector:@selector(isSelected)] && ![_connectedPeripheral isConnected])
		{
			self.connectedPeripheral = nil;
			NSLog(@"Peripheral Disconnect");
			return;
		}
		
		//See if we are subscribed to a characteristic on the peripheral
		if([_connectedPeripheral services])
		{
			//Loop through all service
			[[_connectedPeripheral services] enumerateObjectsUsingBlock:^(CBService *service, NSUInteger idx, BOOL *stop) {
				
				//Check it is valid
				if([service characteristics])
				{
					//Loop through all the services characteristics
					[[service characteristics] enumerateObjectsUsingBlock:^(CBCharacteristic *characteristic, NSUInteger idx, BOOL *stop) {
						
						//And is the one we are listening to
						if([characteristic isNotifying])
						{
							//Unsubscribe
							[_connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
							
							//And then we're done.
							self.connectedPeripheral = nil;
							NSLog(@"Peripheral Disconnect");
							return;
						}
					}];
				}
				
			}];
		}
		
		//If it jumps to here, we're connected, but we're not subscribed, so we just disconnect
		[_centralManager cancelPeripheralConnection:_connectedPeripheral];
		self.connectedPeripheral = nil;
		NSLog(@"Peripheral Disconnect");
	}
}

@end
