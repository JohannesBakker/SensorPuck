//
//  BleManager.m
//  SensorPuck
//
//  Created by Admin on 4/19/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "BleManager.h"
#import "Constant.h"
#import "SensorReadingParser.h"
#import "Common.h"
#import "DBManager.h"

#define PUCK_NOFOUND_TIMEOUT    10.0f

@interface BleManager() {
    NSTimer *_timer;
    NSLock *_lock;
}

@end

@implementation BleManager

@synthesize puckArray;
@synthesize curPuck;

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (instancetype)init{
    if (self != nil) {
        if (puckArray == nil) {
            puckArray = [[NSMutableArray alloc] init];
            curPuck = [[Puck alloc] init];
        }
        
        _lock = [[NSLock alloc] init];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkPucks:) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (Puck*)getCurrentPuck {
    if (curPuck == nil) {
        curPuck = [[Puck alloc] init];
    }
    
    return curPuck;
}

- (BOOL) isCurrentPuck:(Puck*)puck {
    if ([curPuck._address isEqualToString:puck._address]) {
        return YES;
    }
    
    return NO;
}

- (void) setCurrentPuck:(Puck*)puck {
    curPuck = puck;
}


- (Puck*)findPuck:(NSString *)address{
    if (puckArray.count == MAX_PUCK_COUNT)
        return nil;
    
    for (Puck *puck in puckArray) {
        if ([puck._address isEqualToString:address]) {
            return puck;
        }
    }
    
    Puck *addingPuck = [[Puck alloc] init];
    addingPuck._address = address;
    
    NSString *szName = [[DBManager sharedInstance] loadAddress:address];
    if (szName == nil || szName.length == 0)
        addingPuck._name = [addingPuck getPuckDefaultName];
    else
        addingPuck._name = szName;
    addingPuck._prevSequence = 0;
    addingPuck._recvCount = 0;
    addingPuck._prevCount = -1;
    addingPuck._uniqueCount = 0;
    addingPuck._lostCount = 0;
    addingPuck._idleCount = 0;
    
    NSLog(@"adding puck's name: %@", addingPuck._name);
    
    if (puckArray.count == 0)
        curPuck = addingPuck;
    
    [puckArray addObject:addingPuck];
    
    return  addingPuck;
}

- (void)didFindSensorDevice:(CBPeripheral *)peripheral advertisementData:(NSData *)advertisementData {
    NSData *manufacturedData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    
    if ([[SensorReadingParser sharedInstance] validSensor:manufacturedData]){
        NSDictionary *dictionary = [[NSDictionary alloc] init];
        
        Puck *puck = [[BleManager sharedInstance] findPuck:[[SensorReadingParser sharedInstance] getSensorDataAddress:manufacturedData]];
        if (puck == nil) {
            return;
        }
        
        if ([[SensorReadingParser sharedInstance] getSensorDataMode:manufacturedData] == ENVIRONMENTAL_MODE) {
            dictionary = [[SensorReadingParser sharedInstance] parseEnvironmentData:manufacturedData];
            [self setEnvironmentData:puck parseData:dictionary];
        }
        else if ([[SensorReadingParser sharedInstance] getSensorDataMode:manufacturedData] == BIOMETRIC_MODE) {
            dictionary = [[SensorReadingParser sharedInstance] parseBiometricData:manufacturedData];
            [self setBiometricData:puck parseData:dictionary];
        }
        
        puck._recvCount++;
        
        if (puck._sequence != puck._prevSequence) {
            puck._uniqueCount++;
            
            if ( puck._sequence > puck._prevSequence )
                puck._lostAdv = puck._sequence - puck._prevSequence - 1;
            else
                puck._lostAdv = puck._sequence - puck._prevSequence + 255;
            
            /* Big losses means just found a new puck */
            if ( (puck._lostAdv == 1) || (puck._lostAdv == 2) )
                puck._lostCount += puck._lostAdv;
            
            puck._prevSequence = puck._sequence;
        
            /* Display new sensor data for the selected puck */
            if ( [self isCurrentPuck:puck] ) {
                if (self.delegateMainView != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegateMainView onReadSensorData:curPuck];
                    });
                    
                }
            }
        }
    }
}

- (void)setEnvironmentData:(Puck*)thisPuck parseData:(NSDictionary*)dictionary {
    thisPuck._measurementMode = ENVIRONMENTAL_MODE;
    thisPuck._sequence = [[dictionary objectForKey:kSensorDataSequenceKey] integerValue];
    thisPuck._temperature= [[dictionary objectForKey:kSensorDataTemperatureKey] doubleValue];
    thisPuck._humidity = [[dictionary objectForKey:kSensorDataHumidityKey] doubleValue];
    thisPuck._ambientLight = [[dictionary objectForKey:kSensorDataLightKey] integerValue];
    thisPuck._uvIndex = [[dictionary objectForKey:kSensorDataUVIndexKey] integerValue];
    thisPuck._baterry= [[dictionary objectForKey:kSensorDataVoltageKey] doubleValue];
    thisPuck._timestamp = [[Common sharedInstance] getCurrentMilisecond];
}

- (void)setBiometricData:(Puck*)thisPuck parseData:(NSDictionary*)dictionary {
    thisPuck._measurementMode = BIOMETRIC_MODE;
    thisPuck._sequence = [[dictionary objectForKey:kSensorDataSequenceKey] integerValue];
    thisPuck._HRMState = [[dictionary objectForKey:kSensorDataHRMStateKey] integerValue];
    thisPuck._HRMRate = [[dictionary objectForKey:kSensorDataHRMRateKey] integerValue];
    if (thisPuck._HRMSample == nil || thisPuck._HRMSample.count == 0)
        thisPuck._HRMPrevSample = 0;
    else
        thisPuck._HRMPrevSample = [[thisPuck._HRMSample objectAtIndex:(HRM_SAMPLE_COUNT-1)] integerValue];
    thisPuck._HRMSample = [dictionary objectForKey:kSensorDataHRMSampleKey];
    thisPuck._timestamp = [[Common sharedInstance] getCurrentMilisecond];
}

-(void)checkPucks:(NSTimer *)timer {
    [_lock lock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    BOOL isCurPuck = NO;
    double timeStamp = [[Common sharedInstance] getCurrentMilisecond];
    
    NSMutableArray *arrayBuf = [[NSMutableArray alloc] init];
    for (Puck *puck in puckArray) {
        if ( (timeStamp - puck._timestamp) >= PUCK_NOFOUND_TIMEOUT ) {
            if ([self isCurrentPuck:puck]) {
                isCurPuck = YES;
            }
        }
        else {
            [arrayBuf addObject:puck];
        }
    }
    
    puckArray = arrayBuf;
    
    if (isCurPuck) {
        if ([puckArray count] > 0) {
            curPuck = [puckArray objectAtIndex:0];
        } else {
            curPuck = nil;
        }
    }
    
    if (self.delegateMainView != nil) {
        [self.delegateMainView onReadSensorData:curPuck];
        [self.delegateMainView getPucks:puckArray];
    }
    if (self.delegateSideMenu != nil) {
        [self.delegateSideMenu getPucks:puckArray];
    }
    });
    
    [_lock unlock];
}

- (void)updatePuckName:(NSString *)newName {
    for (Puck *puck in puckArray) {
        if ([self isCurrentPuck:puck]) {
            puck._name = newName;
            if (self.delegateSideMenu != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self.delegateSideMenu getPucks:puckArray];
                });
            }
            break;
        }
    }
}

@end
