//
//  VideoChatVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "VideoChatVC.h"
#import "JfgGlobal.h"
#import "PopAnimation.h"
#import "RippleAnimationView.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/CylanJFGSDK.h>
#import "ChatButton.h"
#import "JFGEfamilyDataManager.h"
#import "ProgressHUD.h"
#import "JFGEquipmentAuthority.h"

typedef NS_ENUM(NSUInteger, VIEW_CONTROL_TAG)
{
    LABEL_TITLE_TAG = 1000,
    IMAGEVIEW_TITLE_BG_TAG,
    IMAGEVIEW_BACKGROUND_TAG,
    IMGVIEW_CIRCLE_TAG,
    VIEW_LOCALRENDE_VIEW_TAG,
    VIEW_REMOTERENDE_VIEW_TAG,
    BUTTON_INITIATIVEHOLD_TAG,
};

#define DESIGN_SIZE_HEGHT  568.0
#define DESIGN_SIZE_WIDTH 375.0
#define HEIGHT_RATIO(DESIGN)  DESIGN/DESIGN_SIZE_HEGHT *kheight
#define WIDTH_RATIO(DESIGN) DESIGN/DESIGN_SIZE_WIDTH * Kwidth
#define LOCAL_RESOLUTION_SIZE CGSizeMake(240.0, 320.0)

@interface VideoChatVC ()<JFGSDKCallbackDelegate>
/**
 *  接通 电话
 */
@property (nonatomic, strong) ChatButton *answerButton;
/**
 *  挂断电话
 */
@property (nonatomic, strong) ChatButton *holdOnButton;
/**
 *  头像 图片
 */
@property (nonatomic, strong) UIImageView *headImageView;
/**
 *  显示 昵称
 */
@property (nonatomic, strong) UILabel *nickNameLabel;
/**
 *  显示 中控 状态
 */
@property (nonatomic, strong) UILabel *chatStateLabel;

@property (nonatomic,strong)UILabel *topStateLabel;


/**
 *  底部 动画 view
 */
@property (nonatomic, strong) RippleAnimationView *rippleAniView;

@property (nonatomic,assign)BOOL isAnswer;



@end

@implementation VideoChatVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addVideoNotifacation];
    [self initView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [JFGSDK addDelegate:self];
    [self initNavigationView];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
     [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [JFGSDK removeDelegate:self];
    [self stopVideoCall:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

-(void)addVideoNotifacation
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onRecvDisconnectForRemote:) name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    
    //a
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotifyResolution:) name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotificatyRTCP:) name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark view
- (void)initView
{
    isVideoConnectted = NO;
    isEverConnectted = NO;
    connecttedDuration = 0;
    connectTimes = 0;
    
    if (_chatType == videoChatTypeActive)
    {   // 主动
        [self createInitiativeView];
        [self startVideoCall];
        [self localViewSizeFit];
        self.topStateLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_VIDEOCALLING1"];
        
    }
    else
    {
        [self createPassiveView];
    }
    [self.view addSubview:self.topStateLabel];
    [self startCheckTimer];
    _efamilyRecordArray = [[NSMutableArray alloc] initWithCapacity:10];
}

- (void)initNavigationView
{
    // 顶部 导航设置
    self.navigationView.hidden = YES;
}

