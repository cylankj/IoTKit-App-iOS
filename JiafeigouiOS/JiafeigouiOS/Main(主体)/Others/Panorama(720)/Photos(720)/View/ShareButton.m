//
//  ShareButton.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/5/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ShareButton.h"

@implementation ShareButton

//重载父类方法，修改imageView的位置
-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.height);
}


//重载父类方法，修改titleLabel的位置
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat tWidth = contentRect.size.width*1.2;
    CGFloat tX = (contentRect.size.width - tWidth)*0.5;
    
    return CGRectMake(tX, 20+20, tWidth, contentRect.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
