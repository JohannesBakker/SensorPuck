//
//  CCEventManager.h
//  WellnessChallenge
//
//  Created by Donald Pae on 4/13/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCEvent.h"

@protocol CCEventDelegate <NSObject>

@optional
- (void)onEvent:(CCEvent *)e;
- (void)onEventMainThread:(CCEvent *)e;

@end


@interface CCEventManager : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)isEvent:(CCEvent *)e name:(NSString *)name;

- (void)registerObserver:(id<CCEventDelegate>)observer;
- (void)unregisterObserver:(id<CCEventDelegate>)observer;

- (void)postWithName:(NSString *)name;
- (void)postWithName:(NSString *)name object:(id)object;
- (void)postWithName:(NSString *)name object:(id)object msg:(NSString *)msg;

@end
