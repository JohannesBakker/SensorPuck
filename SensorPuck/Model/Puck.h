//
//  Puck.h
//  SensorPuck
//
//  Created by Admin on 4/19/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Puck : NSObject

@property (nonatomic, retain)NSString *_address;
@property (nonatomic, retain)NSString *_name;
@property (nonatomic, readwrite)int _measurementMode;
@property (nonatomic, readwrite)int _sequence;
@property (nonatomic, readwrite)float _humidity;
@property (nonatomic, readwrite)float _temperature;
@property (nonatomic, readwrite)int _ambientLight;
@property (nonatomic, readwrite)int _uvIndex;
@property (nonatomic, readwrite)float _baterry;
@property (nonatomic, readwrite)int _HRMState;
@property (nonatomic, readwrite)int _HRMRate;
@property (nonatomic, readwrite)NSMutableArray *_HRMSample;
@property (nonatomic, readwrite)int _HRMPrevSample;

@property (nonatomic, readwrite)int _prevSequence;
@property (nonatomic, readwrite)int _recvCount;
@property (nonatomic, readwrite)int _prevCount;
@property (nonatomic, readwrite)int _uniqueCount;
@property (nonatomic, readwrite)int _lostAdv;
@property (nonatomic, readwrite)int _lostCount;
@property (nonatomic, readwrite)int _idleCount;
@property (nonatomic, readwrite)double _timestamp;

- (NSString*)getPuckDefaultName;

@end
