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
#import "ShareView.h"
#import "JFGAlbumManager.h"
#import "JFGDownLoadTool.h"
#import "DeviceOrientation.h"
#import "FLProressHUD.h"
#import "POPBasicAnimation.h"
#import "ProgressHUD.h"
#import "LoginManager.h"
#import "JfgUserDefaultKey.h"
#import "CommonMethod.h"
#import "FileManager.h"
#import "LSAlertView.h"
#import "JfgGlobal.h"
#import "DownloadUtils.h"
#import "JFGDownLoadTool.h"
#import "TYDownloadSessionManager.h"
#import <JFGSDK/MPMessagePackReader.h>
#import "UIAlertView+FLExtension.h"
#import "ShareVideoViewController.h"
#import "NSTimer+FLExtension.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>

extern NSInteger supportDirection;

@interface Watch720PhotoVC ()<YBPopupMenuDelegate, JFGSDKPlayerDelegate, JFGSDKCallbackDelegate, DeviceOrientationDelegate>
{
    NSTimer *progressTimer;
}
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
@property (nonatomic, assign) CGFloat videoDuration;

@property (nonatomic, assign) BOOL isShowTool;

@property (nonatomic, strong) UIView *tipView;

@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) DeviceOrientation *devOriention;
@property (nonatomic, assign) int clickTimes;   // 点击次数

@property (nonatomic, strong) DownloadUtils *dlUtils;
@property (nonatomic, strong) JFGDownLoadTool *downloadTool;
@property (nonatomic, strong) TYDownloadModel *tyDownLoadModel;
@property (nonatomic, strong) YBPopupMenu *popUpMenu;

@end

@implementation Watch720PhotoVC
@dynamic leftButton, titleLabel;

#pragma mark
#pragma mark  view 生命周期 及 系统 集成方法

- (void)dealloc
{
    JFGLog(@"watch VC dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.clickTimes = 0;
    self.isShowTool = YES; // Default YES
    
    [JFGSDK addDelegate:self];
    
    [self initView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    supportDirection = DeviceDirectionTypeALL;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self screenDiretionChanged:NO isAnimation:NO];
    
    
    // 重新 设置下这个 坐标 解决 坐标错乱
    CGFloat width = self.sharedButton.left - self.backButton.right;
    CGFloat height = 17.0;
    CGFloat x = self.backButton.right;
    CGFloat y = (self.topBgView.height - height + 20)*0.5;
    
    self.titleTimeLabel.frame = CGRectMake(x, y, width, height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    supportDirection = DeviceDirectionTypePortrait;
    if (self.panoMediaType == mediaTypeVideo)
    {
        [self.panoPlayer stopPlay];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self forceRecoverToPortrait];
    supportDirection = DeviceDirectionTypePortrait;
    [JFGSDK removeDelegate:self];
}

- (void)initView
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.navigationView.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    JFG_WS(weakSelf);
    [self.view addSubview:self.pano720View];
    [self.pano720View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).with.offset(0);
        make.left.equalTo(weakSelf.view).with.offset(0);
        make.width.equalTo(weakSelf.view);
        make.height.equalTo(weakSelf.view);
    }];
    
    [self.view addSubview:self.loadingImageView];
    
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
    
}

- (void)initLoadMedia
{
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"watch filePath %@",self.panoMediaPath]];
    
    self.titleTimeLabel.text = [JfgTimeFormat transformTime:self.titleTime withFormat:@"yyyy-MM-dd hh:mm a"];
    switch (self.panoMediaType)
    {
        case mediaTypeVideo:
        {
            [self play];
        }
            break;
        case mediaTypePhoto:
        {
            if (self.panoMediaPath != nil)
            {
                UIImage *image = [UIImage imageWithContentsOfFile:self.panoMediaPath];
                if (image != nil)
                {
                    [self.pano720View loadUIImage:image];
                }
                else
                {
                    [JFGSDK appendStringToLogFile:@"load thumbNail Image"];
                    [self.pano720View loadUIImage:self.thumbNailImage];
                }
            }
            else if (self.thumbNailImage)
            {
                [self.pano720View loadUIImage:self.thumbNailImage];
            }
        }
            break;
        default:
            break;
    }
    
    [self.pano720View setDisplayMode:DM_Fisheye];
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
                CGFloat spcaceX = (Kwidth - leftest*2 - 40*buttons.count)/(buttons.count - 1);
                
                for (NSInteger i = 0; i < buttons.count; i ++)
                {
                    UIButton *aButton = [buttons objectAtIndex:i];
                    aButton.left = leftest + i*(spcaceX + aButton.width);
                    aButton.top = (self.bottomBgView.height - aButton.height)*0.5;
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
                    aButton.right = Kwidth - 16.0 - (buttons.count - j - 1)*(spaceX+aButton.width);
                    aButton.bottom = self.bottomBgView.height - 7.0;
                }
                
            }
        }
            break;
        default:
            break;
    }
}

