  //
//  DoorVideoSrollView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DoorVideoSrollView.h"
#import "JfgGlobal.h"

@interface DoorVideoSrollView()
{
    CGPoint contentOffset;
}
@end

@implementation DoorVideoSrollView


-(void)didMoveToSuperview
{
    self.delegate = self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    if (self.isFullScreen)
//    {
//        self.fullScreenButton.hidden = YES;
//        self.bottomShadeImageView.hidden = YES;
//        self.halfScreenButton.hidden = NO;
//        self.nickNameLabel.hidden = NO;
//        
//        [self bringSubviewToFront:self.halfScreenButton];
//        [self bringSubviewToFront:self.nickNameLabel];
//        
//        self.halfScreenButton.frame = CGRectMake(10, 10, self.halfScreenButton.width, self.halfScreenButton.height);
//        self.nickNameLabel.frame = CGRectMake(10 + self.halfScreenButton.width, 10, self.height, self.halfScreenButton.height);
//        
//        self.flowSpeedButton.frame = CGRectMake(self.height - 15 - self.flowSpeedButton.width, 15, self.flowSpeedButton.width, self.flowSpeedButton.height);
//        
//        self.shadeImageView.frame = CGRectMake(0, 0, self.height, 60);
//        
//        //scroller滚动，改变坐标使其相对静止
//        self.nickNameLabel.top = contentOffset.y+10;
//        self.halfScreenButton.top = contentOffset.y+10;
//        self.flowSpeedButton.top = contentOffset.y+15;
//        
//    }
//    else
//    {
//        self.fullScreenButton.hidden = NO;
//        self.bottomShadeImageView.hidden = NO;
////        self.halfScreenButton.hidden = YES;
//        self.nickNameLabel.hidden = YES;
//        
//        self.halfScreenButton.frame = CGRectMake(10, 34, self.halfScreenButton.width, self.halfScreenButton.height);
//        self.flowSpeedButton.frame = CGRectMake(self.width - 15 - self.flowSpeedButton.width,  20 + 15, self.flowSpeedButton.width, self.flowSpeedButton.height);
//        self.fullScreenButton.frame = CGRectMake(self.width - 12 - self.fullScreenButton.width, self.height - self.fullScreenButton.height, self.fullScreenButton.width, self.fullScreenButton.height);
//        self.shadeImageView.frame = CGRectMake(0, 0, self.width, 60);
//        self.bottomShadeImageView.frame = CGRectMake(0, self.height - self.bottomShadeImageView.height, self.width, self.bottomShadeImageView.height);
//    }
    
}

- (void)initView
{
//    [self addSubview:self.shadeImageView];
//    [self addSubview:self.bottomShadeImageView];
//    [self addSubview:self.fullScreenButton];
//    
//    [self addSubview:self.halfScreenButton];
//    [self addSubview:self.nickNameLabel];
//    [self addSubview:self.flowSpeedButton];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    contentOffset = scrollView.contentOffset;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (scrollView == self) {
        
        UIView *remoteView =[self viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        return remoteView;
    }
    return nil;
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
//    if (scrollView == self.videoPlayBgScrollerView) {
//        
//        self.snapeImageView.hidden = NO;
//        CGFloat ratio = 1.0;
//        CGFloat width = scrollView.contentSize.width;
//        ratio = remoteCallViewSize.height/remoteCallViewSize.width;
//        CGFloat height = width * ratio;
//        
//        UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
//        if (remoteView) {
//            
//            remoteView.frame = CGRectMake(0, 0, width, height);
//            [self.videoPlayBgScrollerView setContentSize:CGSizeMake(width, height)];
//        }
//        
//    }
    
    
}

#pragma mark property

//- (UIButton *)flowSpeedButton
//{
//    if (_flowSpeedButton == nil)
//    {
//        _flowSpeedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 22)];
//        [_flowSpeedButton setBackgroundImage:[UIImage imageNamed:@"door_flowspeed"] forState:UIControlStateNormal];
//        [_flowSpeedButton.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
//        [_flowSpeedButton setTitle:@"0K/s" forState:UIControlStateNormal];
//        [_flowSpeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    }
//    return _flowSpeedButton;
//}
//
//- (UIImageView *)shadeImageView
//{
//    if (_shadeImageView == nil)
//    {
//        _shadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 60)];
//        _shadeImageView.image = [UIImage imageNamed:@"camera_sahdow"];
//    }
//    return _shadeImageView;
//}
//
//- (UIImageView *)bottomShadeImageView
//{
//    if (_bottomShadeImageView == nil)
//    {
//        _bottomShadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
//        _bottomShadeImageView.image = [UIImage imageNamed:@"camera_sahdow2"];
//    }
//    return _bottomShadeImageView;
//}
//
//- (UIButton *)fullScreenButton
//{
//    if (_fullScreenButton == nil)
//    {
//        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _fullScreenButton.frame = CGRectMake(0, 0, 35, 35);
//        [_fullScreenButton setImage:[UIImage imageNamed:@"door_outarrow"] forState:UIControlStateNormal];
//    }
//    return _fullScreenButton;
//}
//
//
//- (UIButton *)halfScreenButton
//{
//    if (_halfScreenButton == nil)
//    {
//        _halfScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _halfScreenButton.frame = CGRectMake(0, 15, 30, 30);
//        [_halfScreenButton setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
//    }
//    return _halfScreenButton;
//}
//
//- (UILabel *)nickNameLabel
//{
//    if (_nickNameLabel == nil)
//    {
//        _nickNameLabel = [[UILabel alloc] init];
//        _nickNameLabel.font = [UIFont systemFontOfSize:16.0];
//        _nickNameLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
////        _nickNameLabel.text = @"宝宝的房间";
//    }
//    return _nickNameLabel;
//}
//





@end