#pragma mark
#pragma mark  ------  UI 搭建 -----------
// 客户端 主动通话 UI
- (void)createInitiativeView
{
    UIImageView *bgImgView = (UIImageView *)[self.view viewWithTag:IMAGEVIEW_BACKGROUND_TAG];
    if (bgImgView)
    {
        [bgImgView removeFromSuperview];
    }
    
    // 远程 视图  父视图
    _remoteScrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _remoteScrollView.delegate = self;
    _remoteScrollView.clipsToBounds = YES;
    _remoteScrollView.bounces = NO;
    _remoteScrollView.backgroundColor = [UIColor lightGrayColor];
    _remoteScrollView.scrollEnabled = NO;
    [_remoteScrollView setContentSize:_remoteScrollView.frame.size];
    [self.view addSubview:_remoteScrollView];
    
    // 本地视图
    _localScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _localScrollView.delegate = self;
    _localScrollView.clipsToBounds = YES;
    _localScrollView.bounces = NO;
    _localScrollView.backgroundColor = [UIColor whiteColor];
    _localScrollView.userInteractionEnabled = NO;
    _localScrollView.scrollEnabled = NO;
    [_localScrollView setContentSize:_localScrollView.frame.size];
    [self.view addSubview:_localScrollView];
    
    
    
    UIButton *initiativeHoldButton = [[UIButton alloc] init];
    initiativeHoldButton.tag = BUTTON_INITIATIVEHOLD_TAG;
    [initiativeHoldButton setBackgroundImage:[UIImage imageNamed:@"efamily_action_holdonBtn_normal"] forState:UIControlStateNormal];
    [initiativeHoldButton setBackgroundImage:[UIImage imageNamed:@"efamily_action_holdonBtn_pressed"] forState:UIControlStateHighlighted];
    [initiativeHoldButton setTitle:[JfgLanguage getLanTextStrByKey:@"DOOR_STOPPED"] forState:UIControlStateNormal];
    [initiativeHoldButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [initiativeHoldButton addTarget:self action:@selector(holdonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:initiativeHoldButton];
    [initiativeHoldButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-30.0f);
    }];
    
    
    
    
}
// 客户端 被动 通话 UI
- (void)createPassiveView
{
    if (_remoteScrollView)
    {
        [_remoteScrollView removeFromSuperview];
    }
    
    // 背景图片  父视图
    UIImageView *bgImgView = [[UIImageView alloc] init];
    bgImgView.tag = IMAGEVIEW_BACKGROUND_TAG;
    bgImgView.image = [UIImage imageNamed:@"bg_efamily_call"];
    bgImgView.userInteractionEnabled = YES;
    [self.view addSubview:bgImgView];
    [bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];
    
    // 头像 图片
    [bgImgView addSubview:self.headImageView];
    // 昵称 Label
    [bgImgView addSubview:self.nickNameLabel];
    // 状态 Label
    [bgImgView addSubview:self.chatStateLabel];
    //接听  挂断 按钮
    [bgImgView addSubview:self.holdOnButton];
    [bgImgView addSubview:self.answerButton];
    // 底部 动画 view
    [bgImgView addSubview:self.rippleAniView];
    [self flyAnimation];
    
}

// 改变 本地视图 的布局
- (void)changeLocalView
{
    _localScrollView.frame = CGRectMake(Kwidth - 92 - 7, kheight - 140 - 7, 92, 122.5);
    [_localScrollView setContentSize:_localScrollView.frame.size];
    _localScrollView.zoomScale =0.1;
    UIView *remoteView = (UIView *)[_localScrollView viewWithTag:VIEW_LOCALRENDE_VIEW_TAG];
    remoteView.frame = CGRectMake(0, 0, _localScrollView.frame.size.width, _localScrollView.frame.size.height);
}

- (void)showdoorBellViewWithDict:(NSDictionary *)dict
{
    if ([self.navigationController.viewControllers lastObject] == self)
    {

    }
}

-(void)rotateScreen:(id)sender
{
    
}

