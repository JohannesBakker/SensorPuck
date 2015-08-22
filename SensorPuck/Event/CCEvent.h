//
//  CCEvent.h
//  WellnessChallenge
//
//  Created by Donald Pae on 4/13/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEvent : NSObject

@property (nonatomic, retain, readonly) NSString *name;
@property (nonatomic, retain, readonly) id object;
@property (nonatomic, retain, readonly) NSString *msg;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name object:(id)object;
- (id)initWithName:(NSString *)name object:(id)object msg:(NSString *)msg;

- (BOOL)isSameEvent:(CCEvent *)e;

@end
