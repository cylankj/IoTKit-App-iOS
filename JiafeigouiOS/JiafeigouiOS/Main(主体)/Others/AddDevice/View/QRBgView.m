//
//  QRBgView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "QRBgView.h"
#import "UIColor+HexColor.h"
#import "FLGlobal.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"

@implementation QRBgView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

NSString * const qrAnimationKey = @"lineAnimatin";

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    
}

-(void)didMoveToSuperview
{
    [self initView];
}


- (void)initView
{
//    self.backgroundColor = [UIColor whiteColor];
    
    UIView *lineBgView = [[UIView alloc]initWithFrame:CGRectMake(2, 2, self.centerImageView.width-4, self.centerImageView.height-4)];
    lineBgView.backgroundColor = [UIColor clearColor];
    lineBgView.clipsToBounds = YES;
    [self.centerImageView addSubview:lineBgView];
    
    [lineBgView addSubview:self.lineImageView];
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomtView];
    [self addSubview:self.leftView];
    [self addSubview:self.rightView];
    [self addSubview:self.centerImageView];
    [self addSubview:self.describLabel];
    
    [self startQRAnimation];
}

#pragma mark -> animation
- (void)startQRAnimation
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.repeatCount = HUGE_VALF;
    animation.toValue = @(self.centerImageView.bottom);
    animation.duration = 3.0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.lineImageView.layer addAnimation:animation forKey:qrAnimationKey];
}


- (void)stopQRAnimation
{
    [self.lineImageView.layer removeAnimationForKey:qrAnimationKey];
}

#pragma mark setter
- (UIView *)topView
{
    CGFloat widgetWidth = self.width;
    CGFloat widgetHeight = self.centerImageView.top+2;
    CGFloat widgetX = 0;
    CGFloat widgetY = 0;
    
    if (_topView == nil)
    {
        UIView *tempView = [self factoryViewWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _topView = tempView;
    }
    
    return _topView;
}

- (UIView *)bottomtView
{
    CGFloat widgetWidth = self.width;
    CGFloat widgetHeight = self.height - self.centerImageView.bottom+2;
    CGFloat widgetX = 0;
    CGFloat widgetY = self.height - widgetHeight;
    
    if (_bottomtView == nil)
    {
        UIView *tempView = [self factoryViewWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _bottomtView = tempView;
    }
    return _bottomtView;
}

- (UIView *)leftView
{
    CGFloat widgetWidth = self.centerImageView.left+2;
    CGFloat widgetHeight = self.height - self.topView.bottom - self.bottomtView.height;
    CGFloat widgetX = 0;
    CGFloat widgetY = self.topView.bottom;
    
    if (_leftView == nil)
    {
        UIView *tempView = [self factoryViewWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _leftView = tempView;
    }
    
    return _leftView;
}

- (UIView *)rightView
{
    CGFloat widgetWidth = self.width - self.centerImageView.right+2;
    CGFloat widgetHeight = self.height - self.topView.bottom - self.bottomtView.height;
    CGFloat widgetX = self.centerImageView.right-2;
    CGFloat widgetY = self.topView.bottom;
    
    if (_rightView == nil)
    {
        UIView *tempView = [self factoryViewWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _rightView = tempView;
    }
    
    return _rightView;
}

- (UIImageView *)centerImageView
{
    CGFloat imgViewWidth = 210;
    CGFloat imgViewHeight = 210;
    CGFloat imgViewX = (self.width - imgViewWidth)/2.0;
    CGFloat imgViewY = (self.height - imgViewHeight - 82)/2.0;
    
    if (_centerImageView == nil)
    {
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imgViewX, imgViewY, imgViewWidth, imgViewHeight)];
        _centerImageView.image = [UIImage imageNamed:@"qr_center"];
        _centerImageView.clipsToBounds = YES;
    }
    
    return _centerImageView;
}

- (UILabel *)describLabel
{
    CGFloat widgetWidth = 220;
    CGFloat widgetHeight = 50;
    CGFloat widgetX = (self.width - widgetWidth)/2.0;
    CGFloat widgetY = self.centerImageView.bottom + 20;
    
    if (_describLabel == nil)
    {
        _describLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _describLabel.numberOfLines = 0;
        _describLabel.textAlignment = NSTextAlignmentCenter;
        _describLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _describLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_QRCODE_BOTTOM_TEXT"];
        _describLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    return _describLabel;
}

- (UIImageView *)lineImageView
{
    CGFloat widgetWidth = self.centerImageView.width-4;
    CGFloat widgetHeight = 90;
    CGFloat widgetX = 0;
    CGFloat widgetY = - widgetHeight;
    
    if (_lineImageView == nil)
    {
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _lineImageView.image = [UIImage imageNamed:@"qr_lineview"];
    }
    
    return _lineImageView;
}


- (UIView *)factoryViewWithFrame:(CGRect)frame
{
    UIView *retImageView = [[UIView alloc] initWithFrame:frame];
    retImageView.alpha = .5f;
    retImageView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    return retImageView;
}

-(UIActivityIndicatorView *)_indicatorView
{
    if (__indicatorView == nil) {
        
        __indicatorView =  [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        __indicatorView.center = CGPointMake(self.centerImageView.width*0.5, self.centerImageView.height*0.5-10);//只能设置中心，不能设置大小
    }
    return __indicatorView;
}

-(UILabel *)noteLabel
{
    if (_noteLabel == nil) {
        _noteLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self._indicatorView.bottom+10, self.centerImageView.width, 16)];
        _noteLabel.font = [UIFont systemFontOfSize:15];
        _noteLabel.textColor = [UIColor whiteColor];
        _noteLabel.text = [JfgLanguage getLanTextStrByKey:@"PLEASE_WAIT"];
        _noteLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noteLabel;
}

-(void)showLoading
{
    if (self._indicatorView.superview == nil) {
        [self.centerImageView addSubview:self._indicatorView];
    }
    if (self.noteLabel.superview == nil) {
        [self.centerImageView addSubview:self.noteLabel];
    }
    [self._indicatorView startAnimating];
}


-(void)stopLoading
{
    [self._indicatorView stopAnimating];
    [self._indicatorView removeFromSuperview];
    [self.noteLabel removeFromSuperview];
}

@end
