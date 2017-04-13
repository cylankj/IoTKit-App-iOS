
//
//  DelayVideoMakingAnimationView.m
//  HeaderRotation
//
//  Created by 杨利 on 16/7/1.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "DelayVideoMakingAnimationView.h"
#import <POP.h>
#import "UIView+FLExtensionForFrame.h"

@interface DelayVideoMakingAnimationView()

@property (nonatomic,strong)UIImageView *loadingImageView;
@property (nonatomic,strong)UILabel *progressLabel;

@end

@implementation DelayVideoMakingAnimationView

-(void)didMoveToSuperview
{
    [self addSubview:self.loadingImageView];
    [self addSubview:self.progressLabel];
    self.progress = 0;
    [self startRotationAnimation];
}


-(void)setProgress:(CGFloat)progress
{
    if (progress>1 || progress <0) {
        return;
    }
    CGFloat p = progress*100;
    NSString *t = [NSString stringWithFormat:@"%.f",p];
    self.progressLabel.text = t;
    _progress = progress;
}


-(void)startRotationAnimation
{
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 30;
    //开始角度
    baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    [self.loadingImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopRotationAnimation
{
    [self.loadingImageView.layer pop_removeAnimationForKey:@"rotation"];
}

-(UIImageView *)loadingImageView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 62, 62)];
        _loadingImageView.center = CGPointMake(self.width*0.5, self.height*0.5);
        _loadingImageView.image = [UIImage imageNamed:@"delay_login_loading"];
    }
    return _loadingImageView;
}

-(UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        _progressLabel.center= self.loadingImageView.center;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.textColor = [UIColor whiteColor];
        _progressLabel.backgroundColor = [UIColor clearColor];
        _progressLabel.font = [UIFont systemFontOfSize:22];
    }
    return _progressLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
