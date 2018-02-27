//
//  GestureCollection.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/12/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "GestureCollection.h"

@implementation GestureCollection


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //这个方法返回YES，第一个手势和第二个互斥时，第一个会失效
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
