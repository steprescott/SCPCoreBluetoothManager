//
//  SCPCharacteristicsTableViewController.m
//  SCPCoreBluetoothManager
//
//  Created by Ste Prescott on 04/05/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "SCPCharacteristicsTableViewController.h"
#import "SCPCharacteristicValueTableViewController.h"

#import "SCPCoreBluetoothCentralManager.h"

@interface SCPCharacteristicsTableViewController ()

@property (nonatomic, strong) CBCharacteristic *selectedCharacteristic;

@end

static NSString *cellIdentifier = @"cell";

@implementation SCPCharacteristicsTableViewController

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_selectedService characteristics] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
	CBCharacteristic *characteristic = [_selectedService characteristics][indexPath.row];
    
	[[cell textLabel] setText:[NSString stringWithFormat:@"%@", [characteristic UUID]]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedCharacteristic = [_selectedService characteristics][indexPath.row];

	[self performSegueWithIdentifier:@"showValue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSString *identifier = [segue identifier];
	
	if([identifier isEqualToString:@"showValue"])
	{
		SCPCharacteristicValueTableViewController *characteristicValueViewController = (SCPCharacteristicValueTableViewController *)[segue destinationViewController];
		[characteristicValueViewController setCoreBluetoothManger:_coreBluetoothManger];
		[characteristicValueViewController setCharacteristic:_selectedCharacteristic];
	}
}

@end
