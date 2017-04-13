//
//  HitTestScrollView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/1/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "HitTestScrollView.h"

@implementation HitTestScrollView


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* result = [super hitTest:point withEvent:event];
    if (self.isIntercept) {
        if (point.y<self.interceptLimits) {
            self.scrollEnabled = NO;
        }else{
            self.scrollEnabled = YES;
        }
    }
    return result;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
