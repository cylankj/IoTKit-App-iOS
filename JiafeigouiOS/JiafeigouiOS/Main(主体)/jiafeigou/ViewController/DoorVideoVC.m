//
//  DoorVideoVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DoorVideoVC.h"
#import "DoorVideoSrollView.h"
#import "JfgConstKey.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/CylanJFGSDK.h>
#import "JfgGlobal.h"
#import "UIImageView+WebCache.h"
#import "LoginManager.h"
#import "OemManager.h"
#import <POP.h>
#import "VideoSnapImageView.h"
#import "LSAlertView.h"
#import "UIAlertView+FLExtension.h"
#import "ProgressHUD.h"
#import "CommonMethod.h"
#import "JFGAlbumManager.h"
#import "JFGEquipmentAuthority.h"
#import "UIImageView+JFGImageView.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "JfgConfig.h"
#import "JfgTypeDefine.h"
#import "JfgMsgDefine.h"
#import "JFGBoundDevicesMsg.h"
#import <AVFoundation/AVFoundation.h>
#import "UIAlertView+FLExtension.h"
#import "LoginManager.h"
#import <SDWebImageDownloader.h>
#import "UpgradeDeviceVC.h"
#import "FLProressHUD.h"

@interface DoorVideoVC ()<JFGSDKPlayVideoDelegate, JFGSDKCallbackDelegate>
{
    CGRect doorScrollRect;// 记录 竖屏位置
    BOOL _isFullScreen;
    
    CGSize videoSize; // 记录 下发的 屏幕分辨率
    
    BOOL isConnected;
    BOOL isStartTimer;
    
    int imageResetCount;
    
    BOOL isLowSpeed;
    
    BOOL isDidApper;
}

@property (nonatomic, strong)DoorVideoSrollView *doorVideoScrollView;
@property (retain, nonatomic) AVAudioPlayer *avAudioPlayer;

#pragma mark 主动
/**
 *  挂断 按钮
 */
@property (nonatomic, strong) UIButton *holdOnButton;
/**
 *  拍照 按钮
 */
@property (nonatomic, strong) UIButton *cameraButton;
/**
 *  声音 按钮
 */
@property (nonatomic, strong) UIButton *voiceButton;

#pragma mark 被动
/**
 *  门铃 图片
 */
@property (nonatomic, strong) UIImageView *doorBellImageView;

/**
 *  大红点 透明 背景
 */
@property (nonatomic, strong) UIImageView *redDotBgImageView;
/**
 *  左边 大红点 图片
 */
@property (nonatomic, strong) UIImageView *redDotImageView;

/**
 *  右边 大绿点 背景
 */
@property (nonatomic, strong) UIImageView *greenDotBgImageView;
/**
 *  右边 大绿点  图片
 */
@property (nonatomic, strong) UIImageView *greenDotImageView;

/**
 *  左边 小红点 图片
 */
@property (nonatomic, strong) UIImageView *litteRedDot;
/**
 *  有边 小绿点 图片
 */
@property (nonatomic, strong) UIImageView *litteGreenDot;

@property (nonatomic,strong)VideoSnapImageView *snapImageView;

@property (nonatomic,strong)UIImageView *loadingImageView;

@property (nonatomic,strong)UIView *snapAnimationView;


#pragma mark  竖屏
/**
 *  流量速度 Button 有背景所以用Button
 */
@property (nonatomic, strong) UIButton *flowSpeedButton;
/**
 *  上方遮罩 ImageView
 */
@property (nonatomic, strong) UIImageView *shadeImageView;
/**
 *  下方遮罩 ImageView
 */
@property (nonatomic, strong) UIImageView *bottomShadeImageView;
/**
 *  全屏 按钮
 */
@property (nonatomic, strong) UIButton *fullScreenButton;

#pragma mark  横屏
/**
 *  竖屏 按钮
 */
@property (nonatomic, strong) UIButton *halfScreenButton;
/**
 *  标题 名字
 */
@property (nonatomic, strong) UILabel *nickNameLabel;

@end

@implementation DoorVideoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initNavigationView];
    [JFGSDK addDelegate:self];
    [self playMusic];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delDeviceNotification:) name:JFGDeviceDelByOtherClientNotification object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGDoorBellIsCallingKey];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    isDidApper = YES;
    
    [self jfgFpingRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addVideoNotifacation];
    [self setNeedsStatusBarAppearanceUpdate];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopMusic];
    [[NSUserDefaults standardUserDefaults] setObject:self.cid forKey:JFGDoorBellIsPlayingCid];
   
}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self videoCancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:JFGDoorBellIsCallingKey];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:JFGDoorBellIsPlayingCid];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    isDidApper = NO;
    [JFGSDK removeDelegate:self];
}

-(void)applicationDidEnterBackground
{
    [self leftButtonAction:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addVideoNotifacation
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onRecvDisconnectForRemote:) name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    
    //a
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotifyResolution:) name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotificatyRTCP:) name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)delDeviceNotification:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSString *cid = dict[@"cid"];
    if ([cid isEqualToString:self.cid]) {
        
        [CommonMethod delDeviceByOtherClientWithNotification:notification cid:self.cid superViweController:self];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playOuttime) object:nil];
        if (isConnected) {
            [self videoCancel];
        }
        
    }
}

#pragma mark view

