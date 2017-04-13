//
//  FLTipsBaseView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FLTipsBaseView.h"

@implementation FLTipsBaseView
{
    NSMutableArray *tipViews;
    NSInteger tipIndex;
}

+(FLTipsBaseView *)tipBaseView
{
    FLTipsBaseView *tip = [[FLTipsBaseView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    return tip;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self prepare];
    return self;
}

-(void)prepare
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.userInteractionEnabled = YES;
    tipViews = [[NSMutableArray alloc]init];
    
}

-(void)addTipView:(UIView *)view
{
    if (view) {
        [tipViews addObject:view];
    }
}

-(void)didMoveToWindow:(UIWindow *)newWindow
{
    
}

-(void)didMoveToWindow
{
    tipIndex = 0;
    if (tipViews.count>tipIndex) {
        [self addSubview:tipViews[tipIndex]];
        tipIndex++;
    }
}

-(void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        self.alpha = 0;
        [keyWindow addSubview:self];
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = 1;
        }];
    }
}

+(void)dismissAll
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    NSArray *viewList = keyWindow.subviews;
    for (UIView *v in viewList) {
        
        if ([v isKindOfClass:[FLTipsBaseView class]]) {
            [v removeFromSuperview];
        }
        
    }
}

-(void)dismiss
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (tipViews.count>tipIndex) {
        UIView *lastView = [self.subviews lastObject];
        if (lastView) {
            [UIView animateWithDuration:0.3 animations:^{
                lastView.alpha = 0;
            } completion:^(BOOL finished) {
                [lastView removeFromSuperview];
                UIView *tipview = tipViews[tipIndex];
                tipview.alpha = 0;
                [self addSubview:tipview];
                [UIView animateWithDuration:0.3 animations:^{
                    tipview.alpha = 1;
                } completion:^(BOOL finished) {
                    tipIndex ++;
                }];
            }];
        }
    }else{
        [self dismiss];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
