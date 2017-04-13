//
//  PopAnimation.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "PopAnimation.h"

@implementation PopAnimation

+(void)startRotationAnimationForView:(UIView *)animationView
{
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 25;
    //开始角度
    //baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    [animationView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

+(void)stopRotationAnimationForView:(UIView *)animationView
{
    [animationView.layer pop_removeAnimationForKey:@"rotation"];
}

//改变位置
+(void)startSpringPositonAnimation:(CGPoint)center withView:(UIView *)view completionBlock:(void(^)(void))complete
{
    //弹性动画
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    animation.toValue = [NSValue valueWithCGPoint:center];
    //速度
    animation.springSpeed = 15;
    //弹力
    animation.springBounciness = 8;
    //摩擦力
    animation.dynamicsFriction = 15;
    //张力
    animation.dynamicsTension = 80;
    
    animation.completionBlock = ^(POPAnimation *anim,BOOL finished){
        if (complete) {
            complete();
        }
    };
    [view pop_addAnimation:animation forKey:@"center"];
}

+(void)stopSpringPositonAnimaitonForView:(UIView *)animationView
{
    [animationView pop_removeAnimationForKey:@"center"];
}


+(void)startSpringAlphaAnimationForView:(UIView *)animationView alpha:(CGFloat)alpha
{
    //弹性动画
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    animation.toValue = [NSNumber numberWithFloat:alpha];
    //速度
    animation.springSpeed = 50;
    //弹力
    animation.springBounciness = 10;
    //摩擦力
    animation.dynamicsFriction = 15;
    //张力
    animation.dynamicsTension = 85;
    
    animation.completionBlock = ^(POPAnimation *anim,BOOL finished){
        
    };
    [animationView pop_addAnimation:animation forKey:@"alpha"];
}

@end