- (void)initView
{
    [self.view addSubview:self.doorVideoScrollView];
    [self.view addSubview:self.shadeImageView];
    [self.view addSubview:self.bottomShadeImageView];
    [self.view addSubview:self.fullScreenButton];
    
    [self.view addSubview:self.halfScreenButton];
    [self.view addSubview:self.nickNameLabel];
    [self.view addSubview:self.flowSpeedButton];
    [self layoutVideoView];
    NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    for (JiafeigouDevStatuModel *model in list) {
        if ([model.uuid isEqualToString:self.cid]) {
            self.nickName = model.alias;
            break;
        }
    }
    
    if (self.nickName) {
        self.nickNameLabel.text = self.nickName;
    }else{
        self.nickNameLabel.text = self.cid;
    }
    [self.doorVideoScrollView addSubview:self.snapImageView];
    [self.doorVideoScrollView sendSubviewToBack:self.snapImageView];
    
    if (self.imageUrl &&![self.imageUrl isEqualToString:@""]) {
        self.snapImageView.image = [UIImage imageNamed:@"camera_bg"];
        imageResetCount = 0;
        if (self.actionType == doorActionTypeActive) {
            //[self resetHeadImageViewForUrl:[NSURL URLWithString:self.imageUrl]];
            UIImage *Image = [self cacheSnapImage];
            if (Image) {
                self.snapImageView.image = Image;
            }
            
        }else{
            
            int64_t delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                if (isDidApper) {
                    [self resetHeadImageViewForUrl:[NSURL URLWithString:self.imageUrl]];
                }
                
            });
        }
        
        
        
    }else{
        
        [JFGSDK appendStringToLogFile:@"门铃截图链接不存在"];
        UIImage *image = [self cacheSnapImage];
        if (image) {
            self.snapImageView.image = image;
        }else{
            self.snapImageView.image = [UIImage imageNamed:@"camera_bg"];
        }
        
    }

    if (self.actionType == doorActionTypeActive){
        [self initActionView];
    }else{
        [self initUnActionView];
    }
    self.fullScreenButton.hidden = YES;
}


-(void)resetHeadImageViewForUrl:(NSURL *)url
{
    //NSLog(@"%@",url);
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        if (error) {
            
            if (imageResetCount < 10) {
                
                int64_t delayInSeconds = 2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self resetHeadImageViewForUrl:imageURL];
                    
                });
                imageResetCount ++;
                
            }
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"门铃截图加载失败:%@",[error description]]];
        }else{
            
            self.snapImageView.image = image;
        }
        
    }];
    
//    [self.snapImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"camera_bg"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        
//        
//    }];
}

- (void)initNavigationView
{
    self.navigationView.hidden = YES;
}

- (void)initActionView
{
    if (self.holdOnButton.superview == nil)
    {
        [self.view addSubview:self.holdOnButton];
    }
    
    if (self.voiceButton.superview == nil)
    {
        [self.view addSubview:self.voiceButton];
    }
    
    if (self.cameraButton.superview == nil)
    {
        [self.view addSubview:self.cameraButton];
    }
    
    [self videoCall];
    [self startLodingAnimation];
    [self performSelector:@selector(playOuttime) withObject:nil afterDelay:30];
    isStartTimer = YES;
}

- (void)initUnActionView
{
    if (self.doorBellImageView.superview == nil)
    {
        [self.view addSubview:self.doorBellImageView];
    }
    
    if (self.redDotBgImageView.superview == nil)
    {
        [self.view addSubview:self.redDotBgImageView];
    }
    if (self.redDotImageView.superview == nil)
    {
        [self.view addSubview:self.redDotImageView];
    }
    if (self.greenDotBgImageView.superview == nil)
    {
        [self.view addSubview:self.greenDotBgImageView];
    }
    if (self.greenDotImageView.superview == nil)
    {
        [self.view addSubview:self.greenDotImageView];
    }
    
    if (self.litteGreenDot.superview == nil)
    {
        [self.view addSubview:self.litteGreenDot];
    }
    if (self.litteRedDot.superview == nil)
    {
        [self.view addSubview:self.litteRedDot];
    }
    [self performSelector:@selector(callTimeout) withObject:nil afterDelay:30];
    
}

-(void)callTimeout
{
    [JFGSDK refreshDeviceList];
    [self leftButtonAction:nil];
}


- (void)removeUnActionView
{
    if (self.doorBellImageView.superview != nil)
    {
        [self.doorBellImageView removeFromSuperview];
    }
    
    if (self.redDotBgImageView.superview != nil)
    {
        [self.redDotBgImageView removeFromSuperview];
    }
    if (self.redDotImageView.superview != nil)
    {
        [self.redDotImageView removeFromSuperview];
    }
    if (self.greenDotBgImageView.superview != nil)
    {
        [self.greenDotBgImageView removeFromSuperview];
    }
    if (self.greenDotImageView.superview != nil)
    {
        [self.greenDotImageView removeFromSuperview];
    }
    
    if (self.litteGreenDot.superview != nil)
    {
        [self.litteGreenDot removeFromSuperview];
    }
    if (self.litteRedDot.superview != nil)
    {
        [self.litteRedDot removeFromSuperview];
    }
}

- (void)updateFrame:(BOOL)isFullScreen
{
    if (isFullScreen)
    {
        self.holdOnButton.frame = CGRectMake((Kwidth - 66.0)*0.5, kheight - 66 - 20, 66, 66);
        [self.holdOnButton setImage:[UIImage imageNamed:@"door_holdon_full"] forState:UIControlStateNormal];//door_talkdisable_full
        self.holdOnButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        self.cameraButton.frame = CGRectMake(self.holdOnButton.right + 28, kheight - 66 - 20, 66, 66);
        [self.cameraButton setImage:[UIImage imageNamed:@"door_camera_full"] forState:UIControlStateNormal];
        self.cameraButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        self.voiceButton.frame = CGRectMake(self.holdOnButton.left - 28 - 66, kheight - 66 - 20, 66, 66);
        self.voiceButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        [self.voiceButton setImage:[UIImage imageNamed:@"door_talk_enable_full"] forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"door_talk_disable_full"] forState:UIControlStateSelected];
    }
    else
    {
        self.holdOnButton.frame = CGRectMake((Kwidth - 80.0)*0.5, doorScrollRect.size.height + 0.17*kheight, 80, 80);
        [self.holdOnButton setImage:[UIImage imageNamed:@"door_holdon"] forState:UIControlStateNormal];
        self.holdOnButton.transform = CGAffineTransformIdentity;
        
        self.cameraButton.frame = CGRectMake(45, self.holdOnButton.top + (self.holdOnButton.height - 50)*0.5, 50, 50);
        [self.cameraButton setImage:[UIImage imageNamed:@"camera_icon_takepic"] forState:UIControlStateNormal];
        [self.cameraButton setImage:[UIImage imageNamed:@"camera_icon_takepic"] forState:UIControlStateSelected];
        self.cameraButton.transform = CGAffineTransformIdentity;
        
        self.voiceButton.frame = CGRectMake(Kwidth - 50 - 45, self.holdOnButton.top + (self.holdOnButton.height - 50)*0.5, 50, 50);
        [self.voiceButton setImage:[UIImage imageNamed:@"door_talk_enable"] forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"door_talk_disable"] forState:UIControlStateSelected];
        self.voiceButton.transform = CGAffineTransformIdentity;
    }
}

