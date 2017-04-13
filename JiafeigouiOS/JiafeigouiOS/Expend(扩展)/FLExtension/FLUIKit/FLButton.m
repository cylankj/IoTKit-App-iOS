//
//  FLButton.m
//  FLExtensionTask
//
//  Created by 紫贝壳 on 15/8/14.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "FLButton.h"
#import "UIImage+FLExtension.h"

@interface FLButton()

@property(strong, nonatomic) UIImageView *overlayImgView;
@property(nonatomic, assign) CGFloat fadeDuration;

@end

@implementation FLButton

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image highlightedImage:(UIImage *)highlightedImage fadeDuration:(CGFloat)fadeDuration
{
    if((self = [FLButton buttonWithType:UIButtonTypeCustom]))
    {
        self.frame = frame;
        
        self.fadeDuration = fadeDuration;
        
        [self setImage:image forState:UIControlStateNormal];
        self.overlayImgView = [[UIImageView alloc] initWithImage:highlightedImage];
        self.overlayImgView.frame = self.imageView.frame;
        self.overlayImgView.bounds = self.imageView.bounds;
        
        self.adjustsImageWhenHighlighted = NO;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color highlightedColor:(UIColor *)highlightedColor fadeDuration:(CGFloat)fadeDuration
{
    if((self = [FLButton buttonWithType:UIButtonTypeCustom]))
    {
        self.frame = frame;
        
        self.fadeDuration = fadeDuration;
        
        UIImage *image = [UIImage imageWithColor:color size:frame.size];
        UIImage *highlightedImage = [UIImage imageWithColor:highlightedColor size:frame.size];
        [self setImage:image forState:UIControlStateNormal];
        self.overlayImgView = [[UIImageView alloc] initWithImage:highlightedImage];
        self.overlayImgView.userInteractionEnabled = YES;
        self.overlayImgView.frame = self.imageView.frame;
        self.overlayImgView.bounds = self.imageView.bounds;
        
        self.adjustsImageWhenHighlighted = NO;
    }
    
    return self;
}


- (void)setHighlighted:(BOOL)highlighted
{
    if(![self isHighlighted] && highlighted)
    {
        [self addSubview:self.overlayImgView];
        
        [UIView animateWithDuration:self.fadeDuration animations:^{
            self.overlayImgView.alpha = 1;
        } completion:NULL];
    }
    else if([self isHighlighted] && !highlighted)
    {
        [UIView animateWithDuration:self.fadeDuration animations:^{
            self.overlayImgView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.overlayImgView removeFromSuperview];
        }];
    }
    
    [super setHighlighted:highlighted];
}

- (void)setOverlayImgView:(UIImageView *)overlayImgView
{
    if(overlayImgView != _overlayImgView)
    {
        _overlayImgView = overlayImgView;
    }
    
    self.overlayImgView.alpha = 0;
}


@end
