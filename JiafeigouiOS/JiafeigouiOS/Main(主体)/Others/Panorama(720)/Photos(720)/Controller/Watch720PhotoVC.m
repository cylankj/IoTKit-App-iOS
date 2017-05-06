//
//  Watch720PhotoVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Watch720PhotoVC.h"
#import "JfgGlobal.h"
#import "YBPopupMenu.h"
#import "VideoPlayFor720ViewController.h"
#import <JFGSDK/JFGSDKPlayer.h>
#import "JfgTimeFormat.h"
#import "NSString+FLExtension.h"

@interface Watch720PhotoVC ()<YBPopupMenuDelegate, JFGSDKPlayerDelegate>

// 顶部
@property (nonatomic, strong) UIView *topBgView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleTimeLabel;
@property (nonatomic, strong) UIButton *sharedButton;
@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) Panoramic720IosView *pano720View;

// 底部
@property (nonatomic, strong) UIView *bottomBgView;

@property (nonatomic, strong) UIButton *photoButton; // 拍照
@property (nonatomic, strong) UIButton *vrModelButton;  // VR 模式
@property (nonatomic, strong) UIButton *scanModelButton; // 浏览/全景 模式
@property (nonatomic, strong) UIButton *tlyModelButton; // 陀螺仪 模式

// 视频
@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, strong) UIButton *playButton; // 播放，暂停 按钮
@property (nonatomic, strong) UILabel *timeLabel;   //进度 时间显示 按钮

// 横屏
@property (nonatomic, assign) BOOL isLandScape; // 是否横屏

// Player
@property (nonatomic, strong) JFGSDKPlayer *panoPlayer;

@end

@implementation Watch720PhotoVC
@dynamic leftButton, titleLabel;

#pragma mark
#pragma mark  view 生命周期 及 系统 集成方法

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}


- (void)initView
{
    self.navigationView.hidden = YES;
    
    [self.view addSubview:self.pano720View];
    
    [self.view addSubview:self.topBgView];
    [self.topBgView addSubview:self.backButton];
    [self.topBgView addSubview:self.titleTimeLabel];
    [self.topBgView addSubview:self.sharedButton];
    [self.topBgView addSubview:self.moreButton];
    
    [self.view addSubview:self.bottomBgView];
    [self.bottomBgView addSubview:self.photoButton];
    [self.bottomBgView addSubview:self.vrModelButton];
    [self.bottomBgView addSubview:self.scanModelButton];
    [self.bottomBgView addSubview:self.tlyModelButton];
    
    if (self.panoMediaType == mediaTypeVideo)
    {
        [self.bottomBgView addSubview:self.sliderView];
        [self.bottomBgView addSubview:self.playButton];
        [self.bottomBgView addSubview:self.timeLabel];
    }
    
    [self resetViewFrame];

    [self initLoadMedia];
    [self screenDiretionChanged:(self.panoMediaType == mediaTypeVideo)];
    
}

