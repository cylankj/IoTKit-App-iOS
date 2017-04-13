//
//  UIWindow+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (FLExtension)

+(UIWindow *)keyWinsow;

/**
 *屏幕截图
 */
- (UIImage *)takeScreenshot;

@end
