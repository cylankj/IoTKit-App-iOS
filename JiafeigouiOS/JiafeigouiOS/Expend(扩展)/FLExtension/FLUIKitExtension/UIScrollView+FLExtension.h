//
//  UIScrollView+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (FLExtension)
+ (UIScrollView *)initWithFrame:(CGRect)frame
                    contentSize:(CGSize)contentSize
                  clipsToBounds:(BOOL)clipsToBounds
                  pagingEnabled:(BOOL)pagingEnabled
           showScrollIndicators:(BOOL)showScrollIndicators
                       delegate:(id<UIScrollViewDelegate>)delegate;
@end