// according mediaType update viewFrame
- (void)resetViewFrame
{
    NSArray *buttons = @[self.photoButton, self.vrModelButton, self.scanModelButton, self.tlyModelButton]; // 总的 button 个数
    
    switch (self.panoMediaType)
    {
        case mediaTypePhoto:
        {
            if (!self.isLandScape)
            {
                CGFloat widthMax = 40*buttons.count + 50*designWscale*(buttons.count - 1);// 所有按钮占总长度
                CGFloat spaceX = 50*designWscale; // button 之间的间隔
                
                for (NSInteger i = 0; i < buttons.count ; i ++)
                {
                    UIButton *aButton = [buttons objectAtIndex:i];
                    aButton.left = (self.bottomBgView.width -  widthMax)*0.5 + i *(aButton.width + spaceX);
                    aButton.top = (self.bottomBgView.height - aButton.height)*0.5;
                }
            }
            else
            {
                CGFloat leftest = 101; //to left or right distance
                CGFloat spcaceX = (kheight - leftest*2 - 40*buttons.count)/(buttons.count - 1);
                
                for (NSInteger i = 0; i < buttons.count; i ++)
                {
                    UIButton *aButton = [buttons objectAtIndex:i];
                    aButton.left = leftest + i*(spcaceX + aButton.width);
                    aButton.top = (self.bottomBgView.width - aButton.width)*0.5;
                }
                
            }
            
        }
            break;
        case mediaTypeVideo:
        {
            if (!self.isLandScape)
            {
                CGFloat widthMax = self.bottomBgView.width - self.timeLabel.right; // 按钮 占 总长度
                CGFloat leftSpace = 30*designWscale; // 左边间距
                CGFloat rightSpace = 13*designWscale; // 右边间距
                CGFloat buttonWidth = 30.0f;
                
                CGFloat spaceX = (widthMax - leftSpace - rightSpace - buttonWidth*buttons.count)/(buttons.count - 1);
                
                for (NSInteger j = 0; j < buttons.count; j ++)
                {
                    UIButton *aButton = [buttons objectAtIndex:j];
                    aButton.width = aButton.height = buttonWidth;
                    aButton.bottom = self.bottomBgView.height - 9;
                    aButton.left = self.timeLabel.right +leftSpace + (aButton.width + spaceX)*j;
                }
            }
            else
            {
                CGFloat buttonWidth = 30.0;
                CGFloat spaceX = 40.0f;
                
                for (NSInteger j = 0; j < buttons.count; j ++)
                {
                    UIButton *aButton = [buttons objectAtIndex:j];
                    aButton.width = aButton.height = buttonWidth;
                    aButton.right = kheight - 16.0 - (buttons.count - j - 1)*(spaceX+aButton.width);
                    aButton.bottom = self.bottomBgView.width - 7.0;
                }
                
            }
        }
            break;
        default:
            break;
    }
}

- (void)initLoadMedia
{
    self.titleTimeLabel.text = [JfgTimeFormat transformTime:self.titleTime withFormat:@"yyyy-mm-dd hh:mm"];
    
    
    switch (self.panoMediaType)
    {
        case mediaTypeVideo:
        {
            NSString *path = self.panoMediaPath;
            [self.panoPlayer playForUrl:path];
        }
            break;
        case mediaTypePhoto:
        {
            if (self.panoMediaPath != nil)
            {
                [self.pano720View loadImage:self.panoMediaPath];
            }
            else
            {
                [self.pano720View loadUIImage:[UIImage imageNamed:@"guide-pages3"]];
            }
        }
            break;
        default:
            break;
    }
    
    
}

