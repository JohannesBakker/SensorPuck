//
//  ViewController.h
//  SensorPuck
//
//  Created by RuiFeng on 4/17/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleManager.h"
#import "ScanManager.h"

@interface MainViewController : UIViewController<BleManagerDelegate> {
}

@property (nonatomic, readwrite) BOOL isEnvironmentMode;
@property (nonatomic, retain) ScanManager *scanManager;
@property (nonatomic, retain) BleManager *bleManager;

+(instancetype) sharedInstance;

@end

