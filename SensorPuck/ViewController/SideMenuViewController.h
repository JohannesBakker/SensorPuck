//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>
#import "BleManager.h"

@interface SideMenuViewController : UITableViewController<BleManagerDelegate>

@property (nonatomic, retain) BleManager *bleManager;

@end