#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [self videoCancel];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playOuttime) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callTimeout) object:nil];
    if (self.navigationController.viewControllers.count > 1) // 如果 堆栈有，就pop
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else // 堆栈 为空 模态返回
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    
}

-(void)voiceAction:(UIButton *)sender
{
    if (sender.selected) {
        //打开
        if ([JFGEquipmentAuthority canRecordPermission]) {
            [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:YES];
            [CylanJFGSDK setAudio:YES openMic:YES openSpeaker:YES];
            sender.selected = !sender.selected;
        }
       
    }else{
        [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
        [CylanJFGSDK setAudio:YES openMic:NO openSpeaker:YES];
        sender.selected = !sender.selected;
    }
    
}

#pragma mark
#pragma mark ------ music ---------
- (void)playMusic
{
    if (self.actionType == doorActionTypeUnActive)
    {
        NSError *bellVoiceError = nil;
        NSString *bellVoicePath = [[NSBundle mainBundle] pathForResource:@"apns" ofType:@"caf"];
        
        if (bellVoicePath)
        {
            if (!self.avAudioPlayer)
            {
                self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:bellVoicePath] error:&bellVoiceError];
                self.avAudioPlayer.numberOfLoops = 7;
                if (bellVoiceError) {
                    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"bell Play Voice Error :%@",bellVoiceError]];
                }
                if ([self.avAudioPlayer prepareToPlay])
                {
                    [self.avAudioPlayer play];
                    [JFGSDK appendStringToLogFile:@"audio play"];
                }
            }
        }
        else
        {
            
        }
    }
}

- (void)stopMusic
{
    if (self.avAudioPlayer)
    {
        if ([self.avAudioPlayer isPlaying])
        {
            [self.avAudioPlayer stop];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"stopped music" ]];
        }
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
}

#pragma mark- 全屏切换

- (void)layoutVideoView
{
    if (_isFullScreen)
    {
        self.fullScreenButton.hidden = YES;
        self.bottomShadeImageView.hidden = YES;
        self.halfScreenButton.hidden = NO;
        self.nickNameLabel.hidden = NO;
        
        [self.view bringSubviewToFront:self.halfScreenButton];
        [self.view bringSubviewToFront:self.nickNameLabel];
        
        self.halfScreenButton.frame = CGRectMake(self.view.width-10-self.halfScreenButton.width, 10, self.halfScreenButton.width, self.halfScreenButton.height);
        self.nickNameLabel.frame = CGRectMake(self.view.width-10-self.halfScreenButton.width, 10+self.halfScreenButton.height, 30, 300);
        
        self.flowSpeedButton.frame = CGRectMake(self.view.width - 15 - self.flowSpeedButton.width, self.view.height-15-self.flowSpeedButton.height, self.flowSpeedButton.width, self.flowSpeedButton.height);
        
        self.shadeImageView.frame = CGRectMake(0, 0, self.doorVideoScrollView.height, 60);
        
        //scroller滚动，改变坐标使其相对静止
//        self.nickNameLabel.top = contentOffset.y+10;
//        self.halfScreenButton.top = contentOffset.y+10;
//        self.flowSpeedButton.top = contentOffset.y+15;
        
    }
    else
    {
        self.fullScreenButton.hidden = NO;
        self.bottomShadeImageView.hidden = NO;
        //        self.halfScreenButton.hidden = YES;
        self.nickNameLabel.hidden = YES;
        
        self.halfScreenButton.frame = CGRectMake(10, 34, self.halfScreenButton.width, self.halfScreenButton.height);
        self.flowSpeedButton.frame = CGRectMake(self.doorVideoScrollView.width - 15 - self.flowSpeedButton.width,  20 + 15, self.flowSpeedButton.width, self.flowSpeedButton.height);
        self.fullScreenButton.frame = CGRectMake(self.doorVideoScrollView.width - 12 - self.fullScreenButton.width, self.doorVideoScrollView.height - self.fullScreenButton.height, self.fullScreenButton.width, self.fullScreenButton.height);
        self.shadeImageView.frame = CGRectMake(0, 0, self.doorVideoScrollView.width, 60);
        self.bottomShadeImageView.frame = CGRectMake(0, self.doorVideoScrollView.height - self.bottomShadeImageView.height, self.doorVideoScrollView.width, self.bottomShadeImageView.height);
    }
    
}

// 旋转屏幕 到 横屏
- (void)rotateScreen
{
    if (!isConnected) {
        return;
    }
    //[self.doorVideoScrollView setZoomScale:1];
    //[self remoteViewSizeFit];
    
    _isFullScreen = YES;
    
    if (self.doorVideoScrollView.isFullScreen == YES)
    {
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.doorVideoScrollView.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        self.halfScreenButton.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        self.nickNameLabel.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        self.flowSpeedButton.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        self.doorVideoScrollView.frame = CGRectMake(0, 0, Kwidth, kheight);
        self.doorVideoScrollView.isFullScreen = YES;
        
        
        [self updateFrame:_isFullScreen];
        [self layoutVideoView];
        [self zoomScale];
        
        
    } completion:^(BOOL finished) {
        
    }];
   
}
/**
 *  恢复 到 竖屏
 */
