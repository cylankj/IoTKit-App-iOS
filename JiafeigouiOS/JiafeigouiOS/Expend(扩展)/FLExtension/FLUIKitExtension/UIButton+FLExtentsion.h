//
//  UIButton+FLExtentsion.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+FLExtension.h"

@interface UIButton (FLExtentsion)

+ (id)initWithFrame:(CGRect)frame;


/**通过图片创建Button*/
+(id)initWithFrame:(CGRect)frame
             image:(UIImage *)image
  highlightedImage:(UIImage *)highlightedImage
      cornerRadius:(CGFloat)radius
handerForTouchUpInside:(void(^)(UIButton *button))hander;


/**通过背景图与文字创建Button*/
+(id)initWithFrame:(CGRect)frame
   backgroundImage:(UIImage *)image
  highlightedImage:(UIImage *)highlightedImage
             title:(NSString *)title
              font:(UIFont *)font
        titleColor:(UIColor *)color
      cornerRadius:(CGFloat)radius
handerForTouchUpInside:(void(^)(UIButton *button))hander;

/**通过背景色与文字创建Button*/
+(id)initWithFrame:(CGRect)frame
   backgroundColor:(UIColor *)Color
  highlightedColor:(UIColor *)highlightedColor
             title:(NSString *)title
              font:(UIFont *)font
        titleColor:(UIColor *)titleColor
      cornerRadius:(CGFloat)radius
handerForTouchUpInside:(void(^)(UIButton *button))hander;


- (void)setTitleFont:(FontName)fontName
                size:(CGFloat)size;


- (void)setTitleColor:(UIColor *)color;


- (void)setTitleColor:(UIColor *)color
     highlightedColor:(UIColor *)highlightedColor;


-(void)setCornerRadius:(CGFloat)radius;


/**
 使用Block回调TouchUpInside方法
 */
-(void)bk_initWihtHanderForTouchUpInside:(void(^)(UIButton *button))hander;



@end
