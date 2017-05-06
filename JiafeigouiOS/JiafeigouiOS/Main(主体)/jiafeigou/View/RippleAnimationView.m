//
//  RippleAnimationView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "RippleAnimationView.h"
#import "UIView+FLExtensionForFrame.h"
#import "FLGlobal.h"

static CGFloat defaultPicWidth = 500;

@implementation RippleAnimationView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.speed1 = 2;
    self.speed2 = 1;
    self.speed3 = 5;
    return self;
}

-(void)didMoveToSuperview
{
    CGFloat height = ceil(kheight*0.09);
    CGFloat ripple1Height = 75*0.5;
    CGFloat ripple2Height = 90*0.5;
    CGFloat ripple3Height = 117*0.5;
    
    if (height < ripple3Height) {
        
        CGFloat scale = height/ripple3Height;
        ripple3Height = height;
        ripple1Height = ceilf(scale*ripple1Height);
        ripple2Height = ceilf(scale*ripple2Height);
        
    }
    
    
    [self scrollerAddContentImageNamed:self.topImage scrollerView:self.scrollerView1 height:ripple1Height];
    [self addSubview:self.scrollerView1];
    
    //反向的
    [self scrollerAddContentImageNamed:self.centerImage scrollerView:self.scrollerView3 height:ripple3Height];
    [self.scrollerView3 setContentOffset:CGPointMake(self.scrollerView3.contentSize.width-self.bounds.size.width, 0)];
    [self addSubview:self.scrollerView3];
    
    [self scrollerAddContentImageNamed:self.bottomImage scrollerView:self.scrollerView2 height:ripple2Height];
    [self addSubview:self.scrollerView2];
    
    [self startTimer];
}

-(void)willRemoveSubview:(UIView *)subview
{
    if (animationTimer && animationTimer.isValid) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
}

-(void)startTimer
{
    if (!animationTimer || !animationTimer.isValid)
    {
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer
{
    if (animationTimer && animationTimer.isValid) {
        [animationTimer invalidate];
    }
}

-(void)timerAction
{
    [self scrollView:self.scrollerView1 speed:self.speed1 direction:YES];
    [self scrollView:self.scrollerView2 speed:self.speed2 direction:YES];
    [self scrollView:self.scrollerView3 speed:self.speed3 direction:NO];
}


//滚动调节
-(void)scrollView:(UIScrollView *)scrollerView speed:(CGFloat )speed direction:(BOOL)direction
{
    CGFloat offset_x = scrollerView.contentOffset.x;
    if (direction) {
        //正向移动（向左）
        
        if (offset_x>=defaultPicWidth*2) {
            [scrollerView setContentOffset:CGPointMake(0, 0) animated:NO];
            offset_x = scrollerView.contentOffset.x;
        }
        [scrollerView setContentOffset:CGPointMake(offset_x+speed, 0) animated:YES];
        
    }else{
        
        
        if (scrollerView.contentSize.width-offset_x>=2*defaultPicWidth+self.bounds.size.width) {
            [scrollerView setContentOffset:CGPointMake(scrollerView.contentSize.width-self.bounds.size.width, 0) animated:NO];
            offset_x = scrollerView.contentOffset.x;
        }
        [scrollerView setContentOffset:CGPointMake(offset_x-speed, 0) animated:YES];
        
    }
}



-(UIScrollView *)scrollerView1
{
    if (!_scrollerView1) {
        _scrollerView1  = [self factoryScroller];
    }
    return _scrollerView1;
}
-(UIScrollView *)scrollerView2
{
    if (!_scrollerView2) {
        _scrollerView2  = [self factoryScroller];
    }
    return _scrollerView2;
}
-(UIScrollView *)scrollerView3
{
    if (!_scrollerView3) {
        _scrollerView3  = [self factoryScroller];
    }
    return _scrollerView3;
}

-(UIScrollView *)factoryScroller
{
    UIScrollView * scrollerView  =[[UIScrollView alloc]initWithFrame:self.bounds];
    scrollerView.contentSize = CGSizeMake(defaultPicWidth*3, 55);
    scrollerView.scrollEnabled = NO;
    scrollerView.backgroundColor = [UIColor clearColor];
    return scrollerView;
}

-(void)scrollerAddContentImageNamed:(NSString *)imageNamed scrollerView:(UIScrollView *)scrollerView height:(CGFloat)rippleHeight
{
    
    CGFloat height = ceil(kheight*0.09);
    UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, height-rippleHeight, defaultPicWidth, rippleHeight)];
    imageView1.image = [UIImage imageNamed:imageNamed];
    [scrollerView addSubview:imageView1];
    
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(defaultPicWidth, height-rippleHeight, defaultPicWidth, rippleHeight)];
    imageView2.image = [UIImage imageNamed:imageNamed];
    //imageView2.transform = CGAffineTransformMakeScale(-1, 1);
    [scrollerView addSubview:imageView2];
    
    UIImageView *imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(defaultPicWidth*2, height-rippleHeight, defaultPicWidth, rippleHeight)];
    imageView3.image = [UIImage imageNamed:imageNamed];;
    [scrollerView addSubview:imageView3];
    
    //如果图片宽度小于屏幕宽度，使用四张图片
    if (self.bounds.size.width>defaultPicWidth) {
        
        [scrollerView setContentSize:CGSizeMake(defaultPicWidth*4, height)];
        
        UIImageView *imageView4 = [[UIImageView alloc]initWithFrame:CGRectMake(defaultPicWidth*3, height-rippleHeight, defaultPicWidth, rippleHeight)];
        imageView4.image = [UIImage imageNamed:imageNamed];
        //imageView4.transform = CGAffineTransformMakeScale(-1, 1);
        [scrollerView addSubview:imageView4];
        
    }
}

- (NSString *)topImage
{
    if (_topImage == nil)
    {
        _topImage = @"image_scroll_ripple1";
    }
    return _topImage;
}

- (NSString *)bottomImage
{
    if (_bottomImage == nil)
    {
        _bottomImage = @"image_scroll_ripple2";
    }
    return _bottomImage;
}

- (NSString *)centerImage
{
    if (_centerImage == nil)
    {
        _centerImage = @"image_scroll_ripple3";
    }
    return _centerImage;
}
@end
