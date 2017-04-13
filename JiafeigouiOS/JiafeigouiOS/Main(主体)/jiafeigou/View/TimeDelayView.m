//
//  TimeDelayView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "TimeDelayView.h"
#import "JfgGlobal.h"

@interface TimeDelayView()
{
    
}
@property (nonatomic, assign) BOOL isBarShowing;

@end

@implementation TimeDelayView

static const CGFloat kVideoControlAnimationTimeinterval = 0.3;
static const CGFloat kVideoControlBarAutoFadeOutTimeinterval = 5.0;

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self initView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)initView
{
    [self addSubview:self.topBar];
    [self addSubview:self.bottomBar];
    
    
    [self.bottomBar addSubview:self.playButton];
    [self.bottomBar addSubview:self.currentTimeLabel];
    [self.bottomBar addSubview:self.progresSlider];
    [self.bottomBar addSubview:self.totalTimeLabel];
    [self.bottomBar addSubview:self.fullScreenButton];
    [self.bottomBar addSubview:self.moreButton];
    
    [self.topBar addSubview:self.closeButton];
    [self.topBar addSubview:self.dateTimeLabel];
    
    [self.topBar addSubview:self.deleteButton];
    [self.topBar addSubview:self.shareButton];
    [self.topBar addSubview:self.downloadButton];
    [self addSubview:self.indicatorView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat playButtonSpaceX;
    CGFloat currentTimeLabelSpaceX;
    CGFloat progressSliderSpaceX;
    CGFloat progressSliderWidth;
    CGFloat totalTimeLabelSpaceX;
    CGFloat fullScreenButtonSpaceX;
    
    self.topBar.frame = CGRectMake(self.left, self.top, self.width, self.topBar.height);
    
    self.closeButton.frame = CGRectMake(4*designWscale, (self.topBar.height - self.closeButton.height)*0.5, self.closeButton.height, self.closeButton.height);
    self.dateTimeLabel.frame = CGRectMake(self.topBar.left, 0.5*(self.topBar.height - self.dateTimeLabel.height), self.width, self.dateTimeLabel.height);
    
    self.bottomBar.frame = CGRectMake(self.left, self.bottom - self.bottomBar.height, self.width, self.bottomBar.height);

    
    if (self.isFullScreen) // 全屏
    {
        playButtonSpaceX = 4;
        currentTimeLabelSpaceX = 14.0;
        progressSliderSpaceX = 10.0;
        fullScreenButtonSpaceX = self.width - self.fullScreenButton.width - 5.0;
        totalTimeLabelSpaceX = fullScreenButtonSpaceX - self.totalTimeLabel.width - 5.0;
//        progressSliderWidth = self.width - self.currentTimeLabel.right  - self.totalTimeLabel.width - self.fullScreenButton.width;
        
        self.topBar.backgroundColor = [UIColor blackColor];
        self.topBar.alpha = 0.6;
        
        self.bottomBar.backgroundColor = [UIColor blackColor];
        self.bottomBar.alpha = .6;
    }
    else
    {
        playButtonSpaceX = 4;
        currentTimeLabelSpaceX = 14.0;
        progressSliderSpaceX = 0.0;
        fullScreenButtonSpaceX = self.moreButton.left - self.fullScreenButton.width + 5.0;
        totalTimeLabelSpaceX = fullScreenButtonSpaceX - self.totalTimeLabel.width - 5.0;
        
        self.topBar.backgroundColor = [UIColor clearColor];
        self.bottomBar.backgroundColor = [UIColor clearColor];
    }
    
    self.playButton.frame = CGRectMake(playButtonSpaceX*designWscale, (self.bottomBar.height - self.playButton.height) * 0.5, 35*designWscale, 35*designWscale);
    self.currentTimeLabel.frame = CGRectMake(self.playButton.right + currentTimeLabelSpaceX*designWscale, (self.bottomBar.height - self.currentTimeLabel.height)*0.5, self.currentTimeLabel.width, self.currentTimeLabel.height);
    self.totalTimeLabel.frame = CGRectMake(totalTimeLabelSpaceX, (self.bottomBar.height - self.totalTimeLabel.height)*0.5, self.totalTimeLabel.width, self.totalTimeLabel.height);
    
    if (self.isFullScreen) {
        progressSliderWidth = self.width - self.currentTimeLabel.right  - self.totalTimeLabel.width - self.fullScreenButton.width - 30;
    }else{
        progressSliderWidth = self.width - self.currentTimeLabel.right - (self.width - self.totalTimeLabel.left);
    }
    self.progresSlider.frame = CGRectMake(self.currentTimeLabel.right + progressSliderSpaceX, 0.5*(self.bottomBar.height - self.progresSlider.height), progressSliderWidth, self.progresSlider.height);
    
    
    
    self.fullScreenButton.frame = CGRectMake(fullScreenButtonSpaceX, (self.bottomBar.height - self.fullScreenButton.height)*0.5 , self.fullScreenButton.width, self.fullScreenButton.height);
//    self.fullScreenButton.frame = CGRectMake(self.totalTimeLabel.right + fullScreenButtonSpaceX*designWscale, (self.bottomBar.height - self.fullScreenButton.height)*0.5 , self.fullScreenButton.width, self.fullScreenButton.height);
    
    
    self.deleteButton.hidden = !self.isFullScreen;
    self.downloadButton.hidden = !self.isFullScreen;
    self.shareButton.hidden = !self.isFullScreen;
    
    self.moreButton.hidden = self.isFullScreen;
    self.dateTimeLabel.hidden = self.isFullScreen;
    self.indicatorView.center = self.center;
}


- (void)animateHide
{
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
    }];
}