- (void)screenDiretionChanged:(BOOL)isLandScape isAnimation:(BOOL)isAnimated
{
    [[UIApplication sharedApplication] setStatusBarHidden:isLandScape withAnimation:UIStatusBarAnimationFade];
    
    self.isLandScape = isLandScape;
    
    if (isAnimated)
    {
        [self updateFrameWithLandScape:isLandScape];
    }
    else
    {
        [self updateFrameWithLandScape:isLandScape];
    }
}

- (void)updateFrameWithLandScape:(BOOL)isLandScape
{
    CGFloat topViewHeigth = 50.0;
    CGFloat bottomViewHeight = 50.0;
    
    switch (self.panoMediaType)
    {
        case mediaTypePhoto:
        {
            if (isLandScape == YES)
            {
                self.topBgView.frame = CGRectMake(0, 0, Kwidth, topViewHeigth);
                
                self.backButton.frame = CGRectMake(10, (topViewHeigth - self.backButton.height)*0.5, self.backButton.width, self.backButton.height);
                self.titleTimeLabel.frame = CGRectMake(self.backButton.right + 10, (topViewHeigth - self.titleTimeLabel.height)*0.5, self.titleTimeLabel.width, self.titleTimeLabel.height);
                self.titleTimeLabel.textAlignment = NSTextAlignmentLeft;
                self.moreButton.frame = CGRectMake(Kwidth - self.moreButton.width - 20, (topViewHeigth-self.moreButton.height)*0.5, self.moreButton.width, self.moreButton.height);
                self.sharedButton.frame = CGRectMake(self.moreButton.left - self.moreButton.width - 24, (topViewHeigth-self.sharedButton.height)*0.5, self.sharedButton.width, self.sharedButton.height);

                self.bottomBgView.frame = CGRectMake(0, kheight-bottomViewHeight, Kwidth, bottomViewHeight);
            }
            else
            {
                self.bottomBgView.frame = CGRectMake(0, kheight-64.0, Kwidth, 64.0);
                
                self.topBgView.frame = CGRectMake(0, 0, Kwidth, 64.0);
                
                self.backButton.frame = CGRectMake(10, (self.topBgView.height - self.backButton.height + 20)*0.5, self.backButton.width, self.backButton.height);
                self.titleTimeLabel.frame = CGRectMake((Kwidth*0.2)*0.5, (self.topBgView.height - self.titleLabel.height + 20)*0.5, self.titleTimeLabel.width, self.titleTimeLabel.height);
                self.titleTimeLabel.textAlignment = NSTextAlignmentCenter;
                self.moreButton.frame = CGRectMake(Kwidth - self.moreButton.width - 15, (self.topBgView.height - self.moreButton.height + 20)*0.5, self.moreButton.width, self.moreButton.height);
                self.sharedButton.frame = CGRectMake(self.moreButton.left - self.moreButton.width - 24, (self.topBgView.height-self.sharedButton.height + 20)*0.5, self.sharedButton.width, self.sharedButton.height);
            }
            
            
            [self resetViewFrame];
        }
            break;
        case mediaTypeVideo:
        {
            if (isLandScape == YES) // 横屏
            {
                self.bottomBgView.frame = CGRectMake(0, kheight - bottomViewHeight, Kwidth, bottomViewHeight);
                
                self.sliderView.width = Kwidth - 15*2.0f;
                self.sliderView.left = 15.0f;
                self.sliderView.top = 0.0;
                
                self.playButton.left = 10.0;
                self.playButton.bottom = self.bottomBgView.height - 6.0;
                self.timeLabel.left = self.playButton.right + 5.0;
                self.timeLabel.bottom = self.bottomBgView.height - 15.0;
                
                self.topBgView.frame = CGRectMake(0, 0, Kwidth, 44);
                
                self.moreButton.right = Kwidth - 20.0;
                self.moreButton.top = (self.topBgView.height - self.moreButton.height)*0.5;
                self.sharedButton.right = self.moreButton.left - 24.0;
                self.sharedButton.top = self.moreButton.top;
                self.backButton.frame = CGRectMake(10, (topViewHeigth - self.backButton.height)*0.5, self.backButton.width, self.backButton.height);
                self.titleTimeLabel.frame = CGRectMake(self.backButton.right + 10, (44 - self.titleTimeLabel.height)*0.5, self.titleTimeLabel.width, self.titleTimeLabel.height);
                self.titleTimeLabel.textAlignment = NSTextAlignmentLeft;
            }
            else // 竖屏
            {
                self.bottomBgView.frame = CGRectMake(0, kheight-64.0, Kwidth, 64.0);
                
                self.playButton.frame = CGRectMake(8, (self.bottomBgView.height - 30 - 7), 30, 30);
                self.timeLabel.frame = CGRectMake(self.playButton.right + 5, self.bottomBgView.height - 12 - 16, 80, 12);
                
                self.sliderView.width = Kwidth - 15*2.0f;
                self.sliderView.left = 15.0f;
                self.sliderView.top = 10.0;
                
                self.topBgView.transform = CGAffineTransformIdentity;
                self.topBgView.frame = CGRectMake(0, 0, Kwidth, 64.0);
                self.backButton.frame = CGRectMake(10, (self.topBgView.height - 30 + 20)*0.5, 30, 30);
                self.titleTimeLabel.frame = CGRectMake(Kwidth*0.1, (self.topBgView.height - 17.0 + 20)*0.5, Kwidth*0.8, 17.0);
                self.titleTimeLabel.textAlignment = NSTextAlignmentCenter;
                self.moreButton.frame = CGRectMake(Kwidth - 23 - 15, (self.topBgView.height - 23 +20)*0.5, 23, 23);
                self.sharedButton.frame = CGRectMake(self.moreButton.left - 18 - 24, (self.topBgView.height - 23 + 20)*0.5, 23, 23);
            }
            
            [self resetViewFrame];
            self.loadingImageView.center = self.view.center;
        }
            break;
        default:
            break;
    }
}

