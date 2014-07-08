//
//  SCPServicesTableViewController.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 03/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SCPServicesTableViewController.h"
#import "SCPCharacteristicsTableViewController.h"

#import "SCPCoreBluetoothCentralManager.h"

static NSString *cellIdentifier = @"cell";

@interface SCPServicesTableViewController ()

@property (nonatomic, strong) CBService *selectedService;

@end

@implementation SCPServicesTableViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableviewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_connectedPeripheral services] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
	CBService *service = [_connectedPeripheral services][indexPath.row];
	
	[[cell textLabel] setText:[NSString stringWithFormat:@"%@", [service UUID]]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedService = [_connectedPeripheral services][indexPath.row];
	
    if(_selectedService)
    {
        [SVProgressHUD showWithStatus:@"Searching for characteristics"];
        //Discover the characteristics for the selected service
        [_selectedService discoverCharacteristics:nil //If an array of CBUUIDs is given it will only look for the services with that CBUUID
                                          success:^(NSArray *discoveredCharacteristics) {
                                              NSLog(@"Characteristics found: %@", discoveredCharacteristics);
                                              
                                              if([discoveredCharacteristics count] > 0)
                                              {
                                                  dispatch_sync(dispatch_get_main_queue(), ^{
                                                      [SVProgressHUD showSuccessWithStatus:@"Characteristics found"];
                                                      [self performSegueWithIdentifier:@"showCharacteristics" sender:self];
                                                  });
                                              }
                                              else
                                              {
                                                  dispatch_sync(dispatch_get_main_queue(), ^{
                                                      [SVProgressHUD showSuccessWithStatus:@"No characteristics found"];
                                                  });
                                              }
                                              
                                          }
                                          failure:^(NSError *error) {
                                              NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
                                              dispatch_sync(dispatch_get_main_queue(), ^{
                                                  [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Could not discover\n characteristics for service\n %@", [_connectedPeripheral name]]];
                                              });
                                          }];
        
        //Again you can perform the same actions above without using the category methods like below
//        [_coreBluetoothManger discoverCharacteristics:nil
//                                           forService:_selectedService
//                                       withPeripheral:_connectedPeripheral
//                                              success:^(NSArray *discoveredCharacteristics) {
//                                                  NSLog(@"Characteristics found: %@", discoveredCharacteristics);
//                                                  
//                                                  if([discoveredCharacteristics count] > 0)
//                                                  {
//                                                      dispatch_sync(dispatch_get_main_queue(), ^{
//                                                          [SVProgressHUD showSuccessWithStatus:@"Characteristics found"];
//                                                          [self performSegueWithIdentifier:@"showCharacteristics" sender:self];
//                                                      });
//                                                  }
//                                                  else
//                                                  {
//                                                      dispatch_sync(dispatch_get_main_queue(), ^{
//                                                          [SVProgressHUD showSuccessWithStatus:@"No characteristics found"];
//                                                      });
//                                                  }
//                                                  
//                                              } failure:^(NSError *error) {
//                                                  NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
//                                                  dispatch_sync(dispatch_get_main_queue(), ^{
//                                                      [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Could not discover\n characteristics for service\n %@", [_connectedPeripheral name]]];
//                                                  });
//                                              }];
    }
    else
    {
        NSLog(@"No selected service");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSString *identifier = [segue identifier];
	
	if([identifier isEqualToString:@"showCharacteristics"])
	{
		SCPCharacteristicsTableViewController *characteristicsViewController = (SCPCharacteristicsTableViewController *)[segue destinationViewController];
		[characteristicsViewController setCoreBluetoothManger:_coreBluetoothManger];
		[characteristicsViewController setSelectedService:_selectedService];
	}
}

@end
