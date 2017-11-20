//
//  PopAnimation.h
//  JiafeigouiOS
//
//  Created by yangli on 16/6/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <pop/POP.h>

@interface PopAnimation : NSObject
/**
 *  旋转动画
 *
 *  @param animationView 旋转的视图
 */
+(void)startRotationAnimationForView:(UIView *)animationView;

/**
 *  停止旋转动画
 *
 *  @param animationView 旋转的视图
 */
+(void)stopRotationAnimationForView:(UIView *)animationView;


/**
 *  带有弹性动画的视图位置移动
 *
 *  @param center   目的中心点
 *  @param view     动画视图
 *  @param complete 视图结束回调
 */
+(void)startSpringPositonAnimation:(CGPoint)center withView:(UIView *)view completionBlock:(void(^)(void))complete;


/**
 *  结束视图的位置移动
 *
 *  @param animationView 动画视图
 */
+(void)stopSpringPositonAnimaitonForView:(UIView *)animationView;

/**
 *  透明度动画
 *
 *  @param animationView 动画视图
 *  @param alpha         要设置成的透明度
 */
+(void)startSpringAlphaAnimationForView:(UIView *)animationView alpha:(CGFloat)alpha;

+(CATransition *)moveTopAnimation;
+(CATransition *)moveBottomAnimation;
@end