- (void)showHideTopBottomViewAction
{
    
    if (!self.isShowTool)
    {
        [self showTopBottomView];
    }
    else
    {
        [self hideTopBottomView];
    }
}

- (void)showTopBottomView
{
    self.isShowTool = YES;
    JFG_WS(weakSelf);
    
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat bottomHeight = 0;
        CGFloat topHeight = 0;
        
        if (weakSelf.isLandScape)
        {
            weakSelf.bottomBgView.top = kheight - weakSelf.bottomBgView.height;
            weakSelf.topBgView.bottom = weakSelf.topBgView.height;
        }
        else
        {
            bottomHeight = 64.0;
            topHeight = 80.0;
            
            weakSelf.bottomBgView.top = kheight - bottomHeight;
            weakSelf.topBgView.bottom = topHeight - 20.0;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideTopBottomView
{
    // 不管怎样， 全屏隐藏 状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    self.isShowTool = NO;
    JFG_WS(weakSelf);
    
    [UIView animateWithDuration:0.2 animations:^{
        if (weakSelf.isLandScape)
        {
//            weakSelf.bottomBgView.right = - weakSelf.bottomBgView.width;
//            weakSelf.topBgView.left = Kwidth;
            weakSelf.bottomBgView.top = kheight;
            weakSelf.topBgView.bottom = 0;
            
        }
        else
        {
            weakSelf.bottomBgView.top = kheight;
            weakSelf.topBgView.bottom = 0;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showTipView:(NSString *)tipMsg
{
    if (self.isLandScape)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [FLProressHUD hideAllHUDForView:window animation:NO delay:0];
        FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
        hud.textLabel.text = tipMsg;
        hud.position = FLProgressHUDPositionCenter;
        hud.showProgressIndicatorView = NO;
        hud.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        [hud showInView:window animated:YES];
        [FLProressHUD hideAllHUDForView:window animation:YES delay:1.5];
    }else{
        [FLProressHUD hideAllHUDForView:self.view animation:NO delay:0];
        FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
        hud.textLabel.text = tipMsg;
        hud.position = FLProgressHUDPositionCenter;
        hud.showProgressIndicatorView = NO;
        [hud showInView:self.view animated:YES];
        [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1.5];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isDownloadComplete
{
    if (self.originType == SourceTypeMSGPhoto)
    {
        return YES;
    }
    else
    {
        NSString *checkSizeURLString = (self.panoModel.urlString == nil)?[NSString stringWithFormat:@"http://192.168.0.1/images/%@",self.panoModel.fileName]:self.panoModel.urlString;
        
        return [self.downloadTool fileIsDownLoadComplete:checkSizeURLString destinationDir:[FileManager jfgPano720PhotoDirPath:self.cid]];
    }
    
    
}

- (TYDownloadModel *)currentDownModel
{
    NSArray *downloadingArr = [self.downloadTool downloadingModels];
    
    for (NSInteger i = 0; i <downloadingArr.count; i ++)
    {
        TYDownloadModel *dlModel = (TYDownloadModel *)[downloadingArr objectAtIndex:i];
        NSString *fileName = [[NSURL URLWithString:dlModel.downloadURL] lastPathComponent];
        if ([fileName isEqualToString:self.panoModel.fileName])
        {
            return dlModel;
        }
    }
    
    return nil;
}


#pragma mark
#pragma mark  action
- (void)moreButtonAction:(UIButton *)sender
{
    if (self.loadingImageView.hidden == YES)
    {
        TYDownloadModel *curDownloadModel = [self currentDownModel];
        NSString *firstTitle = nil;
        
        if ([self isDownloadComplete])
        {
            firstTitle = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_Downloaded"];
        }
        else
        {
            if (curDownloadModel.state == TYDownloadStateRunning)
            {
                firstTitle = [NSString stringWithFormat:@"%02d%%",(int)(curDownloadModel.progress.progress*100)];
            }
            else
            {
                firstTitle = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_Download"];
            }
        }
        
        YBPopupMenu *popupMenu = [YBPopupMenu showAtPoint:CGPointMake(self.moreButton.x, self.topBgView.bottom) titles:@[firstTitle, [JfgLanguage getLanTextStrByKey:@"DELETE"]] icons:@[@"details_icon_down",@"album_icon_delete"] menuWidth:149 delegate:nil];
        self.popUpMenu = popupMenu;
        popupMenu.dismissOnSelected = YES;
        popupMenu.type = YBPopupMenuTypeDark;
        popupMenu.textColor = [UIColor colorWithHexString:@"#ffffff"];
        popupMenu.isShowShadow = YES;
        popupMenu.delegate = self;
        popupMenu.offset = 2;
        popupMenu.firstCellCanClicked = ![self isDownloadComplete];
        popupMenu.secondCellCanClicked = YES;
        
        
        JFG_WS(weakSelf);
        if (progressTimer == nil)
        {
            progressTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1.0 block:^(NSTimer *timer) {
                if ([weakSelf currentDownModel].state == TYDownloadStateRunning)
                {
                    int progressValue = (int)([weakSelf currentDownModel].progress.progress*100.0);
                    if (progressValue != 0)
                    {
                        [weakSelf.popUpMenu setRows:@[[NSString stringWithFormat:@"%02d%%",progressValue], [JfgLanguage getLanTextStrByKey:@"DELETE"]]];
                    }
                    
                    if (progressValue == 100)
                    {
                        [progressTimer invalidate];
                        progressTimer = nil;
                    }
                    
                    JFGLog(@"progress value -- %d",     progressValue);
                }
                
            } repeats:YES];
        }
        
    }
}

- (void)leftButtonAction:(UIButton *)sender
{
    JFGLog(@"leftButtonAciton work ");
    
    if ([self forceRecoverToPortrait])
    {
        return;
    }
    supportDirection = DeviceDirectionTypePortrait;
    
    if (progressTimer && [progressTimer isValid]) {
        [progressTimer invalidate];
        progressTimer = nil;
    }
    [super leftButtonAction:sender];
    
    [self.panoPlayer stopPlay];
}

- (void)modelButtonAction:(UIButton *)sender
{
    if (self.loadingImageView.hidden == NO)
    {
        return;
    }
    
    if (sender == self.vrModelButton)
    {
        [self vrModelButtonAction:self.vrModelButton];
    }
    else if (sender == self.tlyModelButton)
    {
        self.tlyModelButton.selected = !self.tlyModelButton.selected;
        [self.pano720View enableGyro:self.tlyModelButton.selected];
    }
    else if (sender == self.scanModelButton)
    {
        [self scanModeButtonAction:self.scanModelButton];
    }
    
}

- (void)vrModelButtonAction:(UIButton *)sender
{
    self.vrModelButton.selected = !self.vrModelButton.selected;
    [self.pano720View enableGyro:self.vrModelButton.selected];
    [self.pano720View enableVRMode:self.vrModelButton.selected];
    [self forceRecoverToLandScape];
    supportDirection = self.vrModelButton.selected?DeviceDirectionTypeLandScape:DeviceDirectionTypeALL;
    
    self.tlyModelButton.selected = self.vrModelButton.selected;
    
    self.tlyModelButton.enabled = self.scanModelButton.enabled = !self.vrModelButton.selected;
    
    
    if (self.vrModelButton.selected == YES)
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:isAlreadyShowTip])
        {
            [self.devOriention startMonitor];
            
            [self.view addSubview:self.tipView];
            self.tipView.transform = CGAffineTransformRotate(self.tipView.transform, M_PI_2);
            self.tipView.frame = CGRectMake(0, 0, Kwidth, kheight);
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isAlreadyShowTip];
        }
        
        [self.tlyModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_gyroscope"] forState:UIControlStateNormal];
        self.tlyModelButton.enabled = NO;
        
        [self.scanModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_panorama"] forState:UIControlStateNormal];
        self.scanModelButton.enabled = NO;
    }
    else
    {
        [self.tlyModelButton setBackgroundImage:[UIImage imageNamed:@"video_icon_manual"] forState:UIControlStateNormal];
        [self.tlyModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_gyroscope"] forState:UIControlStateSelected];
        self.tlyModelButton.enabled = YES;
        
        self.scanModelButton.enabled = YES;
        [self.scanModelButton setBackgroundImage:[UIImage imageNamed:@"video_icon_fisheye"] forState:UIControlStateNormal];
        [self.pano720View setDisplayMode:DM_Fisheye];
        self.clickTimes = 0;
    }
    
    if (self.isLandScape == NO)
    {
        self.isLandScape = YES;
        [self screenDiretionChanged:self.isLandScape isAnimation:YES];
    }
}

- (void)scanModeButtonAction:(UIButton *)sender
{
    DFDisplayMode watchModel = DM_Equirectangular;
    int switchCase = self.clickTimes%3;
    NSString *imageName = @"video_icon_fisheye"; // default
    
    switch (switchCase)
    {
        case 0:
        {
            watchModel = DM_Panorama;
            imageName = @"photos_icon_panorama";
            
        }
            break;
        case 1:
        {
            watchModel = DM_LittlePlanet;
            imageName = @"video_icon_asteroid";
        }
            break;
        case 2:
        {
            
            watchModel = DM_Fisheye;
            imageName = @"video_icon_fisheye";
        }
            break;
        default:
            break;
    }
    
    [self.scanModelButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self.pano720View setDisplayMode:watchModel];
    self.clickTimes ++;
}

- (void)removeTipView:(UIButton *)sender
{
    if (self.tipView != nil)
    {
        [self.tipView removeFromSuperview];
        [self.devOriention stop];
    }
}

#pragma mark
- (void)showSDCardPullOutAlert
{
    JFG_WS(weakSelf);
    
    [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
        if (![weakSelf isDownloadComplete])
        {
            [weakSelf leftButtonAction:nil];
        }
    } OKBlock:nil];
}

#pragma mark
- (void)shareButtonAction:(UIButton *)sender
{
    if (self.loadingImageView.hidden == NO)
    {
        return;
    }
    
    // without network
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess)
    {
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    
    switch (self.panoMediaType)
    {
        case mediaTypeVideo:
        {
            NSString *fileName = self.panoModel.fileName;
            NSInteger duration = 0;
            
            if (fileName != nil && ![fileName isEqualToString:@""])
            {
                NSString *name = [fileName stringByDeletingPathExtension];
                NSArray *times = [name componentsSeparatedByString:@"_"];
                if (times.count > 1)
                {
                    duration = [[times objectAtIndex:1] integerValue];
                }
            }
            
            if (duration > 8)
            {
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Share_NoLonger8STips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                
                return;
            }
            
            if (![self isDownloadComplete])
            {
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Download_Then_Share"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                
                return;
            }
            
        }
            break;
            
        default:
            break;
    }
    
    JFG_WS(weakself);
    ShareView *share = [[ShareView alloc] initWithLandScape:self.isLandScape];
    [share showShareView:^(SSDKPlatformType sType) {
        
        if (sType == SSDKPlatformSubTypeWechatSession || sType == SSDKPlatformSubTypeWechatTimeline) {
            if (![ShareSDK isClientInstalled:sType]) {
                NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],[JfgLanguage getLanTextStrByKey:@"WeChat"]];
                [ProgressHUD showText:als];
                return;
            }
            
        }else if (sType == SSDKPlatformSubTypeQQFriend || sType == SSDKPlatformSubTypeQZone){
            if (![ShareSDK isClientInstalled:sType]) {
                NSString *als = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap0_Login_NoInstalled"],@"QQ"];
                [ProgressHUD showText:als];
                return;
            }
        }
        
        
        
        ShareVideoViewController *shareVC = [[ShareVideoViewController alloc] init];
        shareVC.cid = weakself.cid;
        shareVC.devAlias = weakself.nickName;
        shareVC.filePath = weakself.panoMediaPath;
        shareVC.thumbImage = weakself.thumbNailImage;
        shareVC.platformType = sType;
        [weakself.navigationController pushViewController:shareVC animated:YES];
        
    } cancel:^{
        
    }];
}

- (void)photoButtonAction:(UIButton *)sender
{
    if (self.loadingImageView.hidden == NO)
    {
        return;
    }
    
    UIImage *cuttedImage = [self.pano720View takeSnapshot];
    JFG_WS(weakSelf);
    
    [JFGAlbumManager jfgWriteImage:cuttedImage toPhotosAlbum:nil completionHandler:^(UIImage *image, NSError *error) {
        if (error == nil) {
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"]];
            
            /*
            if (weakSelf.isLandScape) {
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                [FLProressHUD hideAllHUDForView:window animation:NO delay:0];
                FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
                hud.textLabel.text = [JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"];
                hud.position = FLProgressHUDPositionCenter;
                hud.showProgressIndicatorView = NO;
                hud.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
                [hud showInView:window animated:YES];
                [FLProressHUD hideAllHUDForView:window animation:YES delay:1.5];
            }else{
                [FLProressHUD hideAllHUDForView:weakSelf.view animation:NO delay:0];
                FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
                hud.textLabel.text = [JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"];
                hud.position = FLProgressHUDPositionCenter;
                hud.showProgressIndicatorView = NO;
                [hud showInView:weakSelf.view animated:YES];
                [FLProressHUD hideAllHUDForView:weakSelf.view animation:YES delay:1.5];
                //[ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"]];
            }
            */
        }
    }];
    
    
}

- (void)playButtonAction:(UIButton *)sender
{
    if (self.loadingImageView.hidden == NO)
    {
        return;
    }
    
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [self.panoPlayer resume];
    }
    else
    {
        [self.panoPlayer pause];
    }
    
}

- (void)play
{
    if ([self isDownloadComplete])
    {
        [self.panoPlayer playForUrl:self.panoMediaPath];
        
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"play filePath: %@", self.panoMediaPath]];
    }
    else
    {
        if (self.urlString != nil && ![self.urlString isEqualToString:@""])
        {
            [self.panoPlayer playForUrl:self.urlString];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"play filePath: %@", self.urlString]];
        }
    }
    
    self.loadingImageView.hidden = NO;
}