- (void)recoverScreen
{
    //[self.doorVideoScrollView setZoomScale:1];
    //[self remoteViewSizeFit];
    
    _isFullScreen = NO;
    if (self.doorVideoScrollView.isFullScreen == NO)
    {
        [self leftButtonAction:nil];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        
        self.doorVideoScrollView.transform = CGAffineTransformIdentity;
        self.halfScreenButton.transform = CGAffineTransformIdentity;
        self.nickNameLabel.transform = CGAffineTransformIdentity;
        self.flowSpeedButton.transform = CGAffineTransformIdentity;
        self.doorVideoScrollView.isFullScreen = NO;
        self.doorVideoScrollView.frame = doorScrollRect;
        [self updateFrame:_isFullScreen];
        [self layoutVideoView];
        [self zoomScale];
        
    } completion:^(BOOL finished) {

    }];
}

- (void)moveDoorBellAction:(UIPanGestureRecognizer*)paramSender
{
    CGFloat distanceFromRed = fabs(self.doorBellImageView.center.x - self.redDotImageView.center.x);
    CGFloat zeroDistanceRed = (self.doorBellImageView.width + self.redDotImageView.width)*0.5; // 临界值 需要做处理
    
    CGFloat distanceFromGreen = fabs(self.doorBellImageView.center.x - self.greenDotImageView.center.x);
    CGFloat zeroDistanceGreen = (self.doorBellImageView.width + self.redDotImageView.width)*0.5; // 临界值
    
    switch (paramSender.state)
    {
        case UIGestureRecognizerStateBegan:
            [CylanJFGSDK setAudio:NO openMic:NO openSpeaker:NO];
            [CylanJFGSDK setAudio:YES openMic:NO openSpeaker:NO];
        {
            self.litteRedDot.hidden = YES;
            self.litteGreenDot.hidden = YES;
            [self stopSharkAnimation];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [paramSender locationInView:paramSender.view.superview];
            CGRect insideRect = CGRectMake(0, doorScrollRect.size.height + self.doorBellImageView.height*0.5, Kwidth, kheight - doorScrollRect.size.height); // 显示 门铃那张图片的 移动范围
            
            if (CGRectContainsPoint(insideRect, location))
            {
                paramSender.view.center = location;
            }
            
            if (CGRectIntersectsRect(self.greenDotBgImageView.frame, self.doorBellImageView.frame))
            {
                if (distanceFromGreen < zeroDistanceGreen) // 判断 是否靠近 绿点
                {
                    CGFloat greenScaleSize = 3.0*(1-distanceFromGreen/zeroDistanceGreen) + 1.0 ;// +1 是原本比例
                    self.greenDotBgImageView.transform = CGAffineTransformMakeScale(greenScaleSize, greenScaleSize);
                }
            }
            else if (CGRectIntersectsRect(self.doorBellImageView.frame, self.redDotBgImageView.frame))
            {
                CGFloat redScaleSize = 3.0*(1-distanceFromRed/zeroDistanceRed) + 1.0 ;// +1 是原本比例
                self.redDotBgImageView.transform = CGAffineTransformMakeScale(redScaleSize, redScaleSize);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (CGRectIntersectsRect(self.greenDotBgImageView.frame, self.doorBellImageView.frame))
            {
                [self removeUnActionView];
                [self initActionView];
            }
            else if (CGRectIntersectsRect(self.doorBellImageView.frame, self.redDotBgImageView.frame))
            {
                [self leftButtonAction:nil];
            }
            else
            {
                self.litteGreenDot.hidden = NO;
                self.litteRedDot.hidden = NO;
                
                self.redDotBgImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.greenDotImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                self.doorBellImageView.frame = CGRectMake((Kwidth - 80)*0.5, doorScrollRect.size.height + kheight *0.17 , 80, 80);
                [self startSharkAnimation];
            }
        }
            break;
            
        default:
            break;
    }

}

#pragma mark SDK action
- (void)videoCall
{
    [CylanJFGSDK connectCamera:self.cid];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callTimeout) object:nil];
    [self stopMusic];
}

- (void)videoCancel
{
    UIImage *Image = [CylanJFGSDK imageForSnapshot];
    [CylanJFGSDK stopRenderView:NO withCid:self.cid];
    [CylanJFGSDK disconnectVideo:@""];
    UIView *remoteView = [self.doorVideoScrollView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        [remoteView removeFromSuperview];
        remoteView = nil;
    }
    isConnected = NO;
    self.fullScreenButton.hidden = YES;
    [self saveSnapImage:Image];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playOuttime) object:nil];
    
}

-(void)saveSnapImage:(UIImage *)snapImage
{
    NSData *imageData = UIImagePNGRepresentation(snapImage);
    if ([imageData isKindOfClass:[NSData class]]) {
        imageData = UIImageJPEGRepresentation(snapImage, 1);
    }else{
        return;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self snapImagePath]];
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[self snapImagePath]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(UIImage *)cacheSnapImage
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[self snapImagePath]];
    UIImage *Image = [UIImage imageWithData:data];
   
    return Image;
}

-(NSString *)snapImagePath
{
    NSString *key = [NSString stringWithFormat:@"snapImage_%@",self.cid];
    return key;
}

#pragma mark animation
NSString *sharkAnimationKey = @"sharkAnimation";

- (void)startSharkAnimation
{
    CABasicAnimation* sharkFast = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    sharkFast.fromValue = [NSNumber numberWithFloat:-0.3];
    sharkFast.toValue = [NSNumber numberWithFloat:+0.3];
    sharkFast.duration = 0.1;
    sharkFast.autoreverses = YES; //是否重复
    sharkFast.repeatDuration = 30.f;
    [_doorBellImageView.layer addAnimation:sharkFast forKey:sharkAnimationKey];
}

- (void)stopSharkAnimation
{
    [self.doorBellImageView.layer removeAnimationForKey:sharkAnimationKey];
}

