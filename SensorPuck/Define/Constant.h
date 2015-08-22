//
//  Constant.h
//  SensorPuck
//
//  Created by Admin on 4/19/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TEST_MODE           NO

/* Sensor Data types */
#define SD_MODE             0
#define SD_SEQUENCE         1
#define SD_HUMIDITY         2
#define SD_TEMPERATURE      3
#define SD_AMB_LIGHT        4
#define SD_UV_LIGHT         5
#define SD_BATTERY          6
#define SD_HRM_STATE        16
#define SD_HRM_RATE         17
#define SD_HRM_SAMPLE       18

/* Measurement Mode */
#define ENVIRONMENTAL_MODE  0
#define BIOMETRIC_MODE      1
#define PENDING_MODE        2
#define NOT_FOUND_MODE      3

/* Heart Rate Monitor state */
#define HRM_STATE_IDLE      0
#define HRM_STATE_NOSIGNAL  1
#define HRM_STATE_ACQUIRING 2
#define HRM_STATE_ACTIVE    3
#define HRM_STATE_INVALID   4
#define HRM_STATE_ERROR     5

#define HRM_SAMPLE_COUNT     5
#define MAX_PUCK_COUNT      16
#define MAX_IDLE_COUNT      3

#define GRAPH_RANGE_SIZE    40000

@interface Constant : NSObject

@end