- (void)seekVideoTime:(UISlider *)slider
{
    if (self.loadingImageView.hidden == NO)
    {
        return;
    }
    
    [self.panoPlayer seekToTime:slider.value * self.videoDuration];
}

#pragma mark
#pragma mark  JFGSDK  delegate
-(void)jfgSDKPlayerReady:(JFGSDKPlayer *)player width:(int)width height:(int)height durationTime:(int)duration
{   
//    self.pano720View.backgroundColor = [UIColor redColor];
//    self.pano720View.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
//    self.pano720View.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*2);
    self.videoDuration = duration;
    int second = self.videoDuration/1000;
    self.timeLabel.text = [NSString stringWithFormat:@"00:00/%02d:%02d",second/60, second%60];
    
    [self.view bringSubviewToFront:self.bottomBgView];
    [self.view bringSubviewToFront:self.topBgView];
    
    [self.panoPlayer startRenderForView:self.pano720View];
}

-(void)jfgSDKPlayerFinished:(JFGSDKPlayer *)player
{
    self.sliderView.value = 1.0;
    
    [self initLoadMedia];
}

-(void)jfgSDKPlayerFailed:(JFGSDKPlayer *)player
{
    JFGLog(@"player fialed ");
    
    if (self.navigationController.visibleViewController == self)
    {
//        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@""]];
    }
    
}

