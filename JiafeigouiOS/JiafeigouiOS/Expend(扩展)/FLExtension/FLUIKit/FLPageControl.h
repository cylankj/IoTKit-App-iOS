//
//  FLPageControl.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPageControl : UIPageControl

@property (nonatomic, strong) UIImage *imagePageStateNormal;
@property (nonatomic, strong) UIImage *imagePageStateHighlighted;

/**
 *  设置pageIndicator之间的距离
 */
@property (nonatomic, assign) NSInteger pageIndicatorSpacing;

/**
 *  设置page总数与当前显示page
 */
- (void)setTotalAndCurrentPageNumber:(NSInteger)totalPageNumber
                   currentPageNumber:(NSInteger)currentPageNumber;

/**
 *  设置图片
 */
- (void)setImageOfPageNormalAndHighlighted:(UIImage *)normalImage
                          highlightedImage:(UIImage *)highlightedImage;

/**
 *  设置颜色
 */
- (void)setColorOfBackgroundAndCurrentPageIndicator:(UIColor *)colorOfBackground
                        colorOfCurrentPageIndicator:(UIColor *)colorOfCurrentPageIndicator;



@end
