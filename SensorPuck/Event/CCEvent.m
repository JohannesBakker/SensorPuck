//
//  CCEvent.m
//  WellnessChallenge
//
//  Created by Donald Pae on 4/13/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import "CCEvent.h"

@implementation CCEvent

- (id)initWithName:(NSString *)name {
    self = [super init];
    _name = name;
    _object = nil;
    _msg = nil;
    return self;
}

- (id)initWithName:(NSString *)name object:(id)object {
    self = [super init];
    _name = name;
    _object = object;
    _msg = nil;
    return self;
}

- (id)initWithName:(NSString *)name object:(id)object msg:(NSString *)msg {
    self = [super init];
    _name = name;
    _object = object;
    _msg = msg;
    return self;
}

- (BOOL)isSameEvent:(CCEvent *)e {
    if ([_name isEqualToString:e.name]) {
        return YES;
    }
    return NO;
}

@end