#pragma mark
#pragma mark  ------  动画 -----------
- (void)flyAnimation
{
    // 记录 控件 原始位置
    CGFloat headImageViewCenterY = self.headImageView.y;
    CGFloat nickNameLabelCenterY = self.nickNameLabel.y;
    CGFloat chatSatusLabelCenterY = self.chatStateLabel.y;
    CGFloat answerButtonCenterY = self.answerButton.y;
    CGFloat holdOnButtonCenterY = self.holdOnButton.y;
    
    // 将控件 下移
    self.headImageView.y = self.nickNameLabel.y = self.chatStateLabel.y = self.answerButton.y = self.holdOnButton.y = kheight + 100;
    
    [self startSpringAnimationView:self.headImageView centerY:headImageViewCenterY delay:0.3f];
    [self startSpringAnimationView:self.nickNameLabel centerY:nickNameLabelCenterY delay:0.4f];
    [self startSpringAnimationView:self.chatStateLabel centerY:chatSatusLabelCenterY delay:0.5f];
    [self startSpringAnimationView:self.answerButton centerY:answerButtonCenterY delay:0.6f];
    [self startSpringAnimationView:self.holdOnButton centerY:holdOnButtonCenterY delay:0.7f];
}
/**
 *  动画开始
 *
 *  @param aniView 动画队形
 *  @param centerY 目的 中心
 *  @param delay   延迟时间
 */
- (void)startSpringAnimationView:(UIView *)aniView centerY:(CGFloat)centerY delay:(double)delay
{
    //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
    dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    //推迟两纳秒执行
    dispatch_queue_t concurrentQueue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(delayInNanoSeconds, concurrentQueue, ^(void){
        [PopAnimation startSpringPositonAnimation:CGPointMake(aniView.x, centerY) withView:aniView completionBlock:nil];
    });
}

#pragma mark  ------  返回 上一个页面 -----------
- (void)backAction:(id)sender
{
    [self stopVideoCall:YES];
    [super leftButtonAction:sender];
}

- (void)backActionWithDelay:(CGFloat)delayTime andError:(NSString *)errorString
{
    UIButton *initiativeHoldButton = (UIButton *)[self.view viewWithTag:BUTTON_INITIATIVEHOLD_TAG];
    if (initiativeHoldButton)
    {
        initiativeHoldButton.userInteractionEnabled = NO;
    }
    
    if (errorString != nil && ![errorString isEqualToString:@""])
    {
        NSLog(@"_____errorString     %@",errorString);
    }
    [self performSelector:@selector(backAction:) withObject:nil afterDelay:delayTime];
}

#pragma mark
#pragma mark  ------  按钮点击 事件 -----------
// 挂断 按钮
- (void)holdonButtonAction:(id)sender
{
    [self backAction:nil];
    [self saveCallMsg];
}


-(void)saveCallMsg
{
    JFGEfamilyDataModel *model = [JFGEfamilyDataModel new];
    
    if (self.chatType == videoChatTypeActive) {
        model.isFromSelf = YES;
    }else{
        model.isFromSelf = NO;
    }
    model.cid = self.cid;
    model.msgType = JFGEfamilyMsgTypeVideo;
    model.resourceUrl = @"";
    
    if (self.timeStamp) {
        model.timestamp = self.timeStamp;
    }else{
        model.timestamp = [[NSDate date] timeIntervalSince1970];
    }
    
    model.acceptSuccess = isVideoConnectted;
    
    if (isVideoConnectted) {
        
        NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:model.timestamp];
        NSTimeInterval time = [beginDate timeIntervalSinceDate:[NSDate date]];
        int64_t cz = fabs(time);
        model.timeLength = cz;
//        int seconds = ((int)cz)%(3600*24)%3600%60;
//        NSLog(@"callTime:%d",seconds);
        
    }else{
        
        model.timeLength = 0;
    }
    [[JFGEfamilyDataManager defaultEfamilyManager] addEfamilyMsg:model];
}

// 接听按钮
- (void)answerButtonAction:(id)sender
{
    [self createInitiativeView];
    [self startVideoCall];
    [self stopEfamilyMusic];
    [self localViewSizeFit];
    self.topStateLabel.text = [JfgLanguage getLanTextStrByKey:@"DOOR_ANSWERING"];
    self.isAnswer = YES;
}

