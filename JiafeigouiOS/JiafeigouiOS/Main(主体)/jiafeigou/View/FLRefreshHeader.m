//
//  FLRefreshHeader.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FLRefreshHeader.h"
#import "PopAnimation.h"

@interface FLRefreshHeader()
{
    int angle;
    BOOL endAnimation;
}
@property(nonatomic,strong)UIImageView *loadImageView;
/** 父类scrollView */
@property (nonatomic,strong)UIScrollView *scrollView;
/** 回调对象 */
@property (weak, nonatomic) id refreshingTarget;
/** 回调方法 */
@property (assign, nonatomic) SEL refreshingAction;
@end

@implementation FLRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self prepare];
      // 默认是普通状态
        self.state = FLRefreshStateNormal;
        self.dragHeight = 30;
    }
    return self;
}

- (void)prepare
{
    // 基本属性
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    self.loadImageView.bounds = CGRectMake(0, 0, 23, 23);
    _loadImageView.x = self.x;
    self.loadImageView.top = 0;
    self.loadImageView.alpha = 0;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    // 如果不是UIScrollView，不做任何事情
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    // 旧的父控件移除监听
    [self removeObservers];
    
    if (newSuperview) { // 新的父控件
        // 设置宽度
        self.width = newSuperview.width;
        // 设置位置
        self.left = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        
        // 添加监听
        [self addObservers];
    }

}

#pragma mark - KVO监听
- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:FLRefreshKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers
{
    [self.superview removeObserver:self forKeyPath:FLRefreshKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:FLRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{

    if (self.state == FLRefreshStateRefreshing){
        return;
    }
    
    if (fabs(_scrollView.contentOffset.y)<=fabs(_originOffset_y)) {
        self.state = FLRefreshStateNormal;
    }else{
        self.state = FLRefreshStatePulling;
    }
    
    if (self.showType == FLRefreshShowTypeGradually) {
        //渐显
        if (_scrollView.contentOffset.y<0 && fabs(_scrollView.contentOffset.y)>=fabs(_originOffset_y)) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.loadImageView.alpha = (fabs(_scrollView.contentOffset.y) - fabs(_originOffset_y))/_dragHeight;
                CGAffineTransform endAngle = CGAffineTransformMakeRotation(-self.loadImageView.alpha*150 * (M_PI / 180.0f));
                self.loadImageView.transform = endAngle;
            }];
        }
    }else{
        
        //设计要求突然出现,而不是渐渐出现
        if (_scrollView.contentOffset.y<0 && fabs(_scrollView.contentOffset.y)>=fabs(_originOffset_y+_dragHeight)) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.loadImageView.alpha = 1;
                CGAffineTransform endAngle = CGAffineTransformMakeRotation(-(fabs(_scrollView.contentOffset.y) - fabs(_originOffset_y))/_dragHeight*150 * (M_PI / 180.0f));
                self.loadImageView.transform = endAngle;
            }];
        }else{
            //不加上else会出现在临界值周围显示出来,却没有刷新
            [UIView animateWithDuration:0.3 animations:^{
                self.loadImageView.alpha = 0;
                CGAffineTransform endAngle = CGAffineTransformMakeRotation(-(fabs(_scrollView.contentOffset.y) - fabs(_originOffset_y))/_dragHeight*150 * (M_PI / 180.0f));
                self.loadImageView.transform = endAngle;
            }];
        }
        
    }
    
    
    
}

-(void)scrollViewDidEndDrag:(UIScrollView *)scroller
{
    if (fabs(scroller.contentOffset.y)>=fabs(_originOffset_y)+_dragHeight && scroller.contentOffset.y<0) {
        [self startRefresh];
    }
    else
    {
        //有时候这个方法不会实时调用导致圆圈出现了却没开始刷新
        //self.loadImageView.alpha = 0;
    }

}
-(void)startRefresh
{
    if (self.hidden) {
        return;
    }
    if (self.state == FLRefreshStateRefreshing) {
        return;
    }
    self.state = FLRefreshStateRefreshing;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.loadImageView.alpha = 1;
            if (self.showType == FLRefreshShowTypeHolding) {
                CGFloat offsetY = MAX(self.scrollView.contentOffset.y * -1, 0);
                UIEdgeInsets set = self.scrollView.contentInset;
                [self.scrollView setContentInset:UIEdgeInsetsMake(MIN(offsetY, 70), set.left, set.bottom, set.right)];
                [self.scrollView setContentOffset:CGPointMake(0, -offsetY)];
            }
        } completion:NULL];
    endAnimation = NO;
    angle = 0;
    //开始动画
    [self startAnimation];
    
    //事件回调
    if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
        [self.refreshingTarget performSelectorOnMainThread:self.refreshingAction withObject:nil waitUntilDone:NO];
    }
}

-(void)endRefresh
{
    self.state = FLRefreshStateNormal;
    [UIView animateWithDuration:0.3 animations:^{
        self.loadImageView.alpha = 0;
        if (self.showType == FLRefreshShowTypeHolding) {
            UIEdgeInsets set = self.scrollView.contentInset;
            [self.scrollView setContentInset:UIEdgeInsetsMake(self.originalTopInset, set.left, set.bottom, set.right)];
        }
    } completion:^(BOOL finished) {
        [self stopAnimation];
    }];
    
}

/** 设置回调对象和回调方法 */
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action
{
    self.refreshingTarget = target;
    self.refreshingAction = action;
}

-(UIImageView *)loadImageView
{
    if (!_loadImageView) {
        _loadImageView = [[UIImageView alloc]init];
        _loadImageView.image = [UIImage imageNamed:@"loading"];
        [self addSubview:_loadImageView];
    }
    return _loadImageView;
}


- (void)startAnimation
{
//    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
//    
//    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        self.loadImageView.transform = endAngle;
//    } completion:^(BOOL finished) {
//        if (endAnimation) {
//            [UIView animateWithDuration:0.3 animations:^{
//                self.loadImageView.alpha = 0;
//                
//            } completion:^(BOOL finished) {
//                
//                self.loadImageView.transform = CGAffineTransformIdentity;
//                endAnimation = NO;
//                
//            }];
//            return ;
//        }
//        angle += 10; [self startAnimation];
//    }];
    
    [PopAnimation startRotationAnimationForView:self.loadImageView];
}

-(void)stopAnimation
{
    //endAnimation = YES;
    [PopAnimation stopRotationAnimationForView:self.loadImageView];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.loadImageView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.loadImageView.transform = CGAffineTransformIdentity;
        endAnimation = NO;
        
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
