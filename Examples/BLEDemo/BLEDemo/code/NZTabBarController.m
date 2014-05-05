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
#import "NZMenuViewController.h"
#import "NZNotificationConstants.h"
#import "NZSensorDataHeaders.h"

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
    self.accelerometerData = [[SensorData alloc] initWithValueHeadersX:kLinearAccelerationX Y:kLinearAccelerationY Z:kLinearAccelerationZ andOffsetsX:kLinearAccelerationXOffset Y:kLinearAccelerationYOffset Z:kLinearAccelerationZOffset andName:@"Linear Acceleration"];
    
    NSLog(@"#controllers: %luu",(unsigned long)([self.viewControllers count]));
    for (int i = 0; i < [self.viewControllers count]; i++) {
        if ([[self.viewControllers objectAtIndex:i] isKindOfClass:[NZBleConnectionViewController class]]) {
            self.bleVC = (NZBleConnectionViewController *)[self.viewControllers objectAtIndex:i];
            self.bleVCIndex = i;
        } else if ([[self.viewControllers objectAtIndex:i] isKindOfClass:[NZGraphViewController class]]) {
            self.graphVC = (NZGraphViewController *)[self.viewControllers objectAtIndex:i];
            self.graphVCIndex = i;
           // [self.graphVC loadView];
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
   // NSLog(@"seleted item: %lu", self.selectedIndex);
    if ([item isEqual:[self.tabBar.items objectAtIndex:self.bleVCIndex] ]) {
        [[self.tabBar.items objectAtIndex:self.bleVCIndex] setBadgeValue:nil];
    }
}


#pragma mark -
#pragma mark BleServiceDataDelegate
#pragma mark -

-(void) didReceiveData:(uint8_t *)buffer lenght:(NSInteger)length{

    [self initSensorData];
    BOOL isAccelerationExtracted = [self.accelerometerData sensorDataFromBuffer:buffer withLength:length];
    BOOL isOrientationExtracted = [self.orientationData sensorDataFromBuffer:buffer withLength:length];
    
   // NSLog(@"yaw: %f:", [self.orientationData.x.value floatValue]);
   // NSLog(@"pitch: %f:", [self.orientationData.y.value floatValue]);
   // NSLog(@"roll: %f:", [self.orientationData.z.value floatValue]);
    
    if (isAccelerationExtracted) {
        [self.bleVC updateSensorDataTextWithSensorData:self.accelerometerData];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:self.accelerometerData, NZSensorDataKey, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NZDidReceiveSensorDataNotification object:self userInfo:dic];

#warning implement the Notification mechanism
        [self.graphVC updateWithData:self.accelerometerData];
        // the root view controller of a navigation view controller is always
        if (![[self.menuNavigationController viewControllers] objectAtIndex:0]) {
            NSLog(@"The root controller of the navigation controller is nill!!!");
        } else if ([[[self.menuNavigationController viewControllers] objectAtIndex:0] isKindOfClass:[NZMenuViewController class]]) {
            if (!self.accelerometerData) {
                NSLog(@"self.accelerometerData not set!!!");
            } else {
                [(NZMenuViewController *)([[self.menuNavigationController viewControllers] objectAtIndex:0]) receivedData:self.accelerometerData];
            }
        } else {
            NSLog(@"the root controller of navigation controller is not a NZMenuViewController!!!");
        }
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
    //[[NSNotificationCenter defaultCenter] postNotificationName:NZDidConnectToBle object:self];
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


#pragma mark -
#pragma mark helper functions
#pragma mark -

- (void) initSensorData {
    self.accelerometerData = [[SensorData alloc] initWithValueHeadersX:kLinearAccelerationX Y:kLinearAccelerationY Z:kLinearAccelerationZ andOffsetsX:kLinearAccelerationXOffset Y:kLinearAccelerationYOffset Z:kLinearAccelerationZOffset andName:@"Linear Acceleration"];
    
    self.orientationData = [[SensorData alloc] initWithValueHeadersX:kYaw Y:kPitch Z:kRoll andOffsetsX:kYawOffset Y:kPitchOffset Z:kRollOffset andName:@"Orientation Yaw Pitch Roll"];
}

@end