-(void)jfgSDKPlayer:(JFGSDKPlayer *)player progress:(int)progress
{
    self.sliderView.value = progress/self.videoDuration;
    int totalSecond = self.videoDuration/1000;
    int currentSecond = totalSecond * self.sliderView.value;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",currentSecond/60, currentSecond%60, totalSecond/60, totalSecond%60];
    self.loadingImageView.hidden = YES;
}

-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray <DataPointSeg *> *)msgList
{
    JFG_WS(weakSelf);
    
    if ([peer isEqualToString:self.cid])
    {
        @try
        {
            for (DataPointSeg *seg in msgList)
            {
                NSError *error = nil;
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (error == nil)
                {
                    switch (seg.msgId)
                    {
                        case dpMsgBase_SDCardInfoList:
                        {
                            if ([obj isKindOfClass:[NSArray class]])
                            {
                                BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
                                if (isExistSDCard == NO)
                                {
                                    //show hub sdCard was pulled out
                                    [self showSDCardPullOutAlert];
                                }
                                
                            }
                        }
                            break;
                    }
                }
            }
        } @catch (NSException *exception) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jifeigou RootViewControl %@",exception]];
        } @finally {
            
        }
    }
}

// 720 专用
-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                               mSeq:(uint64_t)mSeq
                                                cid:(NSString *)cid
                                               type:(int)type
                                       isInitiative:(BOOL)initiative
                                           dpMsgArr:(NSArray *)dpMsgArr
{
    for (DataPointSeg *seg in dpMsgArr)
    {
        NSError *error = nil;
        id obj = [MPMessagePackReader readData:seg.value error:&error];
        if (error == nil)
        {
            switch (seg.msgId)
            {
                    // SDCard 插拔
                case dpMsgBase_SDStatus:
                {
                    if ([obj isKindOfClass:[NSArray class]])
                    {
                        BOOL isExistSDCard = [[obj objectAtIndex:3] boolValue];
                        if (isExistSDCard == NO)
                        {
                            JFG_WS(weakSelf);
                            // sdCard was pulled out
//                            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
//                                [weakSelf.navigationController popViewControllerAnimated:YES];
//                            } OKBlock:nil];
                            
                            [self showSDCardPullOutAlert];
                            
                        }
                        
                    }
                }
                    break;
            }
        }
    }
}