// 适配 view
- (void)zoomScale
{
    if (_isFullScreen == NO) // 非全屏
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    else // 全屏
    {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    
    [self remoteViewSizeFit];
}


#pragma mark JFG SDK Delegate

-(void)jfgDeviceList:(NSArray<JFGSDKDevice *> *)deviceList
{
    if (self.actionType == doorActionTypeActive) {
        return;
    }
    
    BOOL isExist = NO;
    for (JFGSDKDevice *dev in deviceList) {
        if ([dev.uuid isEqualToString:self.cid]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        
        NSArray *delCidArr =  [JFGBoundDevicesMsg sharedDeciceMsg].delDeviceList;
        for (NSString *cid in delCidArr) {
            if ([cid isEqualToString:self.cid]) {
                return;
            }
        }
        
        JFGSDKDevice *_dev = [deviceList lastObject];
        self.cid = _dev.uuid;
        NSString *str = [JfgLanguage getLanTextStrByKey:@"Tap1_device_deleted"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:str delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } otherDelegate:nil];
        
    }
}

-(void)onNotifyResolution:(NSNotification *)notification
{
    
    NSDictionary *dict = notification.object;
    if (dict) {
    
        int width = [[dict objectForKey:@"width"] intValue];
        int height = [[dict objectForKey:@"height"] intValue];
        
        CGSize size = CGSizeMake(width, height);
        UIView *remoteView = [self.doorVideoScrollView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        if (!remoteView) {
            [LSAlertView disMiss]; // 防止 联通 弹框还存在
            remoteView = [[VideoRenderIosView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            remoteView.tag = VIEW_REMOTERENDE_VIEW_TAG;
            remoteView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.5];
            remoteView.layer.edgeAntialiasingMask = YES;
           
            [self.doorVideoScrollView addSubview:remoteView];
           
            [CylanJFGSDK startRenderRemoteView:remoteView];
            
            //延迟操作是为了缓解卡顿现象
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
                [CylanJFGSDK setAudio:YES openMic:NO openSpeaker:YES];
                
            });
            
            
        }
    
        //[self stopLoadingAnimation];
        [self.doorVideoScrollView bringSubviewToFront:remoteView];
//        [self.doorVideoScrollView bringSubviewToFront:self.doorVideoScrollView.flowSpeedButton];
//        [self.doorVideoScrollView bringSubviewToFront:self.doorVideoScrollView.fullScreenButton];
//        [self.doorVideoScrollView insertSubview:remoteView belowSubview:self.doorVideoScrollView.shadeImageView];
        self.voiceButton.enabled = YES;
        self.cameraButton.enabled = YES;
        self.fullScreenButton.hidden = NO;
        videoSize = CGSizeMake(width, height);
        isConnected = YES;
        [self remoteViewSizeFit];
    }
    
}

-(void)onNotificatyRTCP:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    if (dict) {
        int bitRate = [dict[@"bit"] intValue];
        CGFloat kb = bitRate/8;
        [self.flowSpeedButton setTitle:[NSString stringWithFormat:@"%.0fK/s",kb] forState:UIControlStateNormal];
        NSLog(@"bit:%d",bitRate);
        
        if (bitRate < 5) {
            if (!isLowSpeed) {
                [self performSelector:@selector(rtcpLowAction) withObject:nil afterDelay:3];
            }
            isLowSpeed = YES;
        }else{
            
            if (isLowSpeed) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
            }
            [self stopLoadingAnimation];
            isLowSpeed = NO;
        }
        
        if (kb == 0) {
            
            if (!isStartTimer) {
                [self performSelector:@selector(playOuttime) withObject:nil afterDelay:30];
                isStartTimer = YES;
            }
            
            
        }else{
            
            //[self stopLoadingAnimation];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playOuttime) object:nil];
            //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
            isStartTimer = NO;
        }
        
        
    }
}

-(void)rtcpLowAction
{
    if (isConnected) {
        [self startLodingAnimation];
    }
}

-(void)onRecvDisconnectForRemote:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    [self videoCancel];

    [self.flowSpeedButton setTitle:[NSString stringWithFormat:@"0K/s"] forState:UIControlStateNormal];
    if (_isFullScreen)
    {
        [self recoverScreen];
    }
    [self stopLoadingAnimation];
    //JFGErrorType errorType = (JFGErrorType)[dict[@"error"] intValue];
    //[ProgressHUD showText:[CommonMethod languaeKeyForLiveVideoErrorType:errorType]];
    
    
//    [LSAlertView showAlertWithTitle:nil Message:[CommonMethod languaeKeyForLiveVideoErrorType:errorType] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
//        [self.navigationController popViewControllerAnimated:YES];
//    } OKBlock:^{}];
    
    switch ([[dict objectForKey:videoErrorKey] intValue])
    {
        case DisconnectReasonPeerConnectted:
        {
            JFGErrorType errorType = (JFGErrorType)[dict[@"error"] intValue];
            [LSAlertView showAlertWithTitle:nil Message:[CommonMethod languaeKeyForLiveVideoErrorType:errorType] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
                
                [self videoCancel];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playOuttime) object:nil];
                [self.navigationController popViewControllerAnimated:YES];
                
            } OKBlock:^{
                
            }];
            
           
        }
            break;
        
        default:
        {
            if (self.navigationController.visibleViewController == self)
            {
                [self videoCancel];
                [JFGSDK appendStringToLogFile:@"DoorVideoVC显示无网络提示onRecvDisconnectForRemote"];
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Item_ConnectionFail"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"TRY_AGAIN"] CancelBlock:^{
                    
                    
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playOuttime) object:nil];
                    
                } OKBlock:^{
                    
                    [self videoCall];
                    [self startLodingAnimation];
                    
                }];
            }
        }
            break;
    }
    
    isConnected = NO;
}

-(void)jfgOtherClientAnswerDoorbellForCid:(NSString *)cid
{
    if ([cid isEqualToString:self.cid] && isDidApper) {
        [self stopSharkAnimation];
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"DOOR_OTHER_LISTENED"]];
        int64_t delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self leftButtonAction:nil];
            
        });
    }
}

