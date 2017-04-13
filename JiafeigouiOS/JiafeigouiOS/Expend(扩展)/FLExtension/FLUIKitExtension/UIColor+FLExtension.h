//
//  UIColor+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  通过RGBA创建颜色
 */
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/**
 *  通过RGB创建颜色
 */
#define RGB(r, g, b) RGBA(r, g, b, 1.0f)


@interface UIColor (FLExtension)

/**
 *  通过 16进制字符串 创建颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

/**
 *  通过 16进制无符号整型 创建颜色
 */

+ (UIColor *)colorWithHex:(unsigned int)hex;

/**
 *  通过 16进制无符号整型 与 透明度 创建颜色
 */
+ (UIColor *)colorWithHex:(unsigned int)hex
                    alpha:(float)alpha;

/**
 *  创建一个随机颜色
 */
+ (UIColor *)randomColor;

/**
 *  通过其他颜色的色值与透明度获取新色值
 */
+ (UIColor *)colorWithColor:(UIColor *)color
                      alpha:(float)alpha;

@end
