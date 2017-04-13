//
//  RecordButton.m
//  TestTouchMove
//
//  Created by lirenguang on 16/3/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "RecordButton.h"

@implementation RecordButton

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch=[touches anyObject];
    CGPoint touchPoint=[touch locationInView:self];
    NSLog(@"touch  begin______%@", NSStringFromCGPoint(touchPoint));
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch=[touches anyObject];
    CGPoint touchPoint=[touch locationInView:self];
    
    if (touchPoint.y <= -50) // 以 -50 为分界
    {
        _isToUp = YES;
    }
    else
    {
        _isToUp = NO;
    }
  
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch=[touches anyObject];
    CGPoint touchPoint=[touch locationInView:self];
    NSLog(@"touch  end______%@", NSStringFromCGPoint(touchPoint));
    
}

@end
