

//
//  JFGTimepieceView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGTimepieceView.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "XTimer.h"

@interface JFGTimepieceView()
{
    NSTimer *_timer;
    int hour;
    int min;
    int sec;
    UILabel *_label;
}
@end

@implementation JFGTimepieceView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    hour = 0;
    min = 0;
    sec = 0;
    [self initView];
    return self;
}

-(void)initView
{
    UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
    redView.y = self.bounds.size.height*0.5;
    redView.backgroundColor = [UIColor colorWithHexString:@"#ff3b30"];
    redView.layer.masksToBounds = YES;
    redView.layer.cornerRadius = 4;
    [self addSubview:redView];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(redView.right+9, 0, self.width-(redView.right+9), self.height)];
    _label.font = [UIFont systemFontOfSize:16];
    _label.textColor = [UIColor whiteColor];
    _label.text = @"00:00:00";
    [self addSubview:_label];
}

-(void)startTimerForHour:(int)_hour min:(int)_min sec:(int)_sec
{
    hour = _hour;
    min = _min;
    sec = _sec;
    [self startTimer];
}

-(void)startTimer
{
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)timerAction
{
    sec++;
    if (sec>=60) {
        min++ ;
        sec = 0;
    }
    if (min >= 60) {
        hour++;
        min = 0;
    }
    _label.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,min,sec];
    NSLog(@"JFGTimepieceView_timer:%@",_label.text);
}

-(void)stopTimer
{
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    hour = 0; min = 0; sec = 0;
    _label.text = [NSString stringWithFormat:@"%02d:%02d:%02d",0,0,0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