-(void)playOuttime
{
    [self videoCancel];
    [self.flowSpeedButton setTitle:[NSString stringWithFormat:@"0K/s"] forState:UIControlStateNormal];
    if (_isFullScreen)
    {
        [self recoverScreen];
    }
    
    if (isDidApper) {
        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"NETWORK_TIMEOUT"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        } OKBlock:^{}];
    }
    [self stopLoadingAnimation];
}

- (void)remoteViewSizeFit
{
    if (!isConnected) {
        return;
    }
    CGFloat ratio = 1.0;
    CGFloat width;
    if (_isFullScreen) {
        width = self.view.bounds.size.height;
    }else{
        width = self.view.bounds.size.width;
    }
    ratio = videoSize.height/videoSize.width;
    CGFloat height = width * ratio;
    
    if (!_isFullScreen) {
        
        if (height < self.doorVideoScrollView.height) {
            
            height = self.doorVideoScrollView.height;
            width = height/ratio;
            
        }
        
    }else{
        if (height < self.doorVideoScrollView.width) {
            
            height = self.doorVideoScrollView.width;
            width = height/ratio;
            
        }
    }
    
    self.snapImageView.frame = CGRectMake(0, 0, width, height);
    UIView *remoteView =[self.doorVideoScrollView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        remoteView.frame = CGRectMake(0, 0, width, height);
        [self.doorVideoScrollView bringSubviewToFront:remoteView];
    }
    
    [self.doorVideoScrollView setContentSize:CGSizeMake(width, height)];
    [self.doorVideoScrollView setContentOffset:CGPointMake(0, 0)];
 
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"remoteViewSize:%@",NSStringFromCGRect(remoteView.frame)]];
    
}

#pragma mark property
- (DoorVideoSrollView *)doorVideoScrollView
{
    if (_doorVideoScrollView == nil)
    {
        //720   576
        CGFloat rota = 576.0/720.0;
        CGFloat height =rota*Kwidth;
        _doorVideoScrollView = [[DoorVideoSrollView alloc] initWithFrame:CGRectMake(0, 0, Kwidth, height)];
        _doorVideoScrollView.backgroundColor = [UIColor lightGrayColor];
        _doorVideoScrollView.scrollEnabled = YES;
        _doorVideoScrollView.bounces = NO;
//        _doorVideoScrollView.maximumZoomScale = 3.0;
//        _doorVideoScrollView.minimumZoomScale = 1.0;
        _doorVideoScrollView.bouncesZoom = NO;
        [self.fullScreenButton addTarget:self action:@selector(rotateScreen) forControlEvents:UIControlEventTouchUpInside];
        [self.halfScreenButton addTarget:self action:@selector(recoverScreen) forControlEvents:UIControlEventTouchUpInside];
        doorScrollRect = CGRectMake(0, 0, Kwidth, height);
    }
    return _doorVideoScrollView;
}

- (void)setIsOnline:(BOOL)isOnline
{
    _isOnline = isOnline;
    
    if (_isOnline == NO) // 不在线
    {
        if (self.navigationController.visibleViewController == self)
        {
            [self videoCancel];
             [JFGSDK appendStringToLogFile:@"DoorVideoVC显示无网络提示setIsOnline"];
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Item_ConnectionFail"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"TRY_AGAIN"] CancelBlock:^{
                
            } OKBlock:^{
                [self videoCall];
            }];
        }
        
    }
    
}


#pragma mark- JFGSDK udp Handle
- (void)jfgFpingRequest
{
    [JFGSDK fping:@"255.255.255.255"];
}
- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"cid in udp [%@]",ask.cid]];
    if ([ask.cid isEqualToString:self.cid])
    {
        [JFGSDK appendStringToLogFile:@"this cid is in udp check ok"];
        [JFGSDK checkDevVersionWithCid:self.cid pid:self.pType version:ask.ver];
    }
}

- (void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"isHaveNewPackage [%d]", info.hasNewPkg]];
    if (info.hasNewPkg)
    {
        [self showAlterView];
    }
}

- (void)showAlterView
{
    if (self.navigationController.visibleViewController == self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *aler = [[UIAlertView alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Device_UpgradeTips"] message:nil delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"]  otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"OK"], nil];
            [aler showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
                    upgradeDevice.cid = self.cid;
                    upgradeDevice.pType = self.pType;
                    [self.navigationController pushViewController:upgradeDevice animated:YES];
                }
                
            } otherDelegate:nil];
        });
        
        /*
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Device_UpgradeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
            upgradeDevice.cid = self.cid;
            upgradeDevice.pType = self.pType;
            [self.navigationController pushViewController:upgradeDevice animated:YES];
        }];
        */
    }
}

#pragma mark 主动

- (UIButton *)holdOnButton
{
    if (_holdOnButton == nil)
    {
        _holdOnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _holdOnButton.frame = CGRectMake((Kwidth - 80.0)*0.5, self.doorVideoScrollView.height + 0.17*kheight, 80, 80);
        [_holdOnButton setImage:[UIImage imageNamed:@"door_holdon"] forState:UIControlStateNormal];
        [_holdOnButton setImage:[UIImage imageNamed:@"door_holdon_full"] forState:UIControlStateSelected];
        [_holdOnButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _holdOnButton;
}

- (UIButton *)cameraButton
{
    if (_cameraButton == nil)
    {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.frame = CGRectMake(45, self.holdOnButton.top + (self.holdOnButton.height - 50)*0.5, 50, 50);
        [_cameraButton setImage:[UIImage imageNamed:@"camera_icon_takepic"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"camera_icon_takepic"] forState:UIControlStateSelected];
        [_cameraButton addTarget:self action:@selector(snap) forControlEvents:UIControlEventTouchUpInside];
        _cameraButton.enabled = NO;
    }
    return _cameraButton;
}

- (UIButton *)voiceButton
{
    if (_voiceButton == nil)
    {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.frame = CGRectMake(Kwidth - 50 - 45, self.holdOnButton.top + (self.holdOnButton.height - 50)*0.5, 50, 50);
        [_voiceButton addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
        [_voiceButton setImage:[UIImage imageNamed:@"door_talk_enable"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"door_talk_disable"] forState:UIControlStateSelected];
        _voiceButton.selected = YES;
        _voiceButton.enabled = NO;
    }
    return _voiceButton;
}

#pragma mark 被动
- (UIImageView *)doorBellImageView
{
    if (_doorBellImageView == nil)
    {
        _doorBellImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Kwidth - 80)*0.5, doorScrollRect.size.height + kheight *0.17 , 80, 80)];
        _doorBellImageView.image = [UIImage imageNamed:@"door_bellImage"];
        _doorBellImageView.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *_panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(moveDoorBellAction:)];
        //无论最大还是最小都只允许一个手指
        _panGestureRecognizer.minimumNumberOfTouches = 1;
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        [_doorBellImageView addGestureRecognizer:_panGestureRecognizer];
        
        [self startSharkAnimation];
    }
    return _doorBellImageView;
}

