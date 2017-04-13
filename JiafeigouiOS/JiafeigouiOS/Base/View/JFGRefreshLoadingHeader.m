//
//  JFGRefreshLoadingHeader.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/16.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGRefreshLoadingHeader.h"
#import "PopAnimation.h"

@interface JFGRefreshLoadingHeader()

@property (nonatomic,strong)UIImageView *loadImageView;

@end

@implementation JFGRefreshLoadingHeader


#pragma mark - 懒加载
-(UIImageView *)loadImageView
{
    if (!_loadImageView) {
        _loadImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loading-gray"]];
        
    }
    return _loadImageView;
}

-(void)prepare
{
    [super prepare];
    [self addSubview:self.loadImageView];
}

-(void)placeSubviews
{
    [super placeSubviews];
    if (self.loadImageView.mj_x == 0) {
        self.loadImageView.mj_x = (self.mj_w-_loadImageView.mj_w)*0.5;
        self.loadImageView.mj_y = (self.mj_h-_loadImageView.mj_h)*0.5;
    }
}

-(void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    if (state == MJRefreshStateIdle) {
        [self stopAnimation];
        [UIView animateWithDuration:0.3 animations:^{
            self.loadImageView.transform = CGAffineTransformIdentity;
        }];
    }else if (state == MJRefreshStatePulling){
        
    }else if (state == MJRefreshStateRefreshing){
        [self startAnimation];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];

    if (self.state == MJRefreshStatePulling ){
        CGPoint point = [change[@"new"] CGPointValue];
        CGFloat offset_y = fabsf(point.y)- MJRefreshHeaderHeight;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGAffineTransform endAngle = CGAffineTransformMakeRotation(offset_y * (M_PI/80));
            self.loadImageView.transform = endAngle;
        }];
    }
}


- (void)startAnimation
{
    [PopAnimation startRotationAnimationForView:self.loadImageView];
}

-(void)stopAnimation
{
    [PopAnimation stopRotationAnimationForView:self.loadImageView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