#pragma mark
#pragma mark  ------  听筒播放 切换 -----------
- (void)openProximityMonitoringPlay
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    
}
- (void)closeProximityMonitoringPlay
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)sensorStateChange:(NSNotification *)notification
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else//屏幕没黑
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (![self.avAudioPlayer isPlaying]) //没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
        {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

#pragma mark
#pragma mark  ------  音乐 播放/停止 -----------
- (void)playEfamilyMusic
{
    if (_chatType == videoChatTypeUnactive)
    {
        NSError *bellVoiceError = nil;
        NSString *bellVoicePath = [[NSBundle mainBundle] pathForResource:@"ihome" ofType:@"caf"];
        
        if (bellVoicePath)
        {
            if (!self.avAudioPlayer)
            {
                self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:bellVoicePath] error:&bellVoiceError];
                self.avAudioPlayer.numberOfLoops = 0;
                if (bellVoiceError) {

                }
                if ([self.avAudioPlayer prepareToPlay])
                {
                    [self.avAudioPlayer play];
                }
            }
        }
        else
        {
            
        }
    }
}

- (void)stopEfamilyMusic
{
    if (self.avAudioPlayer)
    {
        if ([self.avAudioPlayer isPlaying])
        {
            [self.avAudioPlayer stop];
        }
        
    }
}

#pragma mark
#pragma mark  ======= SDK action

-(void)onNotifyResolution:(NSNotification *)notification
{
    //NSLog(@"connected Notify");
    
    NSDictionary *dict = notification.object;
    if (dict) {
        
        [self startTitleTimer];
        
        int width = [[dict objectForKey:@"width"] intValue];
        int height = [[dict objectForKey:@"height"] intValue];
        
        CGSize size = CGSizeMake(width, height);
        NSLog(@"resoluSize:%@",NSStringFromCGSize(CGSizeMake(width, height)));
        UIView *remoteView = [_remoteScrollView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        if (!remoteView) {
            remoteView = [[VideoRenderIosView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            remoteView.tag = VIEW_REMOTERENDE_VIEW_TAG;
            remoteView.backgroundColor = [UIColor clearColor];
            remoteView.layer.edgeAntialiasingMask = YES;
            [_remoteScrollView addSubview:remoteView];
            
            [CylanJFGSDK startRenderRemoteView:remoteView];
            
            if ([JFGEquipmentAuthority canRecordPermission]) {
                [CylanJFGSDK setAudio:YES openMic:YES openSpeaker:YES];
                [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:YES];
            }
            
        }
        
        remoteCallViewSize = size;
        [self remoteViewSizeFit];
        [self changeLocalView];
        [self endCheckTimer];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(backAction:) object:nil];
        isVideoConnectted = YES;
        self.timeStamp = [[NSDate date] timeIntervalSince1970];
    }
    
    
}



-(void)onNotificatyRTCP:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    if (dict) {
        int bitRate = [dict[@"bit"] intValue];
        //        int frameRate = [dict[@"frameRate"] intValue];
        //        int timestamp = [dict[@"timestamp"] intValue];
        //        int videorecved = [dict[@"videoRecved"] intValue];
        
        NSLog(@"bit:%d",bitRate);
    }
}

-(void)onRecvDisconnectForRemote:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
//    [CylanJFGSDK stopRenderView:YES withCid:self.cid];
//    [CylanJFGSDK stopRenderView:NO withCid:self.cid];
//    [CylanJFGSDK disconnectVideo:@""];
    
    NSLog(@"视频连接断开:%@",[dict description]);
    
    
    if ([[dict objectForKey:@"error"] intValue] == 11) {
        
        
        
    }
    [self saveCallMsg];
    
    [self backAction:nil];
    if ([[[dict objectForKey:@"error"] stringValue] isEqualToString: @"102"]) {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"CONNECTING"]];
    }
    
}

