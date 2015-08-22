//
//  Common.m
//  SensorPuck
//
//  Created by Admin on 4/23/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "Common.h"

@implementation Common

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (double)getCurrentMilisecond {
    double curTime = 0.0f;
    curTime = (double)[[NSDate date] timeIntervalSince1970];
    
    return curTime;
}

- (void)addTopBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
    [view.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
    [view.layer addSublayer:border];
}

- (void)addLeftBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

- (void)addLeftBorderWithColorAndHeight:(UIView*)view color:(UIColor *)color andWidth:(CGFloat)borderWidth andHeight:(CGFloat)borderHeight{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, view.frame.size.height - borderHeight, borderWidth, borderHeight);
    [view.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIView*)view color:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

- (void)addRightBorderWithColorAndHeight:(UIView*)view color:(UIColor *)color andWidth:(CGFloat)borderWidth andHeight:(CGFloat)borderHeight{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(view.frame.size.width - borderWidth, view.frame.size.height - borderHeight, borderWidth, borderHeight);
    [view.layer addSublayer:border];
}

@end
