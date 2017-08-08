//
//  BindProgressAnimationView.m
//  HeaderRotation
//
//  Created by 杨利 on 16/6/16.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "BindProgressAnimationView.h"
#import <POP.h>
#import "UIColor+FLExtension.h"
#import "UIView+FLExtensionForFrame.h"
#import "SetDevNicNameViewController.h"
#import "JfgLanguage.h"
@implementation BindProgressAnimationView
{
    UIImageView *loadingImageView;
    UILabel *progressLabel;
    UILabel *tipLabel;
    UIButton *resetButton;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    CGFloat size = 250;
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, size, size)];
    [self initView];
    return self;
}

-(void)initView
{
    loadingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    loadingImageView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    loadingImageView.image = [UIImage imageNamed:@"add_login_loading-1"];
    [self addSubview:loadingImageView];
    
    progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    progressLabel.font = [UIFont systemFontOfSize:49];
    progressLabel.center = loadingImageView.center;
    progressLabel.textColor = [UIColor colorWithHexString:@"#36bdff"];
    progressLabel.text = @"0%";
    progressLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:progressLabel];
    
    [self bringSubviewToFront:loadingImageView];
    
    
    tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 72, self.bounds.size.width, 22)];
    tipLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_NETWORK_2"];
    tipLabel.font = [UIFont systemFontOfSize:22];
    tipLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    tipLabel.alpha = 0;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipLabel];
    
    resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.frame = CGRectMake(0, tipLabel.bottom+40, 180, 44);
    resetButton.center = CGPointMake(tipLabel.x, resetButton.y);
    resetButton.layer.masksToBounds = YES;
    resetButton.layer.cornerRadius = 22;
    resetButton.layer.borderColor = [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
    resetButton.layer.borderWidth = 1;
    [resetButton setTitle:[JfgLanguage getLanTextStrByKey:@"TRY_AGAIN"] forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:18];
    resetButton.alpha = 0;
    [self addSubview:resetButton];
    
}

-(void)reset
{
    [UIView animateWithDuration:0.5 animations:^{
        tipLabel.alpha = 0;
        resetButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            loadingImageView.alpha = 1;
            progressLabel.alpha = 1;
        } completion:^(BOOL finished) {
            [self starAnimation];
        }];
    }];
    
    if (self.bindResetBlock) {
        self.bindResetBlock();
    }
}

-(void)starAnimation
{
    //[self startRotationAnimation];
    
    [self progressAnimationWithStartProgress:0 stopProgress:50 duration:15 completionBlock:^{
       [self progressAnimationWithStartProgress:50 stopProgress:90 duration:45 completionBlock:^{
       }];
    }];
}


-(void)progressAnimationWithStartProgress:(int)startProgress
                             stopProgress:(int)stopProgress
                                 duration:(CGFloat)duration
                          completionBlock:(void(^)(void))completionBlock
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"countdown" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            UILabel *lable = (UILabel*)obj;
            lable.text = [NSString stringWithFormat:@"%d%%",(int)values[0]];
        };
        prop.threshold = 0.01f;
    }];
    POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];   //秒表当然必须是线性的时间函数
    anBasic.property = prop;    //自定义属性
    anBasic.fromValue = @(startProgress);
    anBasic.toValue = @(stopProgress);
    anBasic.duration = duration;    //持续时间
    anBasic.completionBlock = ^(POPAnimation *anim, BOOL finished){
        
        if (completionBlock) {
            completionBlock();
        }
        
    };
    [progressLabel pop_addAnimation:anBasic forKey:@"countdown"];
}

-(void)failedAnimation
{
    //[self stopRotationAnimation];
    [progressLabel pop_removeAllAnimations];
    [progressLabel pop_removeAnimationForKey:@"countdown"];
    
    [UIView animateWithDuration:0.5 animations:^{
        loadingImageView.alpha = 0;
        progressLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
        progressLabel.text= @"0%";
        loadingImageView.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.5 animations:^{
            tipLabel.alpha = 1;
            resetButton.alpha = 1;
        }];
    }];
}

-(void)successAnimationWithCompletionBlock:(void(^)(void))completionBlock
{
    [progressLabel pop_removeAllAnimations];
    [progressLabel pop_removeAnimationForKey:@"countdown"];
    
    int currentProgress = [progressLabel.text intValue];
    int s = 100 - currentProgress;
    CGFloat duration ;
    if (s<40) {
        duration = 1;
    }else if (s<70){
        duration = 2;
    }else{
        duration = 3;
    }
 
    [self progressAnimationWithStartProgress:currentProgress stopProgress:100 duration:duration completionBlock:^{
        [self stopRotationAnimation];
        if (completionBlock) {
            completionBlock();
        }
    }];
}


-(void)startRotationAnimation
{
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 25;
    //开始角度
    baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    [loadingImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopRotationAnimation
{
    [loadingImageView.layer pop_removeAnimationForKey:@"rotation"];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
