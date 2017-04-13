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
#import "NSString+FLExtension.h"

@interface Watch720PhotoVC ()<YBPopupMenuDelegate>

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

@property (nonatomic, strong) UIButton *downLoadButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIButton *favoriteButton;

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
    
    [self.bottomBgView addSubview:self.downLoadButton];
    [self.bottomBgView addSubview:self.shareButton];
    [self.bottomBgView addSubview:self.favoriteButton];
    
    [self resetViewFrame];
    [self initData];
}

// 重新 调整 布局
- (void)resetViewFrame
{
    NSArray *buttons = @[self.photoButton, self.vrModelButton, self.scanModelButton, self.tlyModelButton]; // 总的 button 个数
    
    switch (self.mediaType)
    {
        case mediaTypePhoto:
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
            break;
        case mediaTypeVideo:
        {
            [self.bottomBgView addSubview:self.sliderView];
            [self.bottomBgView addSubview:self.playButton];
            [self.bottomBgView addSubview:self.timeLabel];
            
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
            break;
        default:
            break;
    }
}

- (void)initData
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

- (void)screenDiretionChanged:(BOOL)isLandScape
{
    [[UIApplication sharedApplication] setStatusBarHidden:isLandScape withAnimation:UIStatusBarAnimationFade];
    
    self.downLoadButton.hidden = !isLandScape;
    self.shareButton.hidden = !isLandScape;
    self.favoriteButton.hidden = !isLandScape;
    
    self.photoButton.hidden = isLandScape;
    self.vrModelButton.hidden = isLandScape;
    self.tlyModelButton.hidden = isLandScape;
    self.scanModelButton.hidden = isLandScape;
    self.moreButton.hidden = isLandScape;
    self.sharedButton.hidden = isLandScape;
    
    if (isLandScape == YES) // 横屏
    {
        self.bottomBgView.frame = CGRectMake(0, 0, 44, kheight);
        
        self.backButton.frame = CGRectMake(10, (44 - self.backButton.width)*0.5, self.backButton.width, self.backButton.height);
        self.titleTimeLabel.frame = CGRectMake(self.backButton.right + 10, (44 - self.titleTimeLabel.height)*0.5, self.titleTimeLabel.width, self.titleTimeLabel.height);
        self.topBgView.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.topBgView.frame = CGRectMake(Kwidth-44, 0, 44, kheight);
    }
    else // 竖屏
    {
        
    }
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
    YBPopupMenu *popupMenu = [YBPopupMenu showAtPoint:CGPointMake(self.moreButton.x, 64.0) titles:@[[JfgLanguage getLanTextStrByKey:@"下载"], [JfgLanguage getLanTextStrByKey:@"删除"]] icons:@[@"details_icon_down",@"album_icon_delete"] menuWidth:149 delegate:nil];
    popupMenu.dismissOnSelected = YES;
    popupMenu.textColor = [UIColor colorWithHexString:@"#ffffff"];
    popupMenu.isShowShadow = YES;
    popupMenu.delegate = self;
    popupMenu.offset = 2;
    popupMenu.type = YBPopupMenuTypeDark;
}

#pragma mark
#pragma mark  delegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    
}


#pragma mark
#pragma mark  getter
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
        CGFloat y = 20 + (self.topBgView.height - height)*0.5;
    
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
        CGFloat y = 20 + (44 - height)*0.5;
        
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
        CGFloat y = 20 + (44 - height)*0.5;
        
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
        CGFloat y = 20 + (44 - height)*0.5;
        
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

- (UIButton *)downLoadButton
{
    if (_downLoadButton == nil)
    {
        CGFloat spaceX = 108;
        
        CGFloat width = 23;
        CGFloat height = 23;
        CGFloat x = 12;
        CGFloat y = kheight - 3*width - 3*spaceX;
        
        _downLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downLoadButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        _downLoadButton.hidden = YES;
        _downLoadButton.frame = CGRectMake(x, y, width, height);
        [_downLoadButton setBackgroundImage:[UIImage imageNamed:@"details_icon_down"] forState:UIControlStateNormal];
    }
    
    return _downLoadButton;
}

- (UIButton *)shareButton
{
    if (_shareButton == nil)
    {
        CGFloat spaceX = 108;
        
        CGFloat width = 23;
        CGFloat height = 23;
        CGFloat x = 12;
        CGFloat y = kheight - 3*width - 2*spaceX;
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _shareButton.hidden = YES;
        _shareButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        _shareButton.frame = CGRectMake(x, y, width, height);
        [_shareButton setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    }
    
    return _shareButton;
}

- (UIButton *)favoriteButton
{
    if (_favoriteButton == nil)
    {
        CGFloat spaceX = 108;
        
        CGFloat width = 23;
        CGFloat height = 23;
        CGFloat x = 12;
        CGFloat y = kheight - 3*width - spaceX;
        
        _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteButton.frame = CGRectMake(x, y, width, height);
        _favoriteButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        [_favoriteButton setBackgroundImage:[UIImage imageNamed:@"icon_collection"] forState:UIControlStateNormal];
    }
    
    return _favoriteButton;
}

@end
