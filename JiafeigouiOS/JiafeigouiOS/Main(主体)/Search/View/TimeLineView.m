//
//  TimeLineView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/5/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "TimeLineView.h"
#import "UIColor+HexColor.h"
#import "FLGlobal.h"
@implementation TimeLineView

- (id)initWithFrame:(CGRect)frame
{
    self= [super initWithFrame:frame];
    
    if(self) {
        
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //    CGFloat selfWidth =CGRectGetWidth(rect);
    
    CGFloat selfHeight =CGRectGetHeight(rect);
    
    CGFloat lineWidth =1.f;
    
    CGContextRef context =UIGraphicsGetCurrentContext();  //获取绘图上下文----画板
    CGContextSetLineWidth(context, lineWidth);  //设置线宽
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"#e1e1e1"].CGColor);  //设置线的颜色
    CGFloat lengths[] = {2,1};
    CGContextSetLineDash(context, 0, lengths ,2);  //设置虚线的样式
    CGContextMoveToPoint(context, 23, 0);  //将路径绘制的起点移动到一个位置，即设置线条的起点
    CGContextAddLineToPoint(context, 23, selfHeight);  //在图形上下文移动你的笔画来指定线条的终点
    CGContextStrokePath(context);  //创建你已经设定好的路径。此过程将使用图形上下文已经设置好的颜色来绘制路径。
}
@end
