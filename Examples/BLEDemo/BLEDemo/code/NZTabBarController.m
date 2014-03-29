//
//  NZTabBarController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 28/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZTabBarController.h"
#import "NZBleConnectionViewController.h"
#import "NZGraphViewController.h"
#import "SensorData.h"

@interface NZTabBarController ()

@property (weak, nonatomic) NZBleConnectionViewController *bleVC;
@property (weak, nonatomic) NZGraphViewController * graphVC;
@property (weak, nonatomic) UINavigationController *menuNavigationController;
@property int bleVCIndex;
@property int graphVCIndex;
@property int menuNCIndex;

@end

@implementation NZTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[BLEDiscovery sharedInstance].peripheralDelegate = self;
    [BLEDiscovery sharedInstance].discoveryDelegate = self;
    [[BLEDiscovery sharedInstance] startScanningForSupportedUUIDs];
    self.accelerometerData = [[SensorData alloc] initWithValueHeadersX:'x' Y:'y' Z:'z'];
    
    NSLog(@"#controllers: %d", [self.viewControllers count]);
    for (int i = 0; i < [self.viewControllers count]; i++) {
        if ([[self.viewControllers objectAtIndex:i] isKindOfClass:[NZBleConnectionViewController class]]) {
            self.bleVC = (NZBleConnectionViewController *)[self.viewControllers objectAtIndex:i];
            self.bleVCIndex = i;
        } else if ([[self.viewControllers objectAtIndex:i] isKindOfClass:[NZGraphViewController class]]) {
            self.graphVC = (NZGraphViewController *)[self.viewControllers objectAtIndex:i];
            self.graphVCIndex = i;
       } else if ([[self.viewControllers objectAtIndex:i] isKindOfClass:[UINavigationController class]]) {
           self.menuNavigationController = (UINavigationController *)[self.viewControllers objectAtIndex:i];
           self.menuNCIndex = i;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Managing Tab Bar Item selection
#pragma mark -

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"seleted item: %d", self.selectedIndex);
    if ([item isEqual:[self.tabBar.items objectAtIndex:self.bleVCIndex] ]) {
        [[self.tabBar.items objectAtIndex:self.bleVCIndex] setBadgeValue:nil];
    }
}


#pragma mark -
#pragma mark BleServiceDataDelegate
#pragma mark -

-(void) didReceiveData:(uint8_t *)buffer lenght:(NSInteger)length{
    BOOL extractedData = [self.bleVC extractDataFromBuffer:buffer withLength:length to:self.accelerometerData];
    if (extractedData) {
        [self.graphVC updateWIthData:self.accelerometerData];
    }
}

#pragma mark -
#pragma mark BleDiscoveryDelegate
#pragma mark -

- (void) discoveryDidRefresh {
}

- (void) peripheralDiscovered:(CBPeripheral*) peripheral {
    //    [BLEDiscovery sharedInstance].supportedServiceUUIDs
    if([BLEDiscovery sharedInstance].connectedService == nil){
        [[BLEDiscovery sharedInstance] connectPeripheral:peripheral];
    }
}

- (void) discoveryStatePoweredOff {
}

#pragma mark -
#pragma mark BleServiceProtocol
#pragma mark -

-(void) bleServiceDidConnect:(BLEService *)service{
    service.delegate = self;
    service.dataDelegate = self;
    [self.bleVC updateConnectedLabel:([BLEDiscovery sharedInstance].connectedService != nil)];
    [[self.tabBar.items objectAtIndex:self.bleVCIndex] setBadgeValue:@":)"];
    //[self updateConnectedLabel];
}
-(void) bleServiceDidDisconnect:(BLEService *)service{
        [self.bleVC updateConnectedLabel:([BLEDiscovery sharedInstance].connectedService != nil)];
        [[self.tabBar.items objectAtIndex:self.bleVCIndex] setBadgeValue:@":("];
    //[self updateConnectedLabel];
}

-(void) bleServiceIsReady:(BLEService *)service{
    
}

-(void) bleServiceDidReset {
}

-(void) reportMessage:(NSString*) message{
}


@end