#pragma mark
#pragma mark  orientation

- (BOOL)forceRecoverToPortrait
{
    if (UIDeviceOrientationIsLandscape((UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation]))
    {
        if (self.vrModelButton.selected == YES) // if vr model were open , close it
        {
            [self modelButtonAction:self.vrModelButton];
        }
        
        [self forceRecoverToDirection:UIDeviceOrientationPortrait];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)forceRecoverToLandScape
{
    if (UIDeviceOrientationIsPortrait((UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation]))
    {
        [self forceRecoverToDirection:UIDeviceOrientationLandscapeRight];
        return YES;
    }
    
    return NO;
}

- (void)forceRecoverToDirection:(UIDeviceOrientation)orientataion
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector             = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = orientataion;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}

//  陀螺仪 判断的旋转
- (void)directionChange:(TgDirection)direction
{
    switch (direction)
    {
        case TgDirectionRight:
        case TgDirectionleft:
        {
            [self removeTipView:nil];
        }
            break;
            
        default:
            break;
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIDeviceOrientationIsPortrait((UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation])) //竖屏
    {
        self.isLandScape = NO;
    }
    else
    {
        self.isLandScape = YES;
    }
    
    [self screenDiretionChanged:self.isLandScape isAnimation:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    switch (toInterfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
        {
            [self.pano720View detectOrientationChange:UIDeviceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        {
            [self.pano720View detectOrientationChange:UIDeviceOrientationLandscapeRight];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            [self.pano720View detectOrientationChange:UIDeviceOrientationLandscapeLeft];
        }
            break;
        default:
            break;
    }

}


#pragma mark
#pragma mark  delegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    if (self.myDelegate != nil)
    {
        switch (index)
        {
            case 0:
            {
                if ([self currentDownModel].state == TYDownloadStateRunning)
                {
                    JFG_WS(weakSelf);
                    [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Album_CancelDownloadTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:nil OKBlock:^{
                            [weakSelf.downloadTool suspendWithDownloadModel:weakSelf.panoModel.urlString];
                    }];
                }
                else
                {
                    if ([self.myDelegate respondsToSelector:@selector(donwloadWithModel:)])
                    {
                        [self.myDelegate donwloadWithModel:self.panoModel];
                    }
                }
                
            }
                break;
            case 1:
            {
                JFG_WS(weakSelf);
                NSString *deleteTitle = nil;
                
                switch (self.originType)
                {
                    case SourceTypeMSGPhoto:
                    {
                        deleteTitle = [JfgLanguage getLanTextStrByKey:@"Tips_SureDelete"];
                    }
                        break;
                        
                    default:
                    {
                        deleteTitle = [JfgLanguage getLanTextStrByKey:@"PHOTO_DELE_POP"];
                    }
                        break;
                }
                
                
                [LSAlertView showAlertWithTitle:deleteTitle Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Sure"] CancelBlock:^{
                    
                } OKBlock:^{
                    if ([weakSelf.myDelegate respondsToSelector:@selector(deleteModelInLocal:)])
                    {
                        [weakSelf.myDelegate deleteModelInLocal:weakSelf.panoModel];
                    }
                    
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }
            default:
                break;
        }
    }
    
}


#pragma mark
#pragma mark  getter

- (UIImageView *)loadingImageView
{
    if (_loadingImageView == nil)
    {
        _loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_loading"]];
        _loadingImageView.frame = CGRectMake(0, 0, 50, 50);
        _loadingImageView.center = self.view.center;
        _loadingImageView.hidden = YES;
        
        //创建旋转动画
        POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
        //线性动画
        baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
        //间隔时间
        baseAnimation.duration = 25;
        //开始角度
        //baseAnimation.fromValue =@(0);
        //结束角度
        baseAnimation.toValue = @(180);
        //是否永远循环执行
        baseAnimation.repeatForever = YES;
        //添加动画
        [_loadingImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
    }
    
    return _loadingImageView;
}

- (JFGSDKPlayer *)panoPlayer
{
    //
    if (_panoPlayer == nil) {
        _panoPlayer = [[JFGSDKPlayer alloc] init];
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
        _topBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
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
        CGFloat width = self.sharedButton.left - self.backButton.right;
        CGFloat height = 17.0;
        CGFloat x = self.backButton.right;
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
        CGFloat x = self.moreButton.left - width - 24;
        CGFloat y = (self.topBgView.height - height + 20)*0.5;
        
        _sharedButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [_sharedButton setBackgroundImage:[UIImage imageNamed:@"details_icon_share"] forState:UIControlStateNormal];
        [_sharedButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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
//        _pano720View.layer.edgeAntialiasingMask = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideTopBottomViewAction)];
        
        [_pano720View addGestureRecognizer:tapGesture];
        
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
        _bottomBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
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
        [_photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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
        [_vrModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_vr_hl"] forState:UIControlStateSelected];
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
        [_scanModelButton setBackgroundImage:[UIImage imageNamed:@"video_icon_fisheye"] forState:UIControlStateNormal];
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
        [_tlyModelButton setBackgroundImage:[UIImage imageNamed:@"video_icon_manual"] forState:UIControlStateNormal];
        [_tlyModelButton setBackgroundImage:[UIImage imageNamed:@"photos_icon_gyroscope"] forState:UIControlStateSelected];
        [_tlyModelButton addTarget:self action:@selector(modelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tlyModelButton;
}

- (UISlider *)sliderView
{
    if (_sliderView == nil)
    {
        CGFloat x = 15;
        CGFloat y = 10;
        CGFloat width = (Kwidth - x - 5);
        CGFloat height = 10;
        
        _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _sliderView.minimumValue = .0f;
        _sliderView.maximumValue = 1.0;
        [_sliderView setMaximumTrackTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2]];
        [_sliderView setMinimumTrackTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_round"] forState:UIControlStateNormal];
        [_sliderView addTarget:self action:@selector(seekVideoTime:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sliderView;
}

- (UIButton *)playButton
{
    if (_playButton == nil)
    {
        CGFloat width = 30;
        CGFloat height = 30;
        CGFloat x = 8;
        CGFloat y = (self.bottomBgView.height - height - 7);
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(x, y, width, height);
        _playButton.selected = YES;
        [_playButton setBackgroundImage:[UIImage imageNamed:@"btn_rightkey_nomal"] forState:UIControlStateNormal];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"btn_rightkey_disabled"] forState:UIControlStateDisabled];
        [_playButton setBackgroundImage:[UIImage imageNamed:@"delaytime_pause"] forState:UIControlStateSelected];
        
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _playButton;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil)
    {
        CGFloat width = 80;
        CGFloat height = 12;
        CGFloat x = self.playButton.right + 5;
        CGFloat y = self.bottomBgView.height - height - 16;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _timeLabel.font = [UIFont systemFontOfSize:height];
        _timeLabel.text = @"00:00/00:00";
        _timeLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    }
    return _timeLabel;
}

- (DownloadUtils *)dlUtils
{
    if (_dlUtils == nil)
    {
        _dlUtils = [[DownloadUtils alloc] init];
        _dlUtils.pType = self.pType;
        [_dlUtils setDirectory:[FileManager jfgPano720PhotoDirPath:self.cid]];
    }
    
    return _dlUtils;
}

- (JFGDownLoadTool *)downloadTool
{
    if (_downloadTool == nil)
    {
        _downloadTool = [[JFGDownLoadTool alloc] init];
    }
    return _downloadTool;
}

- (UIView *)tipView
{
    if (_tipView == nil)
    {
        _tipView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        _tipView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kheight - 107)*0.5, 244.5, 107, 90)];
        iconImageView.image = [UIImage imageNamed:@"pop_pic_vr_tips"];
        [_tipView addSubview:iconImageView];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconImageView.bottom + 15.0, kheight, 16.0)];
        tipLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_PutInVR"];
        tipLabel.font = [UIFont systemFontOfSize:16.0];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor whiteColor];
        [_tipView addSubview:tipLabel];
        
        UIButton *closeTipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeTipButton setBackgroundImage:[UIImage imageNamed:@"album_btn_close"] forState:UIControlStateNormal];
        closeTipButton.frame = CGRectMake(kheight - 16.5 - 17, 61.0, 16.5, 16.5);
        [closeTipButton addTarget:self action:@selector(removeTipView:) forControlEvents:UIControlEventTouchUpInside];
        [_tipView addSubview:closeTipButton];
    }
    
    return _tipView;
}

- (DeviceOrientation *)devOriention
{
    if (_devOriention == nil)
    {
        _devOriention = [[DeviceOrientation alloc] initWithDelegate:self];
    }
    
    return _devOriention;
}

@end
