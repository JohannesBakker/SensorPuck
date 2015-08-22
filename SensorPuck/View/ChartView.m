//
//  ChartView.m
//  SensorPuck
//
//  Created by Admin on 5/5/15.
//  Copyright (c) 2015 RuiFeng. All rights reserved.
//

#import "ChartView.h"
#import "Constant.h"

#define AXIS_LINECOUNT          8
#define GRAPH_DOT_RADIUS        1.0f
#define GRAPH_LINE_WIDTH        0.5f

@interface ChartView() {
}
@end

@implementation ChartView

@synthesize pointData;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    int xLen = self.bounds.size.width;
    int yLen = self.bounds.size.height;
    
    //////////////////////
    // draw start x, y axis
    int xStep = xLen / AXIS_LINECOUNT;
    int yStep = yLen / AXIS_LINECOUNT;
    for (int i = 0; i < AXIS_LINECOUNT; i++) {
        [self drawLine:context color:[UIColor lightGrayColor] width:1.0f startPoint:CGPointMake(i * xStep, 0) endPoint:CGPointMake(i * xStep, yLen)];
        [self drawLine:context color:[UIColor lightGrayColor] width:1.0f startPoint:CGPointMake(0, i * yStep) endPoint:CGPointMake(xLen, i * yStep)];
    }
    // draw stop x, y axis
    //////////////////////
    
    //////////////////////
    // draw start heart beat data
    double xBeatStep = xLen / GRAPH_DOMAIN_SIZE;
    if (pointData.count == 0) {
        return;
    }
    for (int i = 1; i <= pointData.count; i++) {
        double fYVal = ([[pointData objectAtIndex:i-1] doubleValue]/GRAPH_RANGE_SIZE)*yLen;
        NSLog(@"Y Val: %f", fYVal);
        [self drawCircle:context color:[UIColor redColor] radius:GRAPH_DOT_RADIUS CenterPoint:CGPointMake(i*xBeatStep, fYVal)];
        if (i > 1) {
            [self drawLine:context
                     color:[UIColor redColor]
                     width:GRAPH_LINE_WIDTH
                     startPoint:CGPointMake((i-1)*xBeatStep, ([[pointData objectAtIndex:i-2] doubleValue]/GRAPH_RANGE_SIZE)*yLen)
                     endPoint:CGPointMake(i*xBeatStep, ([[pointData objectAtIndex:i-1] doubleValue]/GRAPH_RANGE_SIZE)*yLen)];
        }
    }
    // draw stop heart beat data
    //////////////////////
}

- (void)drawLine:(CGContextRef)ctx color:(UIColor *)c width:(float)w startPoint:(CGPoint)sp endPoint:(CGPoint)ep {
    
    CGContextSetStrokeColorWithColor(ctx, c.CGColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, sp.x, sp.y);
    CGContextAddLineToPoint(ctx, ep.x, ep.y);
    
    CGContextStrokePath(ctx);
}

- (void)drawCircle:(CGContextRef)ctx fillColor:(UIColor *)fc strokeColor:(UIColor *)sc radius:(float)r CenterPoint:(CGPoint)cp {
    
    // Set the width of the line
    CGContextSetLineWidth(ctx, 2.0);
    
    //Make the circle
    // 150 = x coordinate
    // 150 = y coordinate
    // 100 = radius of circle
    // 0   = starting angle
    // 2*M_PI = end angle
    // YES = draw clockwise
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, cp.x, cp.y, r, 0, 2*M_PI, YES);
    CGContextClosePath(ctx);
    
    //color
    CGContextSetFillColorWithColor(ctx, fc.CGColor);
    CGContextSetStrokeColorWithColor(ctx, sc.CGColor);
    
    // Note: If I wanted to only stroke the path, use:
    // CGContextDrawPath(context, kCGPathStroke);
    // or to only fill it, use:
    // CGContextDrawPath(context, kCGPathFill);
    
    //Fill/Stroke the path
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
}

- (void)drawCircle:(CGContextRef)ctx color:(UIColor *)c radius:(float)r CenterPoint:(CGPoint)cp {
    
    [self drawCircle:ctx fillColor:c strokeColor:c radius:r CenterPoint:cp];
}

- (void)drawText:(CGContextRef)ctx text:(NSString *)t size:(float)s point:(CGPoint)p {
    
    CGContextSetTextDrawingMode(ctx, kCGTextFill); // This is the default
    
    [[UIColor redColor] setFill]; // This is the default
    
    [t drawAtPoint:CGPointMake(p.x, p.y)
    withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:s]}];
}

- (void)clearGraph {
    if (pointData == nil) {
        pointData = [NSMutableArray array];
    }
    else {
        [pointData removeAllObjects];
    }
}

- (void) setGraphData:(NSMutableArray *)array {
    pointData = array;
}

- (NSMutableArray *)getOldPoints {
    if (pointData == nil) {
        pointData = [NSMutableArray array];
    }
    return pointData;
}

@end
