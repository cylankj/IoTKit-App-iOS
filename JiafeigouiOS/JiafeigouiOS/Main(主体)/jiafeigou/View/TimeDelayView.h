//
//  TimeDelayView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeDelayView : UIView

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;

/**
 *  播放 暂停 按钮
 */
@property (nonatomic, strong) UIButton *playButton;
/**
 *  横屏 竖屏 按钮
 */
@property (nonatomic, strong) UIButton *fullScreenButton;
/**
 *  当前 时间 Label
 */
@property (nonatomic, strong) UILabel *currentTimeLabel;
/**
 *  总时间 Lael
 */
@property (nonatomic, strong) UILabel *totalTimeLabel;
/**
 *  进度条 Slider
 */
@property (nonatomic, strong) UISlider *progresSlider;
/**
 *  更多 按钮
 */
@property (nonatomic, strong) UIButton *moreButton;
/**
 *  删除 按钮
 */
@property (nonatomic, strong) UIButton *deleteButton;
/**
 *  下载 按钮
 */
@property (nonatomic, strong) UIButton *downloadButton;
/**
 *  分享 按钮
 */
@property (nonatomic, strong) UIButton *shareButton;


/**
 *  关闭 按钮
 */
@property (nonatomic, strong) UIButton *closeButton;
/**
 *  时间 Label
 */
@property (nonatomic, strong) UILabel *dateTimeLabel;


@property (nonatomic,strong)UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL isFullScreen;

- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

@end
