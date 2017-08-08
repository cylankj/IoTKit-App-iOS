//
//  MSRefreshAutoNormalFooter.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MSRefreshAutoNormalFooter.h"
#import <POP.h>
#import "UILabel+FLExtension.h"
#import "JfgLanguage.h"
#import "UIColor+HexColor.h"

@interface MSRefreshAutoNormalFooter()

@property (nonatomic,strong)UIImageView *loadingImageView;
@property (nonatomic,strong)UILabel *noMoreLabel;

@end

@implementation MSRefreshAutoNormalFooter

#pragma mark - 懒加载子控件

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    //self.loadingView = nil;
    [self setNeedsLayout];
}
#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    [self.stateLabel setTransform:CGAffineTransformMakeRotation(M_PI /2)];
    self.stateLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.stateLabel.verticalText = [JfgLanguage getLanTextStrByKey:@"Loaded"];
    self.stateLabel.font = [UIFont systemFontOfSize:13];
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    //if (self.loadingView.constraints.count) return;
    
    // 圈圈
    CGFloat loadingCenterX = self.mj_w * 0.5;
    if (!self.isRefreshingTitleHidden) {
        loadingCenterX -= self.stateLabel.mj_textWith * 0.5 + 20;
    }
    CGFloat loadingCenterY = self.mj_h * 0.5;
    self.loadingImageView.center = CGPointMake(loadingCenterX-55, loadingCenterY+5);
    self.stateLabel.verticalText = [JfgLanguage getLanTextStrByKey:@"Loaded"];
    CGSize size = [self.stateLabel sizeThatFits:CGSizeMake(320, 320)];
    self.stateLabel.mj_w = size.height;
    self.stateLabel.mj_x = (self.mj_w - self.stateLabel.mj_w)*0.25;
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        [self stopAnimating];
        self.loadingImageView.hidden = YES;
        self.stateLabel.hidden = YES;
    } else if (state == MJRefreshStateRefreshing) {
        [self startAnimating];
        self.stateLabel.hidden = YES;
        self.loadingImageView.hidden = NO;
    }else if(state == MJRefreshStateNoMoreData){
        [self stopAnimating];
        self.stateLabel.verticalText = [JfgLanguage getLanTextStrByKey:@"Loaded"];
        self.loadingImageView.hidden = YES;
        self.stateLabel.hidden = NO;
    }
}

-(void)startAnimating
{
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 25;
    //开始角度
    //baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(180);
    //是否永远循环执行
    baseAnimation.repeatForever = YES;
    //添加动画
    [self.loadingImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopAnimating
{
     [self.loadingImageView.layer pop_removeAnimationForKey:@"rotation"];
}

-(UIImageView *)loadingImageView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"doorbell_icon_loading_gray"]];
        _loadingImageView.userInteractionEnabled = YES;
        [self addSubview:_loadingImageView];
    }
    return _loadingImageView;
}

-(UILabel *)noMoreLabel
{
    if (!_noMoreLabel) {
        _noMoreLabel = [[UILabel alloc]init];
        _noMoreLabel.hidden = YES;
        _noMoreLabel.backgroundColor = [UIColor orangeColor];
        _noMoreLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        _noMoreLabel.font = [UIFont systemFontOfSize:13];
        _noMoreLabel.transform =CGAffineTransformMakeRotation(M_PI /2);
        _noMoreLabel.verticalText = [JfgLanguage getLanTextStrByKey:@"Loaded"];
        [self addSubview:_noMoreLabel];
    }
    return _noMoreLabel;
}

@end