-(void)jfgEfamilyMsg:(id)msg
{
    if ([msg isKindOfClass:[NSArray class]]) {
        NSArray *sourArr = msg;
        if (sourArr.count>=2) {
            
            int msgID = [sourArr[0] intValue];
            NSString *cid = sourArr[1];
            if (msgID == 2531 && [cid isEqualToString:self.cid]) {
                
                [self saveCallMsg];
                
                [self backAction:nil];
                
                
            }
            
        }
        
    }
}



#pragma mark
#pragma mark  ------  视频 通话 -----------
- (void)startVideoCall
{
    connectTimes ++;
    
    [self startCallRepeatTimer];
    
    VideoRenderIosView *localRenderView = [_localScrollView viewWithTag:VIEW_LOCALRENDE_VIEW_TAG];
    
    if (localRenderView == nil)
    {
        localRenderView = [[VideoRenderIosView alloc] initWithFrame:self.view.bounds];
        localRenderView.tag = VIEW_LOCALRENDE_VIEW_TAG;
        [_localScrollView addSubview:localRenderView];
    }
    [CylanJFGSDK openLocalCamera:YES];
    [CylanJFGSDK startRenderLocalView:localRenderView];
    [CylanJFGSDK connectCamera:self.cid];
    
}
- (void)stopVideoCall:(BOOL)isCloseLocalCamera
{
    [CylanJFGSDK stopRenderView:YES withCid:self.cid];
    [CylanJFGSDK stopRenderView:NO withCid:self.cid];
    if (self.cid) {
        [CylanJFGSDK disconnectVideo:self.cid];
    }else{
        [CylanJFGSDK disconnectVideo:@""];
    }
    
    
    UIView *remoteView = [_remoteScrollView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        [remoteView removeFromSuperview];
        remoteView = nil;
    }
    [self endCheckTimer];
    [self endCallRepeatTimer];
}

#pragma mark
#pragma mark  ------定时器 超时处理  -----------
- (void)startCheckTimer
{
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(chatVideoCallOutTime:) userInfo:nil repeats:NO];
}


- (void)endCheckTimer
{
    if (checkTimer)
    {
        if ([checkTimer isValid])
        {
            [checkTimer invalidate];
        }
        checkTimer = nil;
    }
}
- (void)chatVideoCallOutTime:(id)obj
{
    checkTimer = nil;
    [self chatVideoCallOutTimeWithReason: (self.chatType == videoChatTypeActive)?[JfgLanguage getLanTextStrByKey:@"EFAMILY_NO_ANSWER"]:nil];
}

- (void)chatVideoCallOutTimeWithReason:(NSString *)reasonInfo
{
    [self backActionWithDelay:1.0f andError:reasonInfo];
}


#pragma mark
#pragma mark  ------定时器 更改标题  -----------
- (void)startTitleTimer
{
    titleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeTitle) userInfo:nil repeats:YES];
    [self.view bringSubviewToFront:self.topStateLabel];
    
}
- (void)endTitleTimers
{
    if (titleTimer)
    {
        if ([titleTimer isValid])
        {
            [titleTimer invalidate];
        }
        titleTimer = nil;
    }
}
- (void)changeTitle
{
    self.topStateLabel.text = [NSString stringWithFormat:@"%.2ld:%.2ld",connecttedDuration/60,connecttedDuration%60];
    connecttedDuration ++;
}

- (void)startCallRepeatTimer
{
    _callRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(callRepeatAcion:) userInfo:nil repeats:NO];
}

- (void)endCallRepeatTimer
{
    if (_callRepeatTimer != nil)
    {
        if ([_callRepeatTimer isValid])
        {
            [_callRepeatTimer invalidate];
        }
        _callRepeatTimer = nil;
    }
}

- (void)callRepeatAcion:(NSTimer *)callRepeatTimer
{
    _callRepeatTimer = nil;
    
    if (connectTimes == 1) {return;} //首次 连接
    
    if (isVideoConnectted == NO)
    {
        
    }
}