/**
 *  红点
 *
 */
- (UIImageView *)redDotBgImageView
{
    if (_redDotBgImageView == nil)
    {
        _redDotBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, self.holdOnButton.top + (self.holdOnButton.height - 22)*0.5, 22, 22)];
        _redDotBgImageView.image = [UIImage imageNamed:@"bell_red_dot_bg"];
    }
    return _redDotBgImageView;
}

- (UIImageView *)redDotImageView
{
    if (_redDotImageView == nil)
    {
        _redDotImageView = [[UIImageView alloc] initWithFrame:self.redDotBgImageView.frame];
        _redDotImageView.image = [UIImage imageNamed:@"bell_red_dot"];
    }
    
    return _redDotImageView;
}
/**
 *  绿点
 *
 */
- (UIImageView *)greenDotBgImageView
{
    if (_greenDotBgImageView == nil)
    {
        _greenDotBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Kwidth - 45.0 - 22, self.holdOnButton.top + (self.holdOnButton.height - 22)*0.5, 22, 22)];
        _greenDotBgImageView.image = [UIImage imageNamed:@"bell_green_dot_bg"];
    }
    return _greenDotBgImageView;
}
- (UIImageView *)greenDotImageView
{
    if (_greenDotImageView == nil)
    {
        _greenDotImageView = [[UIImageView alloc] initWithFrame:self.greenDotBgImageView.frame];
        _greenDotImageView.image = [UIImage imageNamed:@"bell_green_dot"];
    }
    return _greenDotImageView;
}

/**
 *  小 红/绿 点
 *
 *  @return <#return value description#>
 */
- (UIImageView *)litteGreenDot
{
    CGFloat widgetWidth = 34.0;
    CGFloat widgetHeight = 4.0;
    CGFloat widgetX = (self.greenDotImageView.left-self.doorBellImageView.right - widgetWidth)*0.5 + self.doorBellImageView.right;
    CGFloat widgetY = self.holdOnButton.top + (self.holdOnButton.height - widgetHeight)*0.5;
    
    if (_litteGreenDot == nil)
    {
        _litteGreenDot = [[UIImageView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _litteGreenDot.image = [UIImage imageNamed:@"bell_green_1"];
        
        _litteGreenDot.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"bell_green_1"],
                                          [UIImage imageNamed:@"bell_green_2"],
                                          [UIImage imageNamed:@"bell_green_3"],
                                          [UIImage imageNamed:@"bell_green_4"],
                                          nil];
        _litteGreenDot.animationDuration = 0.8; //浏览整个图片一次所用的时间
        _litteGreenDot.animationRepeatCount = 0; // 0 = loops forever 动画重复次数
        [_litteGreenDot startAnimating];
    }
    return _litteGreenDot;
}

- (UIImageView *)litteRedDot
{
    CGFloat widgetWidth = 34.0;
    CGFloat widgetHeight = 4.0;
    CGFloat widgetX = self.redDotBgImageView.right*0.5 +(self.doorBellImageView.left - widgetWidth)*0.5;
    CGFloat widgetY = self.holdOnButton.top + (self.holdOnButton.height - widgetHeight)*0.5;
    
    if (_litteRedDot == nil)
    {
        _litteRedDot = [[UIImageView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _litteRedDot.image = [UIImage imageNamed:@"bell_red_1"];
        _litteRedDot.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"bell_red_1"],
                                          [UIImage imageNamed:@"bell_red_2"],
                                          [UIImage imageNamed:@"bell_red_3"],
                                          [UIImage imageNamed:@"bell_red_4"],
                                        nil];
        _litteRedDot.animationDuration = 0.8; //浏览整个图片一次所用的时间
        _litteRedDot.animationRepeatCount = 0; // 0 = loops forever 动画重复次数
        [_litteRedDot startAnimating];
    }
    return _litteRedDot;
}

-(UIImageView *)snapImageView
{
    if (!_snapImageView) {
        _snapImageView = [[VideoSnapImageView alloc]initWithFrame:self.doorVideoScrollView.bounds];
        _snapImageView.userInteractionEnabled = YES;
    }
    return _snapImageView;
}

-(UIImageView *)loadingImageView
{
    //260
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        _loadingImageView.image = [UIImage imageNamed:@"camera_loading"];
        _loadingImageView.center = CGPointMake(self.doorVideoScrollView.bounds.size.width*0.5, self.doorVideoScrollView.bounds.size.height*0.5+self.doorVideoScrollView.origin.y);
    }
    return _loadingImageView;
}

#pragma mark -video view
- (UIButton *)flowSpeedButton
{
    if (_flowSpeedButton == nil)
    {
        _flowSpeedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 22)];
        [_flowSpeedButton setBackgroundImage:[UIImage imageNamed:@"door_flowspeed"] forState:UIControlStateNormal];
        [_flowSpeedButton.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_flowSpeedButton setTitle:@"0K/s" forState:UIControlStateNormal];
        [_flowSpeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _flowSpeedButton;
}

- (UIImageView *)shadeImageView
{
    if (_shadeImageView == nil)
    {
        _shadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)];
        _shadeImageView.image = [UIImage imageNamed:@"camera_sahdow"];
    }
    return _shadeImageView;
}

