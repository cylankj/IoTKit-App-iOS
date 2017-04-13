//
//  DelButton.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DelButton.h"

@implementation DelButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds =self.bounds;
    
    CGFloat widthDelta =44.0- bounds.size.width;
    
    CGFloat heightDelta =44.0- bounds.size.height;
    
    bounds =CGRectInset(bounds, -0.5* widthDelta, -0.5* heightDelta);//注意这里是负数，扩大了之前的bounds的范围
    //NSLog(@"*****%@,%@",NSStringFromCGRect(bounds),NSStringFromCGPoint(point));
    return CGRectContainsPoint(bounds, point);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
