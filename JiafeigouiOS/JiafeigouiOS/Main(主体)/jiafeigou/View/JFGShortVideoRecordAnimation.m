//
//  JFGShortVideoRecordAnimation.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGShortVideoRecordAnimation.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"

@interface JFGShortVideoRecordAnimation()
{
    UIView *animationView;
    NSTimer *_timer;
    int timerCount;
    CGFloat cutWidth;
}
@end

@implementation JFGShortVideoRecordAnimation

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initView];
    return self;
}

-(void)initView
{
    cutWidth = self.width / 40;
    animationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 3)];
    animationView.backgroundColor = [UIColor colorWithHexString:@"#36bdff"];
    animationView.layer.masksToBounds = YES;
    animationView.layer.cornerRadius = 1;
    [self addSubview:animationView];
}

-(void)startAnimation
{
    timerCount = 40;
    animationView.width = self.width;
    animationView.left = 0;
    [self stopAnimation];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)stopAnimation
{
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
}

-(void)timerAction
{
    timerCount --;
    [UIView animateWithDuration:0.2 animations:^{
        if (animationView.width == 0) {
            return ;
        }
        animationView.width = cutWidth * timerCount;
        animationView.x = self.width * 0.5;
    }];
    if (timerCount == 0) {
        [self stopAnimation];
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
