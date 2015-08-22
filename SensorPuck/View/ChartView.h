//
//  ChartView.h
//  SensorPuck
//
//  Created by Admin on 5/5/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRAPH_DOMAIN_SIZE       50

@interface ChartView : UIView {
    NSMutableArray *pointData;
}

@property (nonatomic, retain) NSMutableArray *pointData;

- (void)clearGraph;
- (void) setGraphData:(NSMutableArray *)array;
- (NSMutableArray *)getOldPoints;

@end
