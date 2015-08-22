//
//  Puck.m
//  SensorPuck
//
//  Created by Admin on 4/19/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "Puck.h"

@implementation Puck

- (id) init {
    self = [super init];
    if (self != nil) {
        self._lostAdv = 0;
    }
    
    return self;
}

- (NSString*)getPuckDefaultName {
    NSString *szName;
    
    if (self._address == nil || self._address.length == 0)
        return @"Puck_None";
    
    szName = [NSString stringWithFormat:@"Puck_%@", self._address];
    
    return szName;
}

@end
