//
//  DBManager.h
//  ProximityBLE
//
//  Created by Admin on 2/10/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject {
}

+ (instancetype)sharedInstance;

- (void) saveAddress:(NSString *)key newAddress:(NSString *)newAddress;
- (NSString *)loadAddress:(NSString *)key;

@end