- (void)animateShow
{
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:kVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar
{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:kVideoControlBarAutoFadeOutTimeinterval];
}
- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

#pragma mark action
- (void)onTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
        }
    }
}

#pragma mark  property
- (UIView *)topBar
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 49.0*designWscale;
    CGFloat widgetX = 0.0;
    CGFloat widgetY = 0.0;
    
    if (_topBar == nil)
    {
        _topBar = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 49.0;
    CGFloat widgetX = 0.0;
    CGFloat widgetY = kheight - widgetHeight;
    
    if (_bottomBar == nil)
    {
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
    }
    
    return _bottomBar;
}


- (UIButton *)playButton
{
    CGFloat widgetWidth = 35*designWscale;
    CGFloat widgetHeight = widgetWidth;
    CGFloat widgetX = 4*designWscale;
    CGFloat widgetY = (self.bottomBar.height - widgetHeight) * 0.5;
    
    if (_playButton == nil)
    {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_playButton setImage:[UIImage imageNamed:@"delaytime_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"delaytime_pause"] forState:UIControlStateSelected];
    }
    return _playButton;
}

- (UIButton *)fullScreenButton
{
    CGFloat widgetWidth = 35*designWscale;
    CGFloat widgetHeight = widgetWidth;
//    CGFloat widgetX = self.totalTimeLabel.right + 10*designWscale;
    CGFloat widgetX = self.width - self.moreButton.width;
    CGFloat widgetY = (self.bottomBar.height - widgetHeight)*0.5;
    
    if (_fullScreenButton == nil)
    {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_fullScreenButton setImage:[UIImage imageNamed:@"delaytme_outarrow"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"delaytme_insidetarrow"] forState:UIControlStateSelected];
    }
    
    return _fullScreenButton;
}

