//
//  ScanManager.m
//
//  Created by Igor Ishchenko on 12/20/13.
//  Copyright (c) 2013 Igor Ishchenko All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Advertisement.h"
#import "ScanManager.h"
#import "BleManager.h"
#import "SensorReadingParser.h"

@interface ScanManager () {
    NSDictionary *beforeData;
    NSTimeInterval mLastTakingTime;
    dispatch_queue_t queue;
}

@property (nonatomic, retain) CBCentralManager *bluetoothCentralManager;

- (void)showAlertWithTitle:(NSString*)title description:(NSString*)description;

@end

@implementation ScanManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (void)dealloc {
    [_bluetoothCentralManager setDelegate:nil];
}

- (id)init {
    if (self = [super init]) {
        queue = dispatch_queue_create("queue_for_logic", NULL);
        //_bluetoothCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue];
        _bluetoothCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _delegate = [BleManager sharedInstance];
        
        NSLog(@"bluetooth - centeral manager inited!");
        
        beforeData = nil;
        mLastTakingTime = -1;
        
        [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(AsktoSacnForPeripheral) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)startScan {
    [[self bluetoothCentralManager] scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @(YES)}];
}

- (void)stopScan {
    if (self.bluetoothCentralManager == nil)
    {
        NSLog(@"bluetoothCentralManager == nil");
        return;
    }
    [self.bluetoothCentralManager stopScan];
    NSLog(@"Stopped scan");
}

- (void)restartScan {
    [self stopScan];
    [self startScan];
    NSLog(@"Restarted scan");

}

#pragma mark - Bluetooth

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {

    NSString *stateDescription;

    switch ([central state]) {
        case CBCentralManagerStateResetting:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateResetting %d ", (int)central.state];
            break;
        case CBCentralManagerStateUnsupported:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnsupported %d ", (int)central.state];
            [self showAlertWithTitle:@"Error" description:@"This device does not support Bluetooth low energy."];
            break;
        case CBCentralManagerStateUnauthorized:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnauthorized %d ", (int)central.state];
            [self showAlertWithTitle:@"Unauthorized!"
                         description:@"This app is not authorized to use Bluetooth low energy.\n\nAuthorize in Settings > Bluetooth."];
            break;
        case CBCentralManagerStatePoweredOff:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStatePoweredOff %d ", (int)central.state];
            [self showAlertWithTitle:@"Powered Off" description:@"Bluetooth is currently powered off.\n\nPower ON the bluetooth in Settings > Bluetooth."];
            break;
        case CBCentralManagerStatePoweredOn:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStatePoweredOn %d ", (int)central.state];
            [self startScan];
            break;
        case CBCentralManagerStateUnknown:
            stateDescription = [NSString stringWithFormat:@"CBCentralManagerStateUnknown %d ", (int)central.state];
            break;
        default:
            stateDescription = [NSString stringWithFormat:@"CBCentralManager Undefined %d ", (int)central.state];
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    int isconnectable = [[advertisementData valueForKey:CBAdvertisementDataIsConnectable] intValue];
    if (isconnectable == 0) {
        dispatch_async(queue, ^{
           [self.delegate didFindSensorDevice:peripheral advertisementData:advertisementData];
        });
    }
    
}

- (void)showAlertWithTitle:(NSString *)title description:(NSString *)description {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:description
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert performSelectorOnMainThread:@selector(show)
                            withObject:nil
                         waitUntilDone:YES];
}

-(void)AsktoSacnForPeripheral
{
    NSLog(@"Scan Start Again");
    [self.bluetoothCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

@end