- (void)screenDiretionChanged:(BOOL)isLandScape
{
    [[UIApplication sharedApplication] setStatusBarHidden:isLandScape withAnimation:UIStatusBarAnimationFade];
    self.isLandScape = isLandScape;
    CGFloat topViewHeigth = 50.0;
    CGFloat bottomViewHeight = 50.0;
    
    switch (self.panoMediaType)
    {
        case mediaTypePhoto:
        {
            if (isLandScape == YES)
            {
                self.backButton.frame = CGRectMake(10, (topViewHeigth - self.backButton.width)*0.5, self.backButton.width, self.backButton.height);
                self.titleTimeLabel.frame = CGRectMake(self.backButton.right + 10, (topViewHeigth - self.titleTimeLabel.height)*0.5, self.titleTimeLabel.width, self.titleTimeLabel.height);
                self.moreButton.frame = CGRectMake(kheight - self.moreButton.width - 15, (topViewHeigth-self.moreButton.height)*0.5, self.moreButton.width, self.moreButton.height);
                self.sharedButton.frame = CGRectMake(self.moreButton.left - self.moreButton.width - 15, (topViewHeigth-self.sharedButton.height)*0.5, self.sharedButton.width, self.sharedButton.height);
                
                self.topBgView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.topBgView.frame = CGRectMake(Kwidth-topViewHeigth, 0, topViewHeigth, kheight);
                
                self.bottomBgView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.bottomBgView.frame = CGRectMake(0, 0, bottomViewHeight, kheight);
                
            }
            else
            {
                self.bottomBgView.transform = CGAffineTransformIdentity;
                self.bottomBgView.frame = CGRectMake(0, kheight-64.0, Kwidth, 64.0);
                self.playButton.frame = CGRectMake(8, self.bottomBgView.height - 24 - 10, 24, 24);
                self.timeLabel.frame = CGRectMake(self.playButton.right + 5, self.bottomBgView.height - 12 - 16, 70, 12);
                
                self.topBgView.transform = CGAffineTransformIdentity;
                self.topBgView.frame = CGRectMake(0, 0, Kwidth, 64.0);
                self.backButton.frame = CGRectMake(10, (self.topBgView.height - 30 + 20)*0.5, 30, 30);
                self.titleTimeLabel.frame = CGRectMake(Kwidth*0.1, (self.topBgView.height - 17.0 + 20)*0.5, Kwidth*0.8, 17.0);
                self.titleTimeLabel.textAlignment = NSTextAlignmentCenter;
                self.moreButton.frame = CGRectMake(Kwidth - 23 - 15, (self.topBgView.height - 23 +20)*0.5, 23, 23);
                self.sharedButton.frame = CGRectMake(self.moreButton.left - 18 - 23, (self.topBgView.height - 23 + 20)*0.5, 23, 23);
                
            }
            [self resetViewFrame];
        }
            break;
        case mediaTypeVideo:
        {
            if (isLandScape == YES) // 横屏
            {
                self.bottomBgView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.bottomBgView.frame = CGRectMake(0, 0, bottomViewHeight, kheight);
                
                self.sliderView.width = kheight - 15*2.0f;
                self.sliderView.left = 15.0f;
                self.sliderView.top = 0.0;
                
                self.titleTimeLabel.left = self.backButton.right + 15.0;
                self.titleTimeLabel.textAlignment = NSTextAlignmentLeft;
                self.moreButton.right = kheight - 15.0;
                self.moreButton.top = (self.topBgView.height - self.moreButton.height - 20)*0.5;
                self.sharedButton.right = self.moreButton.left - 15.0;
                self.sharedButton.top = self.moreButton.top;
                self.playButton.left = 10.0;
                self.playButton.bottom = self.bottomBgView.width - 10.0;
                self.timeLabel.left = self.playButton.right + 5.0;
                self.timeLabel.bottom = self.bottomBgView.width - 15.0;
                
                self.backButton.frame = CGRectMake(10, (44 - self.backButton.width)*0.5, self.backButton.width, self.backButton.height);
                self.titleTimeLabel.frame = CGRectMake(self.backButton.right + 10, (44 - self.titleTimeLabel.height)*0.5, self.titleTimeLabel.width, self.titleTimeLabel.height);
                self.topBgView.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.topBgView.frame = CGRectMake(Kwidth-44, 0, 44, kheight);
            }
            else // 竖屏
            {
                self.bottomBgView.transform = CGAffineTransformIdentity;
                self.bottomBgView.frame = CGRectMake(0, kheight-64.0, Kwidth, 64.0);
                self.playButton.frame = CGRectMake(8, self.bottomBgView.height - 24 - 10, 24, 24);
                self.timeLabel.frame = CGRectMake(self.playButton.right + 5, self.bottomBgView.height - 12 - 16, 70, 12);
                
                self.topBgView.transform = CGAffineTransformIdentity;
                self.topBgView.frame = CGRectMake(0, 0, Kwidth, 64.0);
                self.backButton.frame = CGRectMake(10, (self.topBgView.height - 30 + 20)*0.5, 30, 30);
                self.titleTimeLabel.frame = CGRectMake(Kwidth*0.1, (self.topBgView.height - 17.0 + 20)*0.5, Kwidth*0.8, 17.0);
                self.titleTimeLabel.textAlignment = NSTextAlignmentCenter;
                self.moreButton.frame = CGRectMake(Kwidth - 23 - 15, (self.topBgView.height - 23 +20)*0.5, 23, 23);
                self.sharedButton.frame = CGRectMake(self.moreButton.left - 18 - 23, (self.topBgView.height - 23 + 20)*0.5, 23, 23);
            }
            
            [self resetViewFrame];
        }
            break;
        default:
            break;
    }
}