- (UIImageView *)bottomShadeImageView
{
    if (_bottomShadeImageView == nil)
    {
        _bottomShadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        _bottomShadeImageView.image = [UIImage imageNamed:@"camera_sahdow2"];
    }
    return _bottomShadeImageView;
}

- (UIButton *)fullScreenButton
{
    if (_fullScreenButton == nil)
    {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenButton.frame = CGRectMake(0, 0, 35, 35);
        [_fullScreenButton setImage:[UIImage imageNamed:@"door_outarrow"] forState:UIControlStateNormal];
    }
    return _fullScreenButton;
}


- (UIButton *)halfScreenButton
{
    if (_halfScreenButton == nil)
    {
        _halfScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _halfScreenButton.frame = CGRectMake(0, 15, 30, 30);
        [_halfScreenButton setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
    }
    return _halfScreenButton;
}

- (UILabel *)nickNameLabel
{
    if (_nickNameLabel == nil)
    {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:16.0];
        _nickNameLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        //        _nickNameLabel.text = @"宝宝的房间";
    }
    return _nickNameLabel;
}



#pragma mark
#pragma mark receive push_msg
-(void)jfgNetworkChanged:(JFGNetType)netType
{
    if (netType == JFGNetTypeOffline)
    {
        if (self.navigationController.visibleViewController == self)
        {
            if (isDidApper) {
                
                [JFGSDK appendStringToLogFile:@"DoorVideoVC显示无网络提示"];
                [self videoCancel];
                
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Item_ConnectionFail"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"TRY_AGAIN"] CancelBlock:^{
                    
                    
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playOuttime) object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } OKBlock:^{
                    
                    [self videoCall];
                    [self startLodingAnimation];
                    
                }];
            }
           
        }
        
    }
}

#pragma mark- 截图
-(void)snap
{
    if (!isConnected) {
        return;
    }
    [self snapAnimation];
    UIImage *image = [CylanJFGSDK imageForSnapshot];
    
    NSError * error = nil;
    DataPointSeg * seg1 = [[DataPointSeg alloc]init];
    seg1.msgId = dpMsgAccount_Wonder;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    int64_t time = (int64_t)[timeString longLongValue];
    
    NSString *fileName = [NSString stringWithFormat:@"%lld_1.jpg",time];
    
    ///long/[vid]/[account]/wonder/
    
    
    NSString *alias = self.cid;
    
    if (self.nickName) {
        alias = self.nickName;
    }
    
    seg1.value = [MPMessagePackWriter writeObject:@[self.cid,[NSNumber numberWithLongLong:time],@0,@(0),fileName,alias] error:&error];
    
    [[JFGSDKDataPoint sharedClient]robotSetDataWithPeer:self.cid dps:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        
        for (DataPointIDVerRetSeg *seg in dataList) {
            if (seg.ret == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:JFGExploreRefreshNotificationKey object:nil userInfo:nil];
                JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
                NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,self.cid,fileName];
                [JFGSDK uploadFile:[self saveImage:image] toCloudFolderPath:wonderFilePath];
                
            }else if (seg.ret == 1050){
            }
            
            break;
        }
        
        
    } failure:^(RobotDataRequestErrorType type) {
        NSLog(@"error：%ld",(long)type);
    }];
    
    [JFGAlbumManager jfgWriteImage:image toPhotosAlbum:nil completionHandler:^(UIImage *image, NSError *error) {
        if (error == nil) {
            
            if (_isFullScreen) {
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
                [FLProressHUD hideAllHUDForView:self.view animation:NO delay:0];
                FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
                hud.textLabel.text = [JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"];
                hud.position = FLProgressHUDPositionCenter;
                hud.showProgressIndicatorView = NO;
                [hud showInView:self.view animated:YES];
                [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1.5];
                //[ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"]];
            }
            /**
             
             
             
             */
            
            
            //
        }
    }];
    
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"呵呵";
    if (!error) {
        message = @"成功保存到相册";
    }else{
        message = [error description];
    }
    NSLog(@"message is %@",message);
}

-(UIView *)snapAnimationView
{
    if (!_snapAnimationView) {
        _snapAnimationView = [[UIView alloc]initWithFrame:self.doorVideoScrollView.bounds];
        _snapAnimationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _snapAnimationView.alpha = 1;
    }
    return _snapAnimationView;
}




//截屏动画
-(void)snapAnimation
{
    self.snapAnimationView.frame = self.doorVideoScrollView.bounds;
    [self.doorVideoScrollView addSubview:self.snapAnimationView];
    
    self.snapAnimationView.alpha = 1;
    self.snapAnimationView.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.snapAnimationView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.snapAnimationView removeFromSuperview];
        
    }];
}


-(void)startLodingAnimation
{
//    if (!self.loadingImageView.hidden) {
//
//        return;
//    }
    if (self.loadingImageView.superview == nil) {
        [self.view addSubview:self.loadingImageView];
    }
    
    if (_isFullScreen) {
        self.loadingImageView.center = CGPointMake(self.view.bounds.size.width*0.5, self.view.bounds.size.height*0.5);
    }else{
        self.loadingImageView.center = CGPointMake(self.doorVideoScrollView.bounds.size.width*0.5, self.doorVideoScrollView.bounds.size.height*0.5+self.doorVideoScrollView.origin.y);
    }
    
    //加载控件与播放按钮控件同一位置，避免遮挡
    self.loadingImageView.hidden = NO;
    [self.view bringSubviewToFront:self.loadingImageView];
    
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
    [self.loadingImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopLoadingAnimation
{
    if (self.loadingImageView.hidden) {
        return;
    }
    self.loadingImageView.hidden = YES;
    [self.loadingImageView.layer pop_removeAnimationForKey:@"rotation"];
}

-(NSString *)saveImage:(UIImage *)currentImage
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"account_pic.png"];
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1);//UIImagePNGRepresentation(currentImage);
    [imageData writeToFile:path atomically:YES];// 将图片写入文件
    return path;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"doorVideoVC delloc");
}

@end
