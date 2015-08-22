//
//  DBManager.m
//  ProximityBLE
//
//  Created by Admin on 2/10/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "DBManager.h"
#import "AppDelegate.h"

@implementation DBManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (void) saveAddress:(NSString *)key newAddress:(NSString *)newAddress {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: newAddress forKey:key];
    [defaults synchronize];
}

- (NSString *)loadAddress:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedAddress = [defaults stringForKey:key];
    
    return savedAddress;
}

@end