#pragma mark
#pragma mark  ------调整 视频View  -----------
- (void)remoteViewSizeFit
{
    CGFloat ratio = 1.0;
    CGRect rect = CGRectMake(0, 64, Kwidth, 255);
    ratio = kheight/remoteCallViewSize.height;
    rect.size.height = remoteCallViewSize.height*ratio;
    
    [_remoteScrollView setContentSize:rect.size];
    
    _remoteScrollView.minimumZoomScale = ratio;
    _remoteScrollView.maximumZoomScale = 5.0;
    _remoteScrollView.zoomScale = ratio;
    
    
    
}

- (void)localViewSizeFit
{
    CGFloat zoomScale = [self localViewZoomScale];
    
    //[_localScrollView setContentSize:CGSizeMake(SCREEN_SIZE.width*zoomScale, SCREEN_SIZE.height*zoomScale)];
    _localScrollView.minimumZoomScale = zoomScale;
    _localScrollView.maximumZoomScale = 5.0;
    _localScrollView.zoomScale = zoomScale;
    _localScrollView.scrollEnabled = NO;
}

- (CGFloat)localViewZoomScale
{
    CGFloat zoomScale = 1.0;
    CGFloat widthScale = Kwidth/LOCAL_RESOLUTION_SIZE.width;
    CGFloat heightScale = kheight/LOCAL_RESOLUTION_SIZE.height;
    zoomScale = (widthScale > heightScale)?widthScale:heightScale; // 确保 满屏，取大的值
    return zoomScale;
}


#pragma mark
#pragma mark  ------  UIScrollView 代理 -----------
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == _remoteScrollView)
    {
        return (UIView *)[_remoteScrollView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    }
    else if (scrollView == _localScrollView)
    {
        return (UIView *)[_localScrollView viewWithTag:VIEW_LOCALRENDE_VIEW_TAG];
    }
    return  nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView == _remoteScrollView)
    {
        UIView *remoteView = (UIView *)[_remoteScrollView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        
        CGAffineTransform transform = remoteView.transform;
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
        remoteView.transform = transform;
        
        remoteView.frame = CGRectMake(0, 0, remoteView.frame.size.width, remoteView.frame.size.height);
        scrollView.maximumZoomScale = scrollView.zoomScale;
    }
    else if (scrollView == _localScrollView)
    {
        int widthError = fabs(Kwidth - _localScrollView.contentSize.width)/2;
        int heightError = fabs(kheight - _localScrollView.contentSize.height)/2;
        
        UIView *localView = (UIView *)[_localScrollView viewWithTag:VIEW_LOCALRENDE_VIEW_TAG];
        
        CGAffineTransform transform = localView.transform;
        transform = CGAffineTransformScale(transform, -1.0, -1.0);
        localView.transform = transform;
        
        localView.frame = CGRectMake(0 , 0, localView.frame.size.width, localView.frame.size.height);
        
        [_localScrollView setContentOffset:CGPointMake(widthError, heightError)];
        scrollView.maximumZoomScale = scrollView.zoomScale;
    }
}

#pragma mark getter

//- (JFGSDKVideoView *)videoPlayTool
//{
//    if (_videoPlayTool == nil)
//    {
//        _videoPlayTool = [[JFGSDKVideoView alloc] initWithFrame:self.view.frame];
//        _videoPlayTool.delegate = self;
//    }
//    return _videoPlayTool;
//}

