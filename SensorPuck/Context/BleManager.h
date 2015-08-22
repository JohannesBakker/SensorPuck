//
//  BleManager.h
//  SensorPuck
//
//  Created by Admin on 4/19/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Puck.h"
#import "ScanManager.h"

@protocol BleManagerDelegate <NSObject>

@optional
- (void)onReadSensorData:(Puck *)puck;
- (void)getPucks:(NSMutableArray *)pucks;

@end

@interface BleManager : NSObject <ScanManagerDelegate>

@property (nonatomic, retain) Puck              *curPuck;
@property (nonatomic, retain) NSMutableArray    *puckArray;

@property (nonatomic, retain)id<BleManagerDelegate> delegateMainView;
@property (nonatomic, retain)id<BleManagerDelegate> delegateSideMenu;

+ (instancetype)sharedInstance;

- (Puck*)getCurrentPuck;
- (void)setCurrentPuck:(Puck*)puck;
- (Puck*)findPuck:(NSString *)address;
- (void)updatePuckName:(NSString *)newName;

@end
