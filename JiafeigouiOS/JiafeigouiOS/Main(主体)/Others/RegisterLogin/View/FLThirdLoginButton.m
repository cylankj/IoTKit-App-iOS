//
//  FLThirdLoginButton.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FLThirdLoginButton.h"

@implementation FLThirdLoginButton

//重载父类方法，修改imageView的位置
-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, 22, contentRect.size.height);
}


//重载父类方法，修改titleLabel的位置
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(20+7, 0, contentRect.size.width, contentRect.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
