//
//  UIImage+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (FLExtension)

/**
 *  混合遮盖
 */
- (UIImage *)blendOverlay;

/**
 *  通过另一个图像和大小遮盖自身
 */
- (UIImage *)maskWithImage:(UIImage *)image
                   andSize:(CGSize)size;

/**
 *  通过另一个图像遮盖自身
 */
- (UIImage *)maskWithImage:(UIImage *)image;

/**
 *  通过自身创建一个给定大小的图像
 */
- (UIImage *)imageAtRect:(CGRect)rect;

/**
 *  缩放图像到相匹配的尺寸
 */
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

/**
 *  缩放图像到给出最小尺寸
 */
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;

/**
 *  缩放图像到给出最大尺寸
 */
- (UIImage *)imageByScalingProportionallyToMaximumSize:(CGSize)targetSize;

/**
 *  比例缩放图像
 */
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

/**
 *  通过给定的弧度旋转图像
 */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

/**
 *  通过给定的角度旋转图像
 */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

/**
 *  检查是否处于填充
 */
- (BOOL)hasAlpha;

/**
 *  移除透明填充
 */
- (UIImage *)removeAlpha;

/**
 *  白色透明填充
 */
- (UIImage *)fillAlpha;


/**
 *  用给定的颜色填充透明度
 *
 *  @param color 填充颜色
 *
 *  @return 返回填充好的图像
 */
- (UIImage *)fillAlphaWithColor:(UIColor *)color;

/**
 *  检查是否图像处于灰度
 */
- (BOOL)isGrayscale;

/**
 *  转换为灰度图像
 */
- (UIImage *)imageToGrayscale;

/**
 *  转换为黑白图像
 *
 *  @return 返回转换后的图像
 */
- (UIImage *)imageToBlackAndWhite;

/**
 *  反转图像颜色
 *
 *  @return 返回转换后的图像
 */
- (UIImage *)invertColors;


/**
 *  对图像应用绽放效果
 *
 *  @param radius    绽放半径
 *  @param intensity 绽放强度
 *
 *  @return 返回转换后的图像
 */
- (UIImage *)bloom:(float)radius
         intensity:(float)intensity;

/**
 *  图像模糊效果
 *
 *  @param blur 虚化半径
 *
 *  @return 返回转换后的图像
 */
- (UIImage *)boxBlurImageWithBlur:(CGFloat)blur;

/**
 *  通过颜色值创建一个图像
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;


/**
 图像模糊效果
 */
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

/**
 *  图像模糊效果
 *
 *  @param blurRadius 虚化半径
 *  @param tintColor  虚化颜色
 *  @param saturationDeltaFactor 饱和度
 *  @param maskImage  遮盖图片
 *
 *  @return 返回转换后的图像
 */
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;


@end
