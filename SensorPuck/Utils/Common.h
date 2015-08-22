//
//  Common.h
//  SensorPuck
//
//  Created by Admin on 4/23/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Common : NSObject

+ (instancetype)sharedInstance;

- (double)getCurrentMilisecond;
- (void)addTopBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth;
- (void)addBottomBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth;
- (void)addLeftBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth;
- (void)addLeftBorderWithColorAndHeight:(UIView*)view color:(UIColor *)color andWidth:(CGFloat)borderWidth andHeight:(CGFloat)borderHeight;
- (void)addRightBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth;
- (void)addRightBorderWithColorAndHeight:(UIView*)view color:(UIColor *)color andWidth:(CGFloat)borderWidth andHeight:(CGFloat)borderHeight;

@end
