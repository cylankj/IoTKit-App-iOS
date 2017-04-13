//
//  UIButton+FLExtentsion.m
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "UIButton+FLExtentsion.h"
#import "UIImage+FLExtension.h"
#import "UIColor+FLExtension.h"
#import <objc/runtime.h>


static const void *FLUIButtonBlockForTouchUpInsideKey = &FLUIButtonBlockForTouchUpInsideKey;

@interface UIButton()

@property (nonatomic,copy,setter=bk_setHanderForTouchUpInside:)void(^bk_handerForTouchUpInside)(UIButton *button);

@end

@implementation UIButton (FLExtentsion)

+ (id)initWithFrame:(CGRect)frame
{
    return [UIButton initWithFrame:frame title:nil];
}

+ (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    return [UIButton initWithFrame:frame title:title backgroundImage:nil];
}

+ (id)initWithFrame:(CGRect)frame title:(NSString *)title backgroundImage:(UIImage *)backgroundImage
{
    return [UIButton initWithFrame:frame title:title backgroundImage:backgroundImage highlightedBackgroundImage:nil];
}

+ (id)initWithFrame:(CGRect)frame title:(NSString *)title backgroundImage:(UIImage *)backgroundImage highlightedBackgroundImage:(UIImage *)highlightedBackgroundImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    return button;
}

+ (id)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    return [UIButton initWithFrame:frame title:title backgroundImage:[UIImage imageWithColor:color] highlightedBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:components[0]-0.1 green:components[1]-0.1 blue:components[2]-0.1 alpha:1]] ];
}

+ (id)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color highlightedColor:(UIColor *)highlightedColor
{
    return [UIButton initWithFrame:frame title:title backgroundImage:[UIImage imageWithColor:color] highlightedBackgroundImage:[UIImage imageWithColor:highlightedColor]];
}



+ (id)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [UIButton initWithFrame:frame title:nil backgroundImage:[UIImage imageWithColor:color] highlightedBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:components[0]-0.1 green:components[1]-0.1 blue:components[2]-0.1 alpha:1]]];
}

+ (id)initWithFrame:(CGRect)frame color:(UIColor *)color highlightedColor:(UIColor *)highlightedColor
{
    return [UIButton initWithFrame:frame title:nil backgroundImage:[UIImage imageWithColor:color] highlightedBackgroundImage:[UIImage imageWithColor:highlightedColor]];
}



+ (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    return [UIButton initWithFrame:frame image:image highlightedImage:nil];
}

+ (id)initWithFrame:(CGRect)frame image:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setTitleFont:(FontName)fontName size:(CGFloat)size
{
    [self.titleLabel setFont:[UIFont fontForFontName:fontName size:size]];
}

- (void)setTitleColor:(UIColor *)color
{
    [self setTitleColor:color highlightedColor:[UIColor colorWithColor:color alpha:0.4]];
}


- (void)setTitleColor:(UIColor *)color highlightedColor:(UIColor *)highlightedColor
{
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:highlightedColor forState:UIControlStateHighlighted];
}

-(void)setCornerRadius:(CGFloat)radius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
}

#pragma mark

+(id)initWithFrame:(CGRect)frame
             image:(UIImage *)image
  highlightedImage:(UIImage *)highlightedImage
      cornerRadius:(CGFloat)radius
handerForTouchUpInside:(void(^)(UIButton *button))hander
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button setCornerRadius:radius];
    [button bk_initWihtHanderForTouchUpInside:^(UIButton *button) {
        if (hander) {
            hander(button);
        }
    }];
    return button;
}


+(id)initWithFrame:(CGRect)frame
   backgroundImage:(UIImage *)image
  highlightedImage:(UIImage *)highlightedImage
             title:(NSString *)title
              font:(UIFont *)font
        titleColor:(UIColor *)color
      cornerRadius:(CGFloat)radius
handerForTouchUpInside:(void(^)(UIButton *button))hander
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font = font;
    [button setCornerRadius:radius];
    [button bk_initWihtHanderForTouchUpInside:^(UIButton *button) {
        if (hander) {
            hander(button);
        }
    }];
    return button;
}

+(id)initWithFrame:(CGRect)frame
   backgroundColor:(UIColor *)Color
  highlightedColor:(UIColor *)highlightedColor
             title:(NSString *)title
              font:(UIFont *)font
        titleColor:(UIColor *)titleColor
      cornerRadius:(CGFloat)radius
handerForTouchUpInside:(void(^)(UIButton *button))hander
{
    
    UIImage *image = [UIImage imageWithColor:Color size:frame.size];
    UIImage *highlightedImage = [UIImage imageWithColor:highlightedColor size:frame.size];

    UIButton *button = [UIButton initWithFrame:frame backgroundImage:image highlightedImage:highlightedImage title:title font:font titleColor:titleColor cornerRadius:radius handerForTouchUpInside:^(UIButton *button) {
        if (hander) {
            hander(button);
        }
        
    }];
    return button;
}

-(void)bk_initWihtHanderForTouchUpInside:(void(^)(UIButton *button))hander
{
    if (!self) {
        return;
    }
    [self addTarget:self action:@selector(bk_handerForTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
    self.bk_handerForTouchUpInside = hander;
}

-(void)bk_handerForTouchUpInsideAction:(UIButton *)button
{
    void (^hander)(UIButton *button) = self.bk_handerForTouchUpInside;
    if (!hander) {
        return;
    }
    hander(button);
}

-(void)bk_setHanderForTouchUpInside:(void(^)(UIButton *button))hander
{
    objc_setAssociatedObject(self, FLUIButtonBlockForTouchUpInsideKey, hander, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

-(void(^)(UIButton *button))bk_handerForTouchUpInside
{
      return objc_getAssociatedObject(self, FLUIButtonBlockForTouchUpInsideKey);
}

@end
