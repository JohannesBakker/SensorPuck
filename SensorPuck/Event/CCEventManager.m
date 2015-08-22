//
//  CCEventManager.m
//  WellnessChallenge
//
//  Created by Donald Pae on 4/13/15.
//  Copyright (c) 2015 Calorie Cloud. All rights reserved.
//

#import "CCEventManager.h"
#import "CCEvent.h"

@interface CCEventManager ()
{
    NSThread *thread;
    NSOperationQueue *operationQueue;
    BOOL stopped;
    NSMutableArray *arrayObservers;
    NSMutableArray *arrayEvents;
    NSLock *lock;
}

@end

@implementation CCEventManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    arrayObservers = [[NSMutableArray alloc] init];
    arrayEvents = [[NSMutableArray alloc] init];
    
    operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    
    lock = [[NSLock alloc] init];
    
    stopped = NO;
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadProc) object:nil];
    [thread start];
    
    return self;
}

+ (BOOL)isEvent:(CCEvent *)e name:(NSString *)name {
    if ([e.name isEqualToString:name]) {
        return YES;
    }
    return NO;
}

- (void)registerObserver:(id<CCEventDelegate>)observer {
    [lock lock];
    [arrayObservers addObject:observer];
    [lock unlock];
}

- (void)unregisterObserver:(id<CCEventDelegate>)observer {
    [lock lock];
    [arrayObservers removeObject:observer];
    [lock unlock];
}

#pragma mark - thread proc
- (void)threadProc {
    while (!stopped) {
        [lock lock];
        
        for (CCEvent *event in arrayEvents) {
            for (id<CCEventDelegate> observer in arrayObservers) {
                if ([observer respondsToSelector:@selector(onEvent:)]) {
                    [operationQueue addOperationWithBlock:^{
                        [observer onEvent:event];
                    }];
                }
                else if ([observer respondsToSelector:@selector(onEventMainThread:)]) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [observer onEventMainThread:event];
                    }];
                }
            }
        }
        [arrayEvents removeAllObjects];
        
        [lock unlock];
        [self sleepFor];
    }    
}

- (void)sleepFor {
    [NSThread sleepForTimeInterval:0.01];
}

#pragma mark - post methods
- (void)postEvent:(CCEvent *)event {
    [lock lock];
    [arrayEvents addObject:event];
    [lock unlock];
}

- (void)postWithName:(NSString *)name {
    CCEvent *event = [[CCEvent alloc] initWithName:name];
    [self postEvent:event];
}

- (void)postWithName:(NSString *)name object:(id)object {
    CCEvent *event = [[CCEvent alloc] initWithName:name object:object];
    [self postEvent:event];
}

- (void)postWithName:(NSString *)name object:(id)object msg:(NSString *)msg {
    CCEvent *event = [[CCEvent alloc] initWithName:name object:object msg:msg];
    [self postEvent:event];
}


@end
