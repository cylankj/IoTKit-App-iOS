//
//  PickerShadeView.m
//  GestureRecognizerDemoi
//
//  Created by 杨利 on 16/8/2.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "PickerShadeView.h"

@implementation PickerShadeView


- (void)drawRect:(CGRect)rect {
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    //pickingFieldWidth:圆形框的直径
    CGFloat pickingFieldWidth = 300;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(contextRef);
    CGContextSetRGBFillColor(contextRef, 0, 0, 0, 0.6);
    CGContextSetLineWidth(contextRef, 2);
    //计算圆形框的外切正方形的frame：
    CGRect pickingFieldRect = CGRectMake((width - pickingFieldWidth) / 2, (height - pickingFieldWidth) / 2, pickingFieldWidth, pickingFieldWidth);
    //创建圆形框UIBezierPath:
    UIBezierPath *pickingFieldPath = [UIBezierPath bezierPathWithOvalInRect:pickingFieldRect];
    //创建外围大方框UIBezierPath:
    UIBezierPath *bezierPathRect = [UIBezierPath bezierPathWithRect:rect];
    //将圆形框path添加到大方框path上去，以便下面用奇偶填充法则进行区域填充：
    [bezierPathRect appendPath:pickingFieldPath];
    //填充使用奇偶法则
    bezierPathRect.usesEvenOddFillRule = YES;
    [bezierPathRect fill];
    CGContextSetLineWidth(contextRef, 2);
    CGContextSetRGBStrokeColor(contextRef, 255, 255, 255, 0.1);
    //CGFloat dash[2] = {4,4};
    //[pickingFieldPath setLineDash:dash count:2 phase:0];
    [pickingFieldPath stroke];
    CGContextRestoreGState(contextRef);
    self.layer.contentsGravity = kCAGravityCenter;
}



@end