- (void)showHideTopBottomViewAction
{
    
}

- (void)showTopBottomView
{
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideTopBottomView
{
    
    [UIView animateWithDuration:0.2 animations:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark  action
- (void)moreButtonAction:(UIButton *)sender
{
    YBPopupMenu *popupMenu = [YBPopupMenu showAtPoint:CGPointMake(self.moreButton.x, 64.0) titles:@[[JfgLanguage getLanTextStrByKey:@"Tap1_Album_Download"], [JfgLanguage getLanTextStrByKey:@"DELETE"]] icons:@[@"details_icon_down",@"album_icon_delete"] menuWidth:149 delegate:nil];
    popupMenu.dismissOnSelected = YES;
    popupMenu.textColor = [UIColor colorWithHexString:@"#ffffff"];
    popupMenu.isShowShadow = YES;
    popupMenu.delegate = self;
    popupMenu.offset = 2;
    popupMenu.type = YBPopupMenuTypeDark;
    
    popupMenu.transform = CGAffineTransformMakeRotation(M_PI_2);
    popupMenu.frame = CGRectMake(Kwidth - 130, kheight - 40, popupMenu.width, popupMenu.height);
    
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)modelButtonAction:(UIButton *)sender
{
    DFDisplayMode watchModel = DM_Equirectangular;
    
    if (sender == self.vrModelButton)
    {
        watchModel = DM_Fisheye;
    }
    else if (sender == self.tlyModelButton)
    {
        watchModel = DM_LittlePlanet;
    }
    else if (sender == self.scanModelButton)
    {
        watchModel = DM_Panorama;
    }
    
    [self.pano720View setDisplayMode:watchModel];
    
}



#pragma mark
#pragma mark  JFGSDK delegate
-(void)jfgSDKPlayerReady:(JFGSDKPlayer *)player width:(int)width height:(int)height
{   
    //self.pano720View = [[Panoramic720IosView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*2)];
    self.pano720View.backgroundColor = [UIColor blackColor];
    self.pano720View.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
    self.pano720View.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*2);
    
    [self.view bringSubviewToFront:self.bottomBgView];
    [self.view bringSubviewToFront:self.topBgView];
    
    [self.panoPlayer startRenderForView:self.pano720View];
}

-(void)jfgSDKPlayerFinished:(JFGSDKPlayer *)player
{
    
}

-(void)jfgSDKPlayerFailed:(JFGSDKPlayer *)player
{
    
}

#pragma mark
#pragma mark  delegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    
}


#pragma mark
#pragma mark  getter
- (JFGSDKPlayer *)panoPlayer
{
    //
    if (_panoPlayer == nil) {
        _panoPlayer = [[JFGSDKPlayer alloc]init];
        _panoPlayer.delegate = self;
    }
    
    return _panoPlayer;
}

// 顶部 view
- (UIView *)topBgView
{
    if (_topBgView == nil)
    {
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat width = Kwidth;
        CGFloat height = 64.0;
        
        _topBgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _topBgView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        _topBgView.alpha = 0.6f;
    }
    
    return _topBgView;
}

- (UIButton *)backButton
{
    if (_backButton == nil)
    {
        CGFloat width = 30;
        CGFloat height = 30;
        CGFloat x = 10;
        CGFloat y = (self.topBgView.height - height + 20)*0.5;
    
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(x, y, width, height);
        [_backButton setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleTimeLabel
{
    if (_titleTimeLabel == nil)
    {
        CGFloat width = Kwidth*0.8;
        CGFloat height = 17.0;
        CGFloat x = (Kwidth - width)*0.5;
        CGFloat y = (self.topBgView.height - height + 20)*0.5;
        
        _titleTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _titleTimeLabel.text = @"2017-06-18 18:00";
        _titleTimeLabel.textAlignment = NSTextAlignmentCenter;
        _titleTimeLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _titleTimeLabel.font = [UIFont systemFontOfSize:height];
    }
    return _titleTimeLabel;
}

- (UIButton *)sharedButton
{
    if (_sharedButton == nil)
    {
        CGFloat width = 23;
        CGFloat height = 23;
        CGFloat x = self.moreButton.left - width - 18;
        CGFloat y = (self.topBgView.height - height + 20)*0.5;
        
        _sharedButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [_sharedButton setBackgroundImage:[UIImage imageNamed:@"details_icon_share"] forState:UIControlStateNormal];
        
    }
    return _sharedButton;
}

- (UIButton *)moreButton
{
    if (_moreButton == nil)
    {
        CGFloat width = 23;
        CGFloat height = 23;
        CGFloat x = Kwidth - width - 15;
        CGFloat y = (self.topBgView.height - height + 20)*0.5;
        
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [_moreButton setBackgroundImage:[UIImage imageNamed:@"details_icon_more"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (Panoramic720IosView *)pano720View
{
    if (_pano720View == nil)
    {
        _pano720View = [[Panoramic720IosView alloc] initPanoramicViewWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
        [_pano720View configV720];
        _pano720View.backgroundColor = [UIColor blackColor];
        _pano720View.layer.edgeAntialiasingMask = YES;
    }
    return _pano720View;
}

// 底部 view
- (UIView *)bottomBgView
{
    if (_bottomBgView == nil)
    {
        CGFloat width = Kwidth;
        CGFloat height = 64.0;
        CGFloat x = 0;
        CGFloat y = kheight - height;
        
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _bottomBgView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        _bottomBgView.alpha = 0.6f;
    }
    return _bottomBgView;
}

- (UIButton *)photoButton
{
    if (_photoButton == nil)
    {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.frame = CGRectMake(0, 0, 40, 40);
        [_photoButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_camera"] forState:UIControlStateNormal];
        
    }
    return _photoButton;
}

- (UIButton *)vrModelButton
{
    if (_vrModelButton == nil)
    {
        _vrModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _vrModelButton.frame = CGRectMake(0, 0, 40, 40);
        [_vrModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_vr"] forState:UIControlStateNormal];
        [_vrModelButton addTarget:self action:@selector(modelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vrModelButton;
}

- (UIButton *)scanModelButton
{
    if (_scanModelButton == nil)
    {
        _scanModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _scanModelButton.frame = CGRectMake(0, 0, 40, 40);
        [_scanModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_panorama"] forState:UIControlStateNormal];
        [_scanModelButton addTarget:self action:@selector(modelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanModelButton;
}

- (UIButton *)tlyModelButton
{
    if (_tlyModelButton == nil)
    {
        _tlyModelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _tlyModelButton.frame = CGRectMake(0, 0, 40, 40);
        [_tlyModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_gyroscope"] forState:UIControlStateNormal];
        [_tlyModelButton addTarget:self action:@selector(modelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tlyModelButton;
}

- (UISlider *)sliderView
{
    if (_sliderView == nil)
    {
        CGFloat x = 15;
        CGFloat y = 5;
        CGFloat width = (Kwidth - x - 5);
        CGFloat height = 10;
        
        _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(x, y, width, height)];
    }
    return _sliderView;
}

- (UIButton *)playButton
{
    if (_playButton == nil)
    {
        CGFloat width = 24;
        CGFloat height = 24;
        CGFloat x = 8;
        CGFloat y = self.bottomBgView.height - height - 10;
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(x, y, width, height);
        [_playButton setBackgroundImage:[UIImage imageNamed:@"btn_rightkey_nomal"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"btn_rightkey_disabled"] forState:UIControlStateDisabled];
    }
    
    return _playButton;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil)
    {
        CGFloat width = 70;
        CGFloat height = 12;
        CGFloat x = self.playButton.right + 5;
        CGFloat y = self.bottomBgView.height - height - 16;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _timeLabel.font = [UIFont systemFontOfSize:height];
        _timeLabel.text = @"00:02/00:09";
        _timeLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    }
    return _timeLabel;
}

@end
