//
//  ScanManager.h
//
//  Created by Igor Ishchenko on 12/20/13.
//  Copyright (c) 2013 Igor Ishchenko All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "SensorReadingParser.h"

@protocol ScanManagerDelegate <NSObject>

@optional
- (void)didFindSensorDevice:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData;

@end

@interface ScanManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate, ScanManagerDelegate>

@property (nonatomic, assign) id<ScanManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)startScan;
- (void)stopScan;
- (void)restartScan;

@end