- (UILabel *)currentTimeLabel
{
    CGFloat widgetWidth = 35;
    CGFloat widgetHeight = 12;
    CGFloat widgetX = self.playButton.right + 14.0*designWscale;
    CGFloat widgetY = (self.bottomBar.height - widgetHeight)/2.0;
    if (_currentTimeLabel == nil)
    {
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _currentTimeLabel.textColor = [UIColor colorWithHexString:@"#cccccc"];
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.text = @"..:..";
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel
{
    CGFloat widgetWidth = self.currentTimeLabel.width;
    CGFloat widgetHeight = 12;
    CGFloat widgetX = self.progresSlider.right + 4*designWscale;
    CGFloat widgetY = (self.bottomBar.height - widgetHeight)/2.0;
    
    if (_totalTimeLabel == nil)
    {
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _totalTimeLabel.textColor = [UIColor colorWithHexString:@"#cccccc"];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.text = @"..:..";
    }
    return _totalTimeLabel;
}

- (UISlider *)progresSlider
{
    CGFloat widgetWidth = 150 * designWscale;
    CGFloat widgetHeight = 20;
    CGFloat widgetX = self.currentTimeLabel.right + 8*designWscale;
    CGFloat widgetY = (self.bottomBar.height - widgetHeight)/2.0;
    
    if (_progresSlider == nil)
    {
        _progresSlider = [[UISlider alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _progresSlider.value = 0.0f;
        _progresSlider.maximumValue = 1.0;
        _progresSlider.minimumValue = 0.0;
        _progresSlider.minimumTrackTintColor = [UIColor colorWithHexString:@"#ffffff"];
        _progresSlider.maximumTrackTintColor = [UIColor colorWithHexString:@"#cccccc"];
        _progresSlider.thumbTintColor = [UIColor colorWithHexString:@"#ffffff"];
        [_progresSlider setThumbImage:[UIImage imageNamed:@"delay_thumb"] forState:UIControlStateNormal];
    }
    return _progresSlider; 
}

- (UIButton *)moreButton
{
    CGFloat widgetWidth = 35 * designWscale;
    CGFloat widgetHeight = widgetWidth;
//    CGFloat widgetX = self.fullScreenButton.right + 3*designWscale;
    CGFloat widgetX = Kwidth - widgetWidth - 5.0;
    CGFloat widgetY = (self.bottomBar.height - widgetHeight)/2.0;
    
    if (_moreButton == nil)
    {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.hidden = NO;
        _moreButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_moreButton setImage:[UIImage imageNamed:@"delaytime_more"] forState:UIControlStateNormal];
        
    }
    return _moreButton;
}



CGFloat topButtonSpace = 15.0;

- (UIButton *)deleteButton
{
    CGFloat widgetWidth = 50 * designWscale;
    CGFloat widgetHeight = widgetWidth;
    CGFloat widgetX = kheight - self.downloadButton.width - self.shareButton.width - 15 - widgetWidth;
    CGFloat widgetY = (self.bottomBar.height - widgetHeight)*0.5;
    
    if (_deleteButton == nil)
    {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.hidden = YES;
        _deleteButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_deleteButton setImage:[UIImage imageNamed:@"delaytime_delete"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

- (UIButton *)downloadButton
{
    CGFloat widgetWidth = 50 * designWscale;
    CGFloat widgetHeight = widgetWidth;
    CGFloat widgetX = kheight - self.shareButton.width - 15 - widgetWidth;
    CGFloat widgetY = (self.topBar.height - widgetHeight)*0.5;
    
    if (_downloadButton == nil)
    {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadButton.hidden = YES;
        _downloadButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_downloadButton setImage:[UIImage imageNamed:@"delaytime_download"] forState:UIControlStateNormal];
    }
    return _downloadButton;
}

- (UIButton *)shareButton
{
    CGFloat widgetWidth = 50 * designWscale;
    CGFloat widgetHeight = widgetWidth;
    CGFloat widgetX = kheight - 20 - widgetWidth;
    CGFloat widgetY = (self.topBar.height - widgetHeight)*0.5;
    
    if (_shareButton == nil)
    {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_shareButton setImage:[UIImage imageNamed:@"delaytime_share"] forState:UIControlStateNormal];
    }
    return _shareButton;
}


- (UIButton *)closeButton
{
    CGFloat widgetWidth = 35*designWscale;
    CGFloat widgetHeight = widgetWidth;
    CGFloat widgetX = 4*designWscale;
    CGFloat widgetY = (self.topBar.height - widgetHeight)*0.5;
    
    if (_closeButton == nil)
    {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_closeButton setImage:[UIImage imageNamed:@"login_btn_close"] forState:UIControlStateNormal];
    }
    return _closeButton;
}

- (UILabel *)dateTimeLabel
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 30;
    CGFloat widgetX = 0;
    CGFloat widgetY = (self.topBar.height - widgetHeight)*0.5;
    
    if (_dateTimeLabel == nil)
    {
        _dateTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _dateTimeLabel.font = [UIFont systemFontOfSize:17.0f];
        _dateTimeLabel.textAlignment = NSTextAlignmentCenter;
        _dateTimeLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _dateTimeLabel.text = @"03.02-18:00";
    }
    return _dateTimeLabel;
}


-(UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];//指定进度轮的大小
        [_indicatorView setCenter:CGPointMake(160, 140)];//指定进度轮中心点
        [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
    }
    return _indicatorView;
}

@end
