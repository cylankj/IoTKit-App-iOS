//
//  FLButton.h
//  FLExtensionTask
//
//  Created by 紫贝壳 on 15/8/14.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FLButton : UIButton

/**
 创建一个高亮图片渐变动画的UIButton
 @param image 背景图片
 @param highlightedImage 点击高亮图片
 @param fadeDuration 高亮图片渐变消失时间
 */
- (id)initWithFrame:(CGRect)frame
              image:(UIImage *)image
   highlightedImage:(UIImage *)highlightedImage
       fadeDuration:(CGFloat)fadeDuration;

/**
 创建一个高亮颜色渐变动画的UIButton
 @param image 背景颜色
 @param highlightedImage 点击高亮颜色
 @param fadeDuration 高亮颜色渐变消失时间
 */
- (id)initWithFrame:(CGRect)frame
              color:(UIColor *)color
   highlightedColor:(UIColor *)highlightedColor
       fadeDuration:(CGFloat)fadeDuration;


@end