- (ChatButton *)answerButton
{
    CGFloat widgetWidth = 63;
    CGFloat widgetHeight = 63;
    CGFloat widgetX = Kwidth*0.5 + 50;
    CGFloat widgetY = kheight *0.63 + widgetHeight;
    
    if (_answerButton == nil)
    {
        _answerButton = [ChatButton buttonWithType:UIButtonTypeCustom];
        _answerButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_answerButton setImage:[UIImage imageNamed:@"efamily_answerbtn_normal"] forState:UIControlStateNormal];
        [_answerButton setTitle:[JfgLanguage getLanTextStrByKey:@"EFAMILY_CALL_ANSWER"] forState:UIControlStateNormal];
        [_answerButton addTarget:self action:@selector(answerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerButton;
}

- (ChatButton *)holdOnButton
{
    CGFloat widgetWidth = 63;
    CGFloat widgetHeight = 63;
    CGFloat widgetX = Kwidth*0.5 - widgetWidth - 50;
    CGFloat widgetY = self.answerButton.top;
    
    if (_holdOnButton == nil)
    {
        _holdOnButton = [ChatButton buttonWithType:UIButtonTypeCustom];
        _holdOnButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_holdOnButton setImage:[UIImage imageNamed:@"efamily_holdonBtn_normal"] forState:UIControlStateNormal];
        [_holdOnButton setTitle:[JfgLanguage getLanTextStrByKey:@"EFAMILY_IGNORE"] forState:UIControlStateNormal];
        [_holdOnButton addTarget:self action:@selector(holdonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _holdOnButton;
}

- (UIImageView *)headImageView
{
    CGFloat widgetWidth = 175.0;
    CGFloat widgetHeight = 175.0;
    CGFloat widgetX = (Kwidth - widgetWidth)*0.5;
    CGFloat widgetY = kheight*0.12;
    
    if (_headImageView == nil)
    {
        _headImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_ihome"]];
        _headImageView.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
    }
    
    return _headImageView;
}

- (UILabel *)nickNameLabel
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 30;
    CGFloat widgetX = 0;
    CGFloat widgetY = self.headImageView.bottom + 24;
    
    if (_nickNameLabel == nil)
    {
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.font = [UIFont systemFontOfSize:24.0f];
        _nickNameLabel.textColor = [UIColor colorWithHexString:@"#4f697d"];
        _nickNameLabel.text = [JfgLanguage getLanTextStrByKey:@"DOOR_MAGNET_NAME"]; //self.nickName
    }
    return _nickNameLabel;
}

- (UILabel *)chatStateLabel
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 30.0;
    CGFloat widgetX = 0;
    CGFloat widgetY = self.nickNameLabel.bottom;
    
    if (_chatStateLabel == nil)
    {
        _chatStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _chatStateLabel.textAlignment = NSTextAlignmentCenter;
        _chatStateLabel.textColor = [UIColor colorWithHexString:@"#4f697d"];
        _chatStateLabel.font = [UIFont systemFontOfSize:17.0f];
        _chatStateLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_VIDEOCALLING1"];
    }
    return _chatStateLabel;
}

- (RippleAnimationView *)rippleAniView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = ceil(kheight*0.09);;
    CGFloat widgetX = 0;
    CGFloat widgetY = kheight - widgetHeight;
    
    if (_rippleAniView == nil)
    {
        _rippleAniView = [[RippleAnimationView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _rippleAniView.speed1 = 50.0;
        _rippleAniView.speed2 = 25.0;
        _rippleAniView.speed3 = 15.0;
        
        _rippleAniView.bottomImage = @"efamily_scroll_bottom";
        _rippleAniView.topImage = @"efamily_scroll_top";
        _rippleAniView.centerImage = @"efamily_scroll_center";
    }
    return _rippleAniView;
}

-(UILabel *)topStateLabel
{
    if (!_topStateLabel) {
        UILabel *timeCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        timeCountLabel.tag = LABEL_TITLE_TAG;
        timeCountLabel.textColor = [UIColor whiteColor];
        timeCountLabel.text = @"";
        timeCountLabel.backgroundColor = [UIColor clearColor];
        timeCountLabel.textAlignment = NSTextAlignmentCenter;
        timeCountLabel.font = [UIFont systemFontOfSize:15];
        _topStateLabel = timeCountLabel;
    }
    return _topStateLabel;
    
}

@end
