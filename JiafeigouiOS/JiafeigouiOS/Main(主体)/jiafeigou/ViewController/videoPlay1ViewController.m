//
//  videoPlay1ViewController.m
//  JiafeigouiOS
//
//  Created by yangli on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "videoPlay1ViewController.h"
#import "NetworkMonitor.h"
#import "UIView+FLExtensionForFrame.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+FLExtension.h"
#import <JFGSDK/JFGSDK.h>
#import "SafaButton.h"
#import "SetAngleVC.h"
#import <POP.h>
#import "HorizontalHistoryRecordView.h"
#import "HistoryDatePicker.h"
#import "FLGlobal.h"
#import "FullScreenHistoryDatePicker.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "FLProressHUD.h"
#import "JFGBoundDevicesMsg.h"
#import "JFGHelpViewController.h"
#import "JfgLanguage.h"
#import <JFGSDK/CylanJFGSDK.h>
#import "VideoSnapImageView.h"
#import "JfgMsgDefine.h"
#import "JfgConfig.h"
#import "JFGBigImageView.h"
#import "OemManager.h"
#import "CommonMethod.h"
#import "LSAlertView.h"
#import "LoginManager.h"
#import "JFGAlbumManager.h"
#import "JFGEquipmentAuthority.h"
#import "UpgradeDeviceVC.h"
#import "JfgConstKey.h"
#import "DownloadUtils.h"
#import "JFGDataPointValueAnalysis.h"
#import "JfgTimeFormat.h"
#import "UIAlertView+FLExtension.h"
#import "NSTimer+FLExtension.h"
#import "AngleView.h"
#import "ProgressHUD.h"
#import "dataPointMsg.h"
#import "VideoPlayViewController.h"




typedef NS_ENUM(NSUInteger, VIEW_CONTROL_TAG)
{
    LABEL_TITLE_TAG = 1001,
    IMAGEVIEW_TITLE_BG_TAG,
    IMAGEVIEW_BACKGROUND_TAG,
    IMGVIEW_CIRCLE_TAG,
    VIEW_LOCALRENDE_VIEW_TAG,
    VIEW_REMOTERENDE_VIEW_TAG,
    BUTTON_INITIATIVEHOLD_TAG,
    SAFA_ALTER_TAG,
};

NSString *const snapShotKey = @"jiafeigouvideoSnapStotKey";
NSString *const fristSafeKey = @"fristSafeKey1";
NSString *const fristhistoryVideoKey =  @"fristhistoryVideoKey";
NSString *const fristIntoAngleVideoViewKey = @"fristIntoAngleVideoViewKey";

@interface videoPlay1ViewController ()<NetworkMonitorDelegate,UIScrollViewDelegate,JFGSDKCallbackDelegate,HorizontalHistoryRecordViewDelegate,HistoryDatePickerDelegate,FullScreenHistoryDatePickerDelegate,UITextFieldDelegate,UIAlertViewDelegate, setAngleDelegate>
{
    //视频播放状态
    videoPlayState playState;
    //视频窗口大小
    videoPlayWindowsMode windowMode;
    //视频内容（直播，历史）
    videoPlayContentMode contentMode;
    //接收对端声音状态
    BOOL isAudio;
    //对讲
    BOOL isTalkBack;
    BOOL isLiveVideo;
    
    BOOL isShared;
    BOOL showTip;
    BOOL fristZoom;
    
    NSDateFormatter *dateFormatter;
    UITapGestureRecognizer *videoTapGesture;
    
    NSMutableArray *historyVideoDateLimits;
    historyVideoDurationTimeModel *currentHistoryModel;
    
    
    int64_t historyLastestTimeStamp;
    NSArray *historyAllList;
    
    BOOL isStartTimeoutRequest;
    BOOL isCancelTImeoutRequest;
    
    NSInteger timeoutRequestCount;
    
    BOOL warnSensitivity;
    BOOL isOpenWarn;
    CGSize remoteCallViewSize;
    
    BOOL isHasSDCard;
    
    NSInteger sdCardErrorCode;
    
    
    CGFloat maxZoomScale;
    
    NSTimer *safeTipTimer;
    
    BOOL isLoading;
    BOOL isLowSpeed;
    BOOL isDidAppear;
    BOOL isInCurrentView;
}

//时间显示
@property (nonatomic,strong)NSTimer *recordTimer;

//视频播放区域最底层背景视图
@property (nonatomic,strong)UIView *videoBgView;

//安全防护模式背景视图
@property (nonatomic,strong)UIView *idleModeBgView;


//呈放视频播放视图（适配视频分辨率，等比拉伸后，实现视频滚动）
@property (nonatomic,strong)UIScrollView *videoPlayBgScrollerView;

/**
 *  安全防护按钮
 */
@property (nonatomic,strong)SafaButton *safeguardBtn;

@property (nonatomic,strong)SafaButton *safeguardBtn_full;

//视频播放模式（历史，直播）及时间显示
@property (nonatomic,strong)UILabel *videoPlayTipLabel;

//全屏播放按钮
@property (nonatomic,strong)UIButton *fullScreenBtn;

//播放暂停按钮
@property (nonatomic,strong)UIButton *playButton;

//视频下方一系列（以上三个）控件背景视图
@property (nonatomic,strong)UIImageView *videoBottomBar;

//视频下载速率显示
@property (nonatomic,strong)UILabel *rateLabel;

//截图显示
@property (nonatomic,strong)VideoSnapImageView *snapeImageView;

//加载提示
@property (nonatomic,strong)UIImageView *loadingImageView1;

//背景视图
@property (nonatomic,strong)UIView *loadingBgView;

//声音
@property (nonatomic,strong)UIButton *voiceButton;

//麦克风
@property (nonatomic,strong)UIButton *microphoneBtn;

//截图
@property (nonatomic,strong)UIButton *snapBtn;

//截屏闪现动画视图
@property (nonatomic,strong)UIView *snapAnimationView;

//全屏顶部Bar
@property (nonatomic,strong)UIView *fullScreenTopControlBar;

//全屏底部Bar
@property (nonatomic,strong)UIView *fullScreenBottomControlBar;

//全屏遮罩
@property (nonatomic,strong)UIView *fullShadeView;

//全屏时声音按钮
@property (nonatomic,strong)UIButton *fullVoideBtn;

//全屏时对讲按钮
@property (nonatomic,strong)UIButton *fullMicBtn;

//全屏时截图按钮
@property (nonatomic,strong)UIButton *fullSnapBtn;

//全屏时播放按钮
@property (nonatomic,strong)UIButton *fullPlayBtn;

//历史视频滚动条
@property (nonatomic,strong)HorizontalHistoryRecordView *historyView;

@property (nonatomic,strong)UIImageView *snapSmallWidows;

@property (nonatomic, strong) DownloadUtils *downLoadUtils;

@property (nonatomic, assign) int angleType;

@property (nonatomic, assign) BOOL isInCurrentVC; // 是否在 当前界面

@end

@implementation videoPlay1ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    isLiveVideo = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addNotificationDelegate];
    if (self.devModel.shareState != DevShareStatuOther) {
        isShared = NO;
    }else{
        isShared = YES;
    }
    playState = videoPlayStatePause;
    [self.view addSubview:self.videoBgView];
    [self.videoBgView addSubview:self.videoPlayBgScrollerView];
    
    [self.view addSubview:self.snapBtn];
    [self.view addSubview:self.microphoneBtn];
    [self.view addSubview:self.voiceButton];
    
    [self voiceAndMicBtnDisableState];
    
    timeoutRequestCount = 0;
    
    isInCurrentView = YES;
    if (![CommonMethod isPanoCameraWithType:[self.devModel.pid intValue]])
    {
        [self jfgFpingRequest];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isShared) {
        [self warnSensitivity];
        [self getSDCard];
    }
    if (safeTipTimer && [safeTipTimer isValid]) {
        [safeTipTimer invalidate];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        [JFGSDK appendStringToLogFile:@"VideoPlayView viewDidAppear"];
        isDidAppear = YES;
        self.isInCurrentVC = YES;
        NSInteger pid = [self.devModel.pid integerValue];
        if (pid == 5 || pid == 7 || pid == 13 || pid == 4 || pid == 16 || pid == 17 || pid == 1071 ) {
            maxZoomScale = 3.0;
        }else{
            maxZoomScale = 1.0;
            [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgCamera_Angle)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
                self.angleType = [[dic objectForKey:dpMsgCameraAngleKey] intValue];
            } FailBlock:^(RobotDataRequestErrorType error) {
                
            }];
        }
        [self addVideoNotification];
        if ([NetworkMonitor sharedManager].currentNetworkStatu == NotReachable) {
            
            [self showDisconnectViewWithText:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
            playState = videoPlayStateNotNet;
            [self hideIdleView];
            
        }else{
            
            [self hideDisconnectNetView];
            
            NSInteger pid = [self.devModel.pid integerValue];
            if (![[NSUserDefaults standardUserDefaults] boolForKey:fristIntoAngleVideoViewKey] && (pid == 18 || pid == 19 || pid == 20 || pid == 21) && self.devModel.shareState != DevShareStatuOther) {
                
                //显示那个角度提示
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristIntoAngleVideoViewKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self showAngleTip];
                
                
            }else{
                
                UIView *vw = [self.videoBgView viewWithTag:13145202];
                if (vw) {
                    [vw removeFromSuperview];
                    vw = nil;
                }
                
                if (self.devModel.safeIdle) {
                    
                    [self hideVideoPlayBar];
                    [self showIdleView];
                    if (isShared == NO) {
                        self.historyView.hidden = YES;
                    }
                    
                }else{
                    
                    if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                        return;
                    }
                    playState = videoPlayStatePlayPreparing;
                    
                    [self hideIdleView];
                    if (isLiveVideo) {
                        [self hideVideoPlayBar];
                        [self startLiveVideo];
                    }else{
                        [self playHistoryVideoForZeroWithTimestamp:historyLastestTimeStamp];
                    }
                    [self performSelector:@selector(onNotifyResolutionOvertime) withObject:nil afterDelay:30];
                    
                }
            }
        }
        
        
    });
    
    //开启屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isDidAppear = NO;
    isInCurrentView = NO;
    //防止退出此页面，tip仍然显示问题
    if (showTip) {
        [FLTipsBaseView dismissAll];
        showTip = NO;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [JFGSDK appendStringToLogFile:@"VideoPlayView viewDidDisappear"];
    self.isInCurrentVC = NO;
    isDidAppear = NO;
    if (playState == videoPlayStatePlaying) {
        [self playAction:self.playButton];
    }else{
        [self stopVideoPlay];
    }
    [self hideVideoPlayBar];
    playState = videoPlayStatePause;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnUpdateHistoryErrorCodeNotification" object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(void)removeHistoryDelegate
{
    self.historyView.delegate = nil;
}

-(void)onNotifyResolutionOvertime
{
    [self playRequestTimeoutDeal];
}

#pragma mark- sd卡状态
-(void)getSDCard
{
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(204),@(dpMsgCamera_isLive)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                
                if (seg.msgId == 204) {
                    JFGDeviceSDCardInfo *sdInfo = [JFGDataPointValueAnalysis dpFor204Msg:seg];
                    if (sdInfo) {
                        
                        isHasSDCard = sdInfo.isHaveCard;
                        sdCardErrorCode = sdInfo.errorCode;
                        if (isHasSDCard && isShared == NO) {
                            if (self.historyView.superview == nil) {
                                
                                [self.view addSubview:self.historyView];
                            }
                        }
                    }
                }else if (seg.msgId == dpMsgCamera_isLive){
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSArray class]]) {
                        
                        NSArray *arr = obj;
                        if (arr.count>0) {
                            id obj2 = arr[0];
                            if ([obj2 isKindOfClass:[NSNumber class]]) {
                                
                                BOOL isLive = [obj2 boolValue];
                                if (isLive) {
                                    self.devModel.safeIdle = YES;
                                    if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                                        [self stopVideoPlay];
                                        [self hideVideoPlayBar];
                                        [self showIdleView];
                                        if (isShared == NO) {
                                            self.historyView.hidden = YES;
                                        }
                                    }
                                }else{
                                    [self hideIdleView];
                                    self.devModel.safeIdle = NO;
                                }
                                
                            }
                        }
                        
                    
                    }else{
                        
                        self.devModel.safeIdle = NO;
                        
                    }
                }
                
               
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}

#pragma mark- 获取安全防护数据
-(void)warnSensitivity
{
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(303),@(501)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                if (seg.msgId == 501) {
                    //是否开启报警
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if (obj && [obj isKindOfClass:[NSNumber class]]) {
                        if ([obj boolValue]) {
                            isOpenWarn = YES;
                        }else{
                            isOpenWarn = NO;
                        }
                        
                    }else{
                        isOpenWarn = YES;
                    }
                    self.safeguardBtn.isFace = isOpenWarn;
                    
                    
                }else if(seg.msgId == 303){
                    //报警等级
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    int warnLever;
                    if (obj && [obj isKindOfClass:[NSNumber class]]){
                        warnLever = [obj intValue];
                    }else{
                        warnLever = 2;
                    }
                    
                    if (warnLever == 0) {
                        warnSensitivity = YES;
                    }else{
                        warnSensitivity = NO;
                    }
                }
            }
        }
        
        
    } failure:^(RobotDataRequestErrorType type) {
        NSLog(@"failed");
    }];
}

-(void)initialData
{
    
}




#pragma mark- 通知代理
-(void)addNotificationDelegate
{
    //网络代理
    [[NetworkMonitor sharedManager] addDelegate:self];
    
    /*!
     *  添加此类的代理
     */
    [JFGSDK addDelegate:self];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(safeIdleChanged:) name:JFGSettingOpenSafety object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidDisappear:) name:@"JFGJumpingRootView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidDisappear:) name:VideoPlayViewDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:) name:VideoPlayViewShowingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doorCalling:) name:JFGDoorBellIsCallingKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transformToVideoView:) name:@"JFGLookHistoryVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(angleChangedWithNotification:) name:angleChangedNotification object:nil];
}

-(void)removeAllNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//视频播放相关代理
-(void)addVideoNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnUpdateHistoryErrorCodeNotification" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onRecvDisconnectForRemote:) name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyErrorCode:) name:@"JFGSDKOnUpdateHistoryErrorCodeNotification" object:nil];
    
    //a
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotifyResolution:) name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotificatyRTCP:) name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
}

-(void)didBecomeActive
{
    if (isDidAppear) {
        
        [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        
            if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
                
                if (timer && timer.isValid) {
                    [timer invalidate];
                    timer = nil;
                }
                [self viewDidAppear:YES];
                
                
            }
            
        } repeats:YES];
        
       
        
        
    }
}

-(void)doorCalling:(NSNotification *)notification
{
    //NSString *cid = notification.object;
    if (windowMode == videoPlayModeFullScreen) {
        [self exitFullScreen];
    }
    [self viewDidDisappear:YES];
}

-(void)didEnterBackground
{
    if (windowMode == videoPlayModeSmallWindow) {
        //任何状态下都要停止播放
       [self viewDidDisappear:YES];
    }else{
        if (windowMode == videoPlayModeFullScreen) {
            [self exitFullScreen];
        }
        [self viewDidDisappear:YES];
    }
    isDidAppear = YES;//1491560175  1491825399
}

-(void)transformToVideoView:(NSNotification *)notification
{
    if (isShared == NO ) {
        NSNumber *num = notification.object;
        uint64_t timestamp = [num unsignedLongLongValue];
        //NSLog(@"transformToVideoTime:%lld",timestamp);
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"transformToVideoTime:%lld",timestamp/1000]];
        isLiveVideo = NO;
        historyLastestTimeStamp = timestamp/1000;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGLookHistoryVideo2" object:nil];
//        [self hideDisconnectNetView];
//        if (playState == videoPlayStatePlaying) {
//            [CylanJFGSDK playVideoByTime:timestamp cid:self.cid];
//            [self voiceAndMicBtnNomalState];
//            [self fullVoiceAndMicBtnDisableState];
//        }else{
//            [self playHistoryVideoForZeroWithTimestamp:timestamp];
//        }
        
        if (self.historyView.dataArray.count) {
             [self.historyView setHistoryTableViewOffsetByTimeStamp:historyLastestTimeStamp];
        }
        
       
//        self.playButton.selected = YES;
//        self.fullPlayBtn.selected = YES;
//        [self performSelector:@selector(hideVideoPlayBar) withObject:nil afterDelay:3];
    }
}

#pragma mark- HistoryDatePickerDelegate
-(void)cancel
{
    
}

-(void)didSelectedItem:(NSString *)item indexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%@",item);
    HistoryVideoDayModel *model = [historyVideoDateLimits objectAtIndex:indexPath.row];
    
    for (NSArray *subArr in self.historyView.dataArray) {
        
        for (historyVideoDurationTimeModel *md in subArr) {
            
            if (md.startTimestamp == model.timestamp && md.startPosition == model.startPosition) {
                currentHistoryModel = md;
                break;
            }
            
        }
        
    }
    
    //NSLog(@"%@",model.timeStr);
    isLiveVideo = NO;
    
    if (playState == videoPlayStatePlaying) {
        //[CylanJFGSDK switchLiveVideo:NO beigenTime:model.timestamp];
        [CylanJFGSDK playVideoByTime:model.timestamp cid:self.cid];
        [self voiceAndMicBtnNomalState];
        [self fullVoiceAndMicBtnDisableState];

    }else{
        [self playHistoryVideoForZeroWithTimestamp:model.timestamp];
    }
    
    
    [self.historyView startHistoryVideoFromDay:model];
    
    if (windowMode == videoPlayModeSmallWindow) {
        [self performSelector:@selector(hideVideoPlayBar) withObject:nil afterDelay:3];
    }else{
        [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
    }
}

-(void)selectedItem:(NSString *)item index:(NSInteger)index
{
    HistoryVideoDayModel *model = [historyVideoDateLimits objectAtIndex:index];
    isLiveVideo = NO;
    if (playState == videoPlayStatePlaying) {
        //[CylanJFGSDK switchLiveVideo:NO beigenTime:model.timestamp];
        [CylanJFGSDK playVideoByTime:model.timestamp cid:self.cid];
        [self voiceAndMicBtnNomalState];
        [self fullVoiceAndMicBtnDisableState];

    }else{
        [self playHistoryVideoForZeroWithTimestamp:model.timestamp];
    }
    [self.historyView startHistoryVideoFromDay:model];
    
    for (NSArray *subArr in self.historyView.dataArray) {
        
        for (historyVideoDurationTimeModel *md in subArr) {
            
            if (md.startTimestamp == model.timestamp && md.startPosition == model.startPosition) {
                currentHistoryModel = md;
                break;
            }
        }
        
    }
    
}

#pragma mark- HorizontalHistoryRecordViewDelegate
//开始滚动历史视频进度条
-(void)historyBarStartScroll
{
    if (windowMode == videoPlayModeSmallWindow) {
         [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideVideoPlayBar) object:nil];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFullVideoPlayBar) object:nil];
    }
}


//停止滚动历史视频进度条
-(void)historyBarEndScroll
{
    if (windowMode == videoPlayModeSmallWindow) {
        [self performSelector:@selector(hideVideoPlayBar) withObject:nil afterDelay:3];
    }else{
        [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
    }
}

//历史视频滚动条目前指示位置的视频模型数据
-(void)currentHistoryVideoModel:(historyVideoDurationTimeModel *)model
{
    currentHistoryModel = model;
    isLiveVideo = NO;
    if (playState == videoPlayStatePlaying) {
        ///[CylanJFGSDK switchLiveVideo:NO beigenTime:model.startPlayTimestamp];
        [CylanJFGSDK playVideoByTime:model.startTimestamp cid:self.cid];
        [self voiceAndMicBtnNomalState];
        [self fullVoiceAndMicBtnDisableState];
    }else{
        [self playHistoryVideoForZeroWithTimestamp:model.startTimestamp];
    }
    self.playButton.selected = YES;
    self.fullPlayBtn.selected = YES;
    
    if (windowMode == videoPlayModeSmallWindow) {
        [self performSelector:@selector(hideVideoPlayBar) withObject:nil afterDelay:3];
    }else{
        [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
    }
    
    
}

//所有有历史视频的日期
-(void)historyVideoDateLimits:(NSArray<HistoryVideoDayModel *> *)limits
{
    historyVideoDateLimits = [[NSMutableArray alloc]initWithArray:limits];
    if (self.devModel.safeIdle) {
        self.historyView.hidden = YES;
    }
    if (playState == videoPlayStatePlayPreparing) {
        self.historyView.hidden = YES;
        return;
    }
    if (windowMode == videoPlayModeSmallWindow) {
        if (self.videoBottomBar.hidden) {
            self.historyView.hidden = YES;
        }else{
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
        }
    }else{
        self.historyView.alpha = 1;
        self.historyView.hidden = NO;
    }
    
}

-(void)historyVideoAllList:(NSArray <NSArray <historyVideoDurationTimeModel *>*>*)list
{
     historyAllList = [[NSArray alloc]initWithArray:list];
}


#pragma mark- 历史视频返回直播
//历史视频返回直播
-(void)transionHistoryVideo:(BOOL)isHistory
{
    isLiveVideo = YES;
//    if (playState == videoPlayStatePlaying) {
//        [CylanJFGSDK switchLiveVideo:YES beigenTime:0];
//    }else{
//        [self stopVideoPlay];
//        [self historyCurrentModeByTimestamp];
//        [self startLodingAnimation];
//        [CylanJFGSDK connectCamera:self.cid];
//    }
    [self stopVideoPlay];
    [self historyCurrentModeByTimestamp];
    [self startLodingAnimation];
    [CylanJFGSDK connectCamera:self.cid];
}

#pragma mark- 视频播放
-(void)startLiveVideo
{
    if (playState == videoPlayStatePlaying) {
        return;
    }
    playState = videoPlayStatePlayPreparing;
    [self startLodingAnimation];
    [self startTimeoutRequest];
    /*!
     *  开始视频直播 获取视频播放视图
     *  可以通过回调#jfgRTCPNotifyBitRate:videoRecved:frameRate:timesTamp: 查看视频加载情况
        长时间接收视频数据为0，则为网络状况差或者超时。
     */
    
    isLiveVideo = YES;
    [CylanJFGSDK connectCamera:self.cid];
    self.videoPlayBgScrollerView.hidden = NO;
    self.playButton.selected = YES;
    
    
    if (self.snapeImageView.superview != self.videoPlayBgScrollerView) {
        [self.videoPlayBgScrollerView addSubview:self.snapeImageView];
    }
    
    if (self.videoPlayBgScrollerView.contentSize.width > 0) {
        self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
    }else{
        self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.bounds.size.width, self.videoPlayBgScrollerView.bounds.size.height);
    }
    
    
    if (self.videoPlayBgScrollerView.superview != self.videoBgView) {
        [self.videoBgView addSubview:self.videoPlayBgScrollerView];
        [self.videoBgView bringSubviewToFront:self.loadingBgView];
    }
    if (self.historyView) {
        self.historyView.isSelectedHistory = NO;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}


#pragma mark- JFGSDK delegate
- (void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
    if ([peer isEqualToString:self.cid]) {
        
        for (DataPointSeg *seg in msgList) {
            
            switch (seg.msgId)
            {
                case dpMsgBase_SDCardInfoList:
                {
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    
                    if ([obj isKindOfClass:[NSArray class]])
                    {
                        BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
                        
                        if (isExistSDCard == NO)
                        {
//                            (self.devModel.shareState != DevShareStatuOther)
                            if ([[CommonMethod viewControllerForView:self.view] isKindOfClass:[VideoPlayViewController class]] && self.isInCurrentVC &&  !isShared)
                            {
                                isHasSDCard = NO;
                                self.historyView.hidden = YES;
                                [self.historyView.dataArray removeAllObjects];
                                if (!isLiveVideo) {
                                    [self stopVideoPlay];
                                }
                                NSLog(@"msg_SD_OFF");
                                UIAlertView *aler = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil];
                                
                                [aler showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                                    
                                    if (!isLiveVideo) {
                                        isLiveVideo = YES;
                                        
                                        if (windowMode == videoPlayModeSmallWindow) {
                                            self.playButton.selected = NO;
                                            [self playAction:self.playButton];
                                        }else{
                                            self.fullPlayBtn.selected = NO;
                                            [self fullPlayAction:self.fullPlayBtn];
                                        }
                                    }
                                    
                                } otherDelegate:nil];
                                
                            }
                        }
                        
                    }
                }
                    break;
                    
                case dpMsgCamera_isLive:{
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSArray class]]) {
                        
                        NSArray *arr = obj;
                        if (arr.count>0) {
                            id obj2 = arr[0];
                            if ([obj2 isKindOfClass:[NSNumber class]]) {
                                
                                BOOL isLive = [obj2 boolValue];
                                if (isLive) {
                                    self.devModel.safeIdle = YES;
                                    if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                                        [self stopVideoPlay];
                                        [self hideVideoPlayBar];
                                        [self showIdleView];
                                        if (isShared == NO) {
                                            self.historyView.hidden = YES;
                                        }
                                    }
                                }else{
                                    self.devModel.safeIdle = NO;
                                    
                                    if (isDidAppear) {
                                        [self hideIdleView];
                                        [self viewDidAppear:YES];
                                    }
                                    
                                }
                                
                            }
                        }
                        
                        
                    }
                }
                    break;
                case dpMsgCamera_Angle:{
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                        
                        self.angleType = [obj intValue];
                        UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
                        if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
                            PanoramicIosView * _remoteView = (PanoramicIosView *)remoteView;
                            if (self.angleType == 1) {
                                //挂壁
                                [_remoteView setMountMode:MOUNT_WALL];
                            }else{
                                //吊顶
                                [_remoteView setMountMode:MOUNT_TOP];
                            }
                        }
                    }
                }
                    break;
                    
                case 203:{//格式化sd卡
                    
                    self.historyView.hidden = YES;
                    [self.historyView.dataArray removeAllObjects];
                    
                    if (!isLiveVideo) {
                        [self stopVideoPlay];
                    }
                    
                    if (isDidAppear)
                    {
                        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips6"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil];
                        
                        [aler showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                            
                            if (!isLiveVideo) {
                                isLiveVideo = YES;
                                if (windowMode == videoPlayModeSmallWindow) {
                                    [self playAction:self.playButton];
                                }else{
                                    [self fullPlayAction:self.fullPlayBtn];
                                }
                            }
                            
                        } otherDelegate:nil];
                    }
                }
                    break;
                    
                default:
                    break;
            }
           
            
        }
        
        
    }
    
}

//历史录像错误回调
-(void)historyErrorCode:(NSNotification *)notification
{
    /*
     "SD_ERR" = "SD卡读取错误";
     "FILE_ERR" = "录像文件错误";
     "FILE_FINISHED" = "录像已播完";
     */
    
    if (isHasSDCard == NO) {
        return;
    }
    if (isLiveVideo) {
        return;
    }
    JFGSDKHistoryVideoErrorInfo *errorInfo = notification.object;
    if (errorInfo.code == 2030) {
       
        //历史录像播放完成
        [self stopVideoPlay];

        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"TIPS"] message:[JfgLanguage getLanTextStrByKey:@"RECORD_NO_FIND"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil];
    
        [aler showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            if (windowMode == videoPlayModeSmallWindow) {
                [self playAction:self.playButton];
            }else{
                [self fullPlayAction:self.fullPlayBtn];
            }
            
        } otherDelegate:nil];
        //保留播放控件
        if (windowMode == videoPlayModeSmallWindow) {
            self.playButton.selected = NO;
        }else{
            self.fullPlayBtn.selected = NO;
        }
        isLiveVideo = YES;
        
    }else if (errorInfo.code == 2031){
        //历史录像读取失败
        [self stopVideoPlay];
        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"TIPS"] message:[JfgLanguage getLanTextStrByKey:@"FILE_ERR"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil];
        [aler showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            if (windowMode == videoPlayModeSmallWindow) {
                [self playAction:self.playButton];
            }else{
                [self fullPlayAction:self.fullPlayBtn];
            }
            
        } otherDelegate:nil];
        //保留播放控件
        if (windowMode == videoPlayModeSmallWindow) {
            self.playButton.selected = NO;
        }else{
            self.fullPlayBtn.selected = NO;
        }
        isLiveVideo = YES;
        
    }else if (errorInfo.code == 2032){
        //sd卡错误
        [self stopVideoPlay];
        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"TIPS"] message:[JfgLanguage getLanTextStrByKey:@"SD_ERR"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil];
        [aler showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            if (windowMode == videoPlayModeSmallWindow) {
                [self playAction:self.playButton];
            }else{
                [self fullPlayAction:self.fullPlayBtn];
            }
            
        } otherDelegate:nil];
        //保留播放控件
        if (windowMode == videoPlayModeSmallWindow) {
            self.playButton.selected = NO;
        }else{
            self.fullPlayBtn.selected = NO;
        }
        isLiveVideo = YES;
    }
}

-(void)onNotifyResolution:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *dict = notification.object;
        if (dict) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onNotifyResolutionOvertime) object:nil];
            int width = [[dict objectForKey:@"width"] intValue];
            int height = [[dict objectForKey:@"height"] intValue];
            NSLog(@"originSize:%@",NSStringFromCGSize(CGSizeMake(width, height)));
            CGSize size = CGSizeMake(width, height);
            
            //防止多次接受通知
            if (playState == videoPlayStatePlaying) {
                return;
            }
            
            UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
            if (remoteView) {
                [remoteView removeFromSuperview];
                remoteView = nil;
            }
            
            NSInteger pid = [self.devModel.pid integerValue];
            UIView *_remoteView;
            if (pid == 18) {
                width = self.view.width;
                height= width;
                size = CGSizeMake(width, width);
                PanoramicIosView * __remoteView = [[PanoramicIosView alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [__remoteView configV360:getSFCParamIosPreset()];
                _remoteView = __remoteView;
                //MODE_TOP = 0 吊顶 MODE_WALL = 1 壁挂
                if (self.angleType == 1) {
                    //挂壁
                    [__remoteView setMountMode:MOUNT_WALL];
                }else{
                    //吊顶
                    [__remoteView setMountMode:MOUNT_TOP];
                }
                
                UITapGestureRecognizer *panTap = [__remoteView getDoubleTapRecognizer];
                [videoTapGesture requireGestureRecognizerToFail:panTap];
                
            }else{
                _remoteView = [[VideoRenderIosView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
            }
            
            _remoteView.tag = VIEW_REMOTERENDE_VIEW_TAG;
            _remoteView.backgroundColor = [UIColor blackColor];
            _remoteView.layer.edgeAntialiasingMask = YES;
            [self.videoPlayBgScrollerView addSubview:_remoteView];
            [CylanJFGSDK startRenderRemoteView:_remoteView];
            remoteCallViewSize = size;
            
            if (isLiveVideo == NO) {
                
                [self voiceAndMicBtnNomalState];
                [self fullVoiceAndMicBtnDisableState];
                
            }
            [JFGSDK appendStringToLogFile:@"onNotifyResolution remoteViewSizeFit"];
            [self remoteViewSizeFit];
            if (playState != videoPlayStatePlaying)
            {
                [self voiceAndMicBtnNomalState];
                [self fullVideoAndMicBtnNomal];
            }
            
            [self stopLoadingAnimation];
            [self isFristIntoView];
            
            if (self.rateLabel.superview == nil) {
                [self.videoBgView addSubview:self.rateLabel];
            }
            self.rateLabel.hidden = NO;
            self.rateLabel.alpha = 1;
            self.rateLabel.text = [NSString stringWithFormat:@"%.0fK/s",0.0];
            [self.videoBgView bringSubviewToFront:self.rateLabel];
            
            if (windowMode == videoPlayModeSmallWindow) {
                self.videoPlayTipLabel.x = self.view.width*0.5;
                self.videoPlayTipLabel.bottom = self.videoBgView.height-8;
            }else{
                self.videoPlayTipLabel.x = kheight*0.5;
                self.videoPlayTipLabel.bottom = self.fullScreenBottomControlBar.top-10;
            }
            playState = videoPlayStatePlaying;
            self.videoPlayTipLabel.hidden = NO;
            [self.videoBgView addSubview:self.videoPlayTipLabel];
            
            
        }
        
    });
    
    

//        dat =  [NSMutableString stringWithString:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timesTamp]]];
//        [dat insertString:[NSString stringWithFormat:@"%@| ",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Playback"]]  atIndex:0];
//        BOOL isStop = [self.historyView setHistoryTableViewOffsetByTimeStamp:timesTamp];

    
}

-(void)onNotificatyRTCP:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    if (dict) {
        int bitRate = [dict[@"bit"] intValue];
        //int frameRate = [dict[@"frameRate"] intValue];
        long long timesTamp = [dict[@"timestamp"] intValue];
        NSLog(@"timestamp:%lld",timesTamp);
        //int videorecved = [dict[@"videoRecved"] intValue];
        historyLastestTimeStamp = timesTamp;
        
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MM/dd HH:mm"];
        }
        
        if (bitRate == 0) {
            [self startTimeoutRequest];
        }else{
            [self stopTimeoutRequest];
        }
    
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
        
        
        NSMutableString *dat;
        
        if (isLiveVideo) {
            
            dat =  [NSMutableString stringWithString:[dateFormatter stringFromDate:[NSDate date]]];
            
            NSString *liveLanguage = [NSString stringWithFormat:@"%@| ",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_VideoLive"]];
            
            [NSString stringWithFormat:@"%@|5/16 12:30",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_VideoLive"]];
            [dat insertString:liveLanguage atIndex:0];
            
            //保留播放控件
            if (windowMode == videoPlayModeSmallWindow) {
                self.playButton.selected = YES;
            }else{
                self.fullPlayBtn.selected = YES;
            }

        }else{

            if (timesTamp == 0) {
                dat =  [NSMutableString stringWithString:[dateFormatter stringFromDate:[NSDate date]]];
            }else{
                 dat =  [NSMutableString stringWithString:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timesTamp]]];
            }
            
            NSString *liveLanguage = [NSString stringWithFormat:@"%@| ",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Playback"]];
            [dat insertString:liveLanguage atIndex:0];
            
            if (self.historyView.dataArray.count) {
                [self.historyView setHistoryTableViewOffsetByTimeStamp:timesTamp];
            }
            
            
            
        }
        self.videoPlayTipLabel.text = dat;
        //CGFloat m = videoRecved/1024.0/1024.0;
        CGFloat kb = bitRate/8;
        //NSString *recoredStr =[NSString stringWithFormat:@"%.0fK/s  %.1fM",kb,m];
        //    if (m>1024) {
        //        recoredStr =[NSString stringWithFormat:@"%.0fK/s  %.1fG",kb,m/1024.0];
        //    }
        
        if (kb>1024) {
            self.rateLabel.text = [NSString stringWithFormat:@"%.1fM/s",kb/1024];
        }else{
            self.rateLabel.text = [NSString stringWithFormat:@"%.0fK/s",kb];
        }
        NSLog(@"bit:%fkb/s",kb);
    }
}



-(void)onRecvDisconnectForRemote:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSString *remoteID = dict[@"remote"];
    NSLog(@"disConnect:%@",remoteID);
    

    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"Disconnect:%@ errorType:%@",remoteID,dict[@"error"]]];
    
    if ([remoteID isEqualToString:self.cid] || [remoteID isEqualToString:@"server"]) {
        
        [self stopVideoPlay];
        JFGErrorType errorType = (JFGErrorType)[dict[@"error"] intValue];
        [self showDisconnectViewWithText:[CommonMethod languaeKeyForLiveVideoErrorType:errorType]];
        if (isShared == NO) {
            self.historyView.hidden = YES;
        }
        playState = videoPlayStateDisconnectCamera;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
        
    }
    
}



-(void)startTimeoutRequest
{
    if (timeoutRequestCount == 0) {
        [self performSelector:@selector(playRequestTimeoutDeal) withObject:nil afterDelay:30];
        timeoutRequestCount++;
    }
}

-(void)stopTimeoutRequest
{
    if (timeoutRequestCount != 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playRequestTimeoutDeal) object:nil];
        timeoutRequestCount --;
    }
}

-(void)rtcpLowAction
{
    if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
        [self startLodingAnimation];
    }
    
}

#pragma mark 网络环境改变代理
-(void)networkChanged:(NetworkStatus)statu
{
    if (statu == NotReachable) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
            playState = videoPlayStateNotNet;
            [self hideVideoPlayBar];
            [self stopVideoPlay];
            
            if (isShared == NO) {
                self.historyView.hidden = YES;
            }
            [self showDisconnectViewWithText:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
            
        });
        
    }
}

-(void)playRequestTimeoutDeal
{
    if (windowMode == videoPlayModeFullScreen) {
        [self exitFullScreen];
    }
    playState = videoPlayStateDisconnectCamera;
    [self hideVideoPlayBar];
    [self stopVideoPlay];
    self.videoPlayTipLabel.hidden = YES;
    if (isShared == NO) {
        self.historyView.hidden = YES;
    }
    [self showDisconnectViewWithText:[JfgLanguage getLanTextStrByKey:@"Tips_Device_TimeoutRetry"]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
}


//停止视频播放
-(void)stopVideoPlay
{
    if (playState == videoPlayStatePlaying) {
        [self snapScreen];
        [CylanJFGSDK setAudio:YES openMic:NO openSpeaker:NO];
        [CylanJFGSDK setAudio:NO openMic:NO openSpeaker:NO];
    }
    self.rateLabel.hidden = YES;
    [self voiceAndMicBtnDisableState];
    [CylanJFGSDK stopRenderView:NO withCid:self.cid];
    if (self.cid) {
        [CylanJFGSDK disconnectVideo:self.cid];
    }else{
        [CylanJFGSDK disconnectVideo:@""];
    }
    UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        
        if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
            
            PanoramicIosView *rvc = (PanoramicIosView *)remoteView;
            [rvc stopRender];
        }
        [remoteView removeFromSuperview];
        remoteView = nil;
        [JFGSDK appendStringToLogFile:@"remoteRemoveFromSuperView"];
    }
    playState = videoPlayStatePause;
    self.videoPlayTipLabel.hidden = YES;
    [self stopLoadingAnimation];
    [self stopTimeoutRequest];
    
}



#pragma mark  ------调整 视频View  -----------
//等比缩放
- (void)remoteViewSizeFit
{
    CGFloat ratio = 1.0;
    CGFloat width;
    if (windowMode == videoPlayModeFullScreen) {

        width = self.view.bounds.size.height;
        
    }else{
        
        width = self.view.bounds.size.width;
    }
    
    
    ratio = remoteCallViewSize.height/remoteCallViewSize.width;
    CGFloat height = width * ratio;
    
    UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        
        remoteView.frame = CGRectMake(0, 0, self.videoBgView.bounds.size.width, height);
        [self.videoPlayBgScrollerView setContentSize:CGSizeMake(width, height)];
        
        if (windowMode == videoPlayModeSmallWindow) {
            
            self.videoBgView.height = height;
            self.videoPlayBgScrollerView.height = height;
            self.playButton.top = self.videoBgView.height*0.36;
            self.historyView.top = self.videoBgView.height;
            self.loadingBgView.height = self.videoBgView.height;
            self.loadingImageView1.y = self.loadingBgView.height*0.5;
            
        }else{
            
            if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
                remoteView.height = self.view.width;
                PanoramicIosView *rpv = (PanoramicIosView *)remoteView;
                [rpv detectOrientationChange];
            }
            
        }
        [self layoutBottomBtn];
    }
    self.snapeImageView.frame = self.videoBgView.bounds;
    [self.videoPlayBgScrollerView setContentOffset:CGPointMake(0, 0)];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"remoteViewSize:%@",NSStringFromCGRect(remoteView.frame)]];
    
}

#pragma mark- UIScrollerView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (scrollView == self.videoPlayBgScrollerView) {
    
        self.snapeImageView.hidden = YES;
        UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        return remoteView;
    }
    return nil;
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    if (scrollView == self.videoPlayBgScrollerView) {
        
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
//            
//        }

    }
   

}


#pragma mark- action
//截图
-(void)snapScreen
{
    if (playState!=videoPlayStatePlaying) {
        return;
    }
    UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    UIImage *image = nil;
    if (remoteView && [remoteView isKindOfClass:[PanoramicIosView class]]) {
        
        PanoramicIosView *_remoteView =(PanoramicIosView *)remoteView;
        image = [_remoteView takeSnapshot];
        
    }else{
       image = [CylanJFGSDK imageForSnapshot];
    }

    if (image == nil) {
        return;
    }
    self.snapeImageView.image = image;
    NSData *imageData = UIImagePNGRepresentation(image);
    
    if ([imageData isKindOfClass:[NSData class]]) {
        imageData = UIImageJPEGRepresentation(image, 1);
    }else{
        return;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@",snapShotKey,self.cid]];
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[NSString stringWithFormat:@"%@_%@",snapShotKey,self.cid]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//摄像头声音
-(void)voiceAction:(UIButton *)sender
{
    if (!isTalkBack) {
        sender.selected  = !sender.selected;
        isAudio = sender.selected;
        [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
    }

    if (windowMode == videoPlayModeFullScreen) {
        self.voiceButton.selected = sender.selected;
    }else{
        self.fullVoideBtn.selected = sender.selected;
    }
}

//对讲功能
-(void)microphoneAction:(UIButton *)sender
{
    if (!isLiveVideo) {
        return;
    }
    
    if (sender.selected) {
        
        [_voiceButton setImage:[UIImage imageNamed:@"btn_closevoice"] forState:UIControlStateNormal];
        [_fullVoideBtn setImage:[UIImage imageNamed:@"full-screen_ico_closevoice"] forState:UIControlStateNormal];
        isTalkBack = NO;
        sender.selected = NO;
        [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
        [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
        self.voiceButton.enabled = YES;
        self.fullVoideBtn.enabled = YES;
        
    }else{
        
        if ([JFGEquipmentAuthority canRecordPermission]) {
            
            isTalkBack = YES;
            sender.selected = YES;
            [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:YES];
            [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:YES];
            
            self.voiceButton.enabled = NO;
            self.fullVoideBtn.enabled = NO;
            [self.voiceButton setImage:[UIImage imageNamed:@"camera_ico_voice"] forState:UIControlStateNormal];
            [self.fullVoideBtn setImage:[UIImage imageNamed:@"full-screen_ico_voice"] forState:UIControlStateNormal];
            
        }else{
            return;
        }
        
        
        
    }
    
    if (windowMode == videoPlayModeFullScreen) {
        self.microphoneBtn.selected = sender.selected;
        self.voiceButton.enabled = self.fullVoideBtn.enabled ;
    }else{
        self.fullMicBtn.selected = sender.selected;
        self.fullVoideBtn.enabled = self.voiceButton.enabled;
    }
    
    
}

-(void)snap
{
    //防止连续点击
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(snapBtnAction) object:nil];
    [self performSelector:@selector(snapBtnAction) withObject:nil afterDelay:1];
}


-(void)snapBtnAction
{
    if (playState == videoPlayStatePlaying) {
        
        UIImage *image = [CylanJFGSDK imageForSnapshot];
        
        
        
        if (image) {
            [self snapAnimation];
            [self showSnapSmallWidow:image];
            
                
#pragma mark- 发送截图到每日精彩
            NSError * error = nil;
            DataPointSeg * seg1 = [[DataPointSeg alloc]init];
            seg1.msgId = dpMsgAccount_Wonder;
            
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
            
            int64_t time = (int64_t)[timeString longLongValue];
            
            NSString *fileName = [NSString stringWithFormat:@"%lld_1.jpg",time];
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,self.cid,fileName];
            [JFGSDK uploadFile:[self saveImage:image] toCloudFolderPath:wonderFilePath];
            
            
            NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
            NSString *alias = self.cid;
            for (JiafeigouDevStatuModel *model in list) {
                if ([model.uuid isEqualToString:self.cid]) {
                    alias = model.alias;
                    break;
                }
            }
            
            seg1.value = [MPMessagePackWriter writeObject:@[self.cid,[NSNumber numberWithLongLong:time],@0,@(0),fileName,alias] error:&error];
            
            [[JFGSDKDataPoint sharedClient]robotSetDataWithPeer:self.cid dps:@[seg1] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                
                for (DataPointIDVerRetSeg *seg in dataList) {
                    if (seg.ret == 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:JFGExploreRefreshNotificationKey object:nil userInfo:nil];
                        break;
                    }
                }
                
                
            } failure:^(RobotDataRequestErrorType type) {
                NSLog(@"error：%ld",(long)type);
            }];
            
            [JFGAlbumManager jfgWriteImage:image toPhotosAlbum:nil completionHandler:^(UIImage *image, NSError *error) {
                
            }];
        }else{
            //
            [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"Item_LoadFail"] position:FLProgressHUDPositionCenter];
            [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
        }
        
        
       
        
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"呵呵";
    if (!error) {
        message = @"成功保存到相册";
    }else
    {
        message = [error description];
    }
    NSLog(@"message is %@",message);
}


//设置安全待机跳转事件
-(void)gotoIdleSetting
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JFGGotoSettingKey object:nil];
}

//无网络连接，重试按钮事件
-(void)disconnectNetAction
{
    if ([NetworkMonitor sharedManager].currentNetworkStatu != NotReachable) {
        if ([LoginManager sharedManager].loginStatus ==JFGSDKCurrentLoginStatusSuccess) {
            
            [self hideDisconnectNetView];
            [self viewDidAppear:YES];
            return;
        }
       
    }
    [CommonMethod showNetDisconnectAlert];
}


#pragma mark- 点击显示隐藏播放按钮
-(void)videoViewTap
{
    //视频加载中，不显示播放按钮等控件
    if (playState == videoPlayStatePlayPreparing) {
        return;
    }
    
    if (windowMode == videoPlayModeFullScreen) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFullVideoPlayBar) object:nil];
        if (self.fullScreenTopControlBar.top == 0) {
            [self hideFullVideoPlayBar];
        }else{
            [self showFullVideoPlayBar];
            [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
        }
        
    }else{
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideVideoPlayBar) object:nil];
        if (self.videoBottomBar.hidden) {
            [self showVideoPlayBar];
            [self performSelector:@selector(hideVideoPlayBar) withObject:nil afterDelay:3];
        }else{
            [self hideVideoPlayBar];
        }
    }
    
    
}


#pragma mark- 安全防护
//安全防护
-(void)safeguarAction:(SafaButton *)safeSender
{
    //__block BOOL isSafe = NO
    if (safeSender.isFace && warnSensitivity && isHasSDCard) {
        
        if (safeSender == self.safeguardBtn_full) {
            
            [LSAlertView showAlertForTransformRotateWithTitle:@"" Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_MotionDetection_OffTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] CancelBlock:^{
                
                [self switchSafeForOpen:!safeSender.isFace];
                
            } OKBlock:^{
                
                
                
            }];

        }else{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_MotionDetection_OffTips"] delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"CANCEL"], nil];
            alertView.tag = SAFA_ALTER_TAG;
            [alertView show];
        }
        
        
        return;
        
    }

    [self switchSafeForOpen:!safeSender.isFace];
    
    
}

//待机开启通知
-(void)safeIdleChanged:(NSNotification *)notification
{
    BOOL isOpen = [notification.object boolValue];
    if (self.devModel.safeIdle != isOpen) {
        self.devModel.safeIdle = isOpen;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SAFA_ALTER_TAG && buttonIndex == 0) {
        [self switchSafeForOpen:!self.safeguardBtn.isFace];
    }
}

-(void)switchSafeForOpen:(BOOL)open
{
    //self.safeguardBtn.isFace = self.safeguardBtn_full.isFace = open;
    __block BOOL isSafe = NO;
    DataPointSeg *seg = [[DataPointSeg alloc]init];
    seg.msgId = 501;
    seg.version = 0;
    seg.value = [MPMessagePackWriter writeObject:[NSNumber numberWithBool:open] error:nil];
    isSafe = YES;
    
    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.cid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
    
        self.safeguardBtn.isFace = !self.safeguardBtn.isFace;
        self.safeguardBtn_full.isFace = !self.safeguardBtn_full.isFace;
        [self warnSensitivity];
        [JFGSDK refreshDeviceList];
        
    } failure:^(RobotDataRequestErrorType type) {
        
        
        
    }];
    
}

#pragma mark- 历史视频
//历史视频时间选择
-(void)historyVideoSelectAction
{
    if (isShared) {
        return;
    }
    
    if (!isHasSDCard) {
        //没有sd卡
        
        if (windowMode == videoPlayModeSmallWindow) {
            
            [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_NoSDCardTips"] position:FLProgressHUDPositionCenter];
            [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1.5];
            
        }else{
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [FLProressHUD hideAllHUDForView:window animation:NO delay:0];
            FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
            hud.textLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_NoSDCardTips"];
            hud.position = FLProgressHUDPositionCenter;
            hud.showProgressIndicatorView = NO;
            hud.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
            [hud showInView:window animated:YES];
            [FLProressHUD hideAllHUDForView:window animation:YES delay:1.5];
        }
        
        return;
    }else{
        if (sdCardErrorCode != 0) {
            
            if (windowMode == videoPlayModeSmallWindow) {
                
                [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"] position:FLProgressHUDPositionCenter];
                [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1.5];
                
            }else{
                
                //适配全屏旋转
                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                [FLProressHUD hideAllHUDForView:window animation:NO delay:0];
                FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
                hud.textLabel.text = [JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"];
                hud.position = FLProgressHUDPositionCenter;
                hud.showProgressIndicatorView = NO;
                hud.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
                [hud showInView:window animated:YES];
                [FLProressHUD hideAllHUDForView:window animation:YES delay:1.5];
            }
            
           
            return;
        }
    }
    
    //有可使用的sd卡，但是没有获取到录像数据
    if (!self.historyView.dataArray.count) {
        [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"NO_CONTENTS_2"] position:FLProgressHUDPositionCenter];
        [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
        return;
    }
    
    if (windowMode == videoPlayModeSmallWindow) {
        
        HistoryDatePicker *picker = [HistoryDatePicker historyDatePicker];        
        NSMutableArray *dateList = [[NSMutableArray alloc]init];
        
        for (HistoryVideoDayModel *model in historyVideoDateLimits) {
            [dateList addObject:model.timeStr];
        }
        picker.title = @"";
        picker.dataArray = (NSMutableArray *)[NSArray arrayWithObject:dateList];
        picker.delegate = self;
        [picker show];
        
    }else{
        
        FullScreenHistoryDatePicker *fullPicker = [FullScreenHistoryDatePicker fullScreenHistoryDatePicker];
        NSMutableArray *dateList = [[NSMutableArray alloc]init];
        
        for (HistoryVideoDayModel *model in historyVideoDateLimits) {
            
            [dateList addObject:model.timeStr];
        }
        fullPicker.dataArray = [[NSArray alloc]initWithArray:dateList];
        fullPicker.delegate = self;
        [fullPicker show];
        
        
    }
    
    
    
}



#pragma mark- 播放暂停事件
//竖屏播放暂停按钮事件
-(void)playAction:(UIButton *)sender
{
    if (sender.selected == NO) {
        //播放
        if (isLiveVideo) {
            [self startLiveVideo];
        }else{
            [self playCurrentHistoryVideo];
        }
        [self hideVideoPlayBar];
        sender.selected = YES;
        
    }else{
        //暂停
        [self stopVideoPlay];
        [self showVideoPlayBar];
        sender.userInteractionEnabled = NO;
        
        //防止执行停止播放后，rtcp回调代理处会把按钮状态改变
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            sender.userInteractionEnabled = YES;
            sender.selected = NO;
            
        });
        
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideVideoPlayBar) object:nil];
        [self historyCurrentModeByTimestamp];
        
    }
    self.fullPlayBtn.selected = sender.selected;
}

-(void)playHistoryVideoForZeroWithTimestamp:(int64_t)time
{
    historyLastestTimeStamp = time;
    if (playState != videoPlayStatePlaying && isLiveVideo == NO) {
        
        [self hideVideoPlayBar];
        self.playButton.selected = YES;
        [self startLodingAnimation];
        
        [CylanJFGSDK playVideoByTime:historyLastestTimeStamp cid:self.cid];
        
        self.videoPlayBgScrollerView.hidden = NO;
        if (self.videoPlayBgScrollerView.contentSize.width > 0) {
            self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
        }else{
            self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.bounds.size.width, self.videoPlayBgScrollerView.bounds.size.height);
        }
    }
}

//全屏播放暂停按钮事件
-(void)fullPlayAction:(UIButton *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFullVideoPlayBar) object:nil];
    
    if (sender.selected == NO) {
        //播放
        if (isLiveVideo) {
            [self startLiveVideo];
        }else{
            [self playCurrentHistoryVideo];
        }
        
        sender.selected = YES;
        
    }else{
        //暂停
        [self stopVideoPlay];
        [self historyCurrentModeByTimestamp];
        sender.userInteractionEnabled = NO;
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            sender.userInteractionEnabled = YES;
            sender.selected = NO;
            
        });
        
    }
    [self fullVoiceAndMicBtnDisableState];
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.playButton.selected = sender.selected;
    });
    
}

-(void)historyCurrentModeByTimestamp
{
    if (isLiveVideo == NO) {
        
        for (int i=0; i<historyAllList.count; i++) {
            
            NSArray *subArr = historyAllList[i];
            for (int j=0; j<subArr.count; j++) {
                
                historyVideoDurationTimeModel *model = subArr[j];
                BOOL isE = [model isBetweenWithPositionByTimestamp:historyLastestTimeStamp];
                if (isE) {
                    currentHistoryModel = model;
                    break;
                }
                
            }
            
        }
        
    }
}

-(void)playCurrentHistoryVideo
{
    if (isLiveVideo == NO) {
        
        if (currentHistoryModel) {
            
            
            isLiveVideo = NO;
            if (playState == videoPlayStatePlaying) {
                [CylanJFGSDK playVideoByTime:currentHistoryModel.startTimestamp cid:self.cid];
               // [CylanJFGSDK switchLiveVideo:NO beigenTime:currentHistoryModel.startTimestamp];
                [self voiceAndMicBtnNomalState];
                [self fullVoiceAndMicBtnDisableState];

            }else{
                [self playHistoryVideoForZeroWithTimestamp:currentHistoryModel.startTimestamp];
            }
            
            
        }else{
            isLiveVideo = YES;
            [self startLiveVideo];
        }
        
        
    }
    
}

#pragma mark- 状态设置
-(void)isFristIntoView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:fristSafeKey]) {
        //第一次进入页面
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristSafeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showVideoPlayBar];
        
        if (self.isShow) {
            [self showSafeTip];
        }else{
            safeTipTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
                
                if (self.isShow && isDidAppear) {
                    [self showSafeTip];
                    [timer invalidate];
                }
                
            } repeats:YES];
        }
        
        
    }
}


//下方三个按钮设置默认状态
-(void)voiceAndMicBtnNomalState
{
    if (self.microphoneBtn.selected) {
        
        [self.voiceButton setImage:[UIImage imageNamed:@"camera_ico_voice"] forState:UIControlStateSelected];
        [self.voiceButton setImage:[UIImage imageNamed:@"btn_closevoice"] forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"camera_ico_voicedisabled"] forState:UIControlStateDisabled];
        
    }
    self.voiceButton.selected = NO;
    self.microphoneBtn.selected = NO;
    self.voiceButton.enabled = YES;
    self.microphoneBtn.enabled = YES;
    self.snapBtn.enabled = YES;
    isTalkBack = NO;
    isAudio = NO;
    
    if (isLiveVideo) {
        [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
        [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
    }else{
        self.microphoneBtn.enabled = NO;
        [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
        [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
    }
    
   
}



//下方三个按钮设置不可点击状态
-(void)voiceAndMicBtnDisableState
{
    isTalkBack = NO;
    isAudio = NO;
    [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
    [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
    
//    if (self.voiceButton.selected) {
//        [self.voiceButton setImage:[UIImage imageNamed:@"camera_btn_closevoicedisabled"] forState:UIControlStateDisabled];
//    }else{
//        [self.voiceButton setImage:[UIImage imageNamed:@"camera_ico_voicedisabled"] forState:UIControlStateDisabled];
//    }
    
   
    [self.microphoneBtn setImage:[UIImage imageNamed:@"camera_ico_ talkDisabled"] forState:UIControlStateDisabled];
    [self.snapBtn setImage:[UIImage imageNamed:@"camera_icon_takepicdisabled"] forState:UIControlStateDisabled];
    self.voiceButton.enabled = NO;
    self.microphoneBtn.enabled = NO;
    self.snapBtn.enabled = NO;
}

-(void)fullVoiceAndMicBtnDisableState
{
    self.fullMicBtn.enabled = NO;
    self.fullSnapBtn.enabled = NO;
    self.fullVoideBtn.enabled = NO;
}

-(void)fullVideoAndMicBtnNomal
{
    self.fullVoideBtn.selected = NO;
    self.fullMicBtn.selected = NO;
    self.fullVoideBtn.enabled = YES;
    self.fullMicBtn.enabled = YES;
    self.fullSnapBtn.enabled = YES;
    self.fullPlayBtn.enabled = YES;
    
    if (!isLiveVideo) {
        self.fullMicBtn.enabled = NO;
    }
}

#pragma mark- 全屏 小屏切换
//全屏
-(void)fullScreen
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    //[self.videoPlayBgScrollerView setZoomScale:1];
    
   // [self remoteViewSizeFit];
    windowMode = videoPlayModeFullScreen;
    
    
    [self hideVideoPlayBar];
    
    self.fullScreenTopControlBar.left = 0;
    self.fullScreenTopControlBar.top = 0;
    self.fullScreenBottomControlBar.left = 0;
    self.fullScreenBottomControlBar.top = self.view.width-50;
    
    //安全防护按钮移动位置
    if (self.safeguardBtn_full.superview == nil) {
        
        //被分享设备不显示安全防护按钮
        if (!isShared) {
            [self.fullScreenBottomControlBar addSubview:self.safeguardBtn_full];
        }

    }
    self.safeguardBtn_full.isFace = self.safeguardBtn.isFace;

    //历史视频滚动条
    if (isShared == NO ) {
        
        if (self.historyView.dataArray.count) {
            [self.historyView removeFromSuperview];
            self.historyView.frame = CGRectMake(90, 0, [UIScreen mainScreen].bounds.size.height-90-90, 55);
            [self.fullScreenBottomControlBar addSubview:self.historyView];
            self.historyView.viewType = ViewTypeFullMode;
            [self.historyView reloadData];
            if (self.historyView.dataArray != 0) {
                self.historyView.alpha = 1;
                self.historyView.hidden = NO;
            }else{
                self.historyView.hidden = YES;
            }
        }else{
            self.historyView.hidden = YES;
        }
        
    }
    
    
    
    //历史视频底部Bar分割线
    if (![self.fullScreenBottomControlBar viewWithTag:1234]) {
        UIView *leftLine = [[UIView alloc]initWithFrame:CGRectMake(90, 0, 2, 50)];
        leftLine.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1];
        leftLine.tag = 1234;
        [self.fullScreenBottomControlBar addSubview:leftLine];
    }
    
    if (![self.fullScreenBottomControlBar viewWithTag:1239]) {
        UIView *rightLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 50)];
        rightLine.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1];
        rightLine.right = [UIScreen mainScreen].bounds.size.height-90;
        rightLine.tag = 1239;
        [self.fullScreenBottomControlBar addSubview:rightLine];
    }
    
    
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    
    //添加黑色背景
    [keyWindows addSubview:self.fullShadeView];
    [self.videoPlayTipLabel removeFromSuperview];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    
        [self.videoBgView removeFromSuperview];
        
        [keyWindows addSubview:self.videoBgView];
       
        self.videoBgView.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        self.videoBgView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        self.videoPlayBgScrollerView.frame = self.videoBgView.bounds;
//        self.videoPlayBgScrollerView.maximumZoomScale = maxZoomScale;
//        self.videoPlayBgScrollerView.minimumZoomScale = 1.0;
        [JFGSDK appendStringToLogFile:@"fullScreen remoteViewSizeFit"];
        [self remoteViewSizeFit];
        self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
        
        self.rateLabel.top = 60;
        self.rateLabel.right = self.videoBgView.height-10;
        
    } completion:^(BOOL finished) {
        
    
        self.videoPlayTipLabel.x = kheight*0.5;
        self.videoPlayTipLabel.bottom = self.fullScreenBottomControlBar.top-10;
        [self.videoBgView addSubview:self.videoPlayTipLabel];
        [self.videoBgView addSubview:self.fullScreenTopControlBar];
        [self.videoBgView addSubview:self.fullScreenBottomControlBar];
        [self.fullShadeView removeFromSuperview];
        
        self.loadingBgView.frame = self.videoBgView.bounds;
        self.loadingImageView1.x = self.loadingBgView.x;
        self.loadingImageView1.y = self.loadingBgView.y;
        
//        self.videoPlayBgScrollerView.maximumZoomScale = maxZoomScale;
//        self.videoPlayBgScrollerView.minimumZoomScale = 1.0;
        
    }];
    
    UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
        PanoramicIosView *panView = (PanoramicIosView *)remoteView;
        NSLog(@"PanoramicIosViewsize:%@",NSStringFromCGRect(panView.frame));
        [panView detectOrientationChange];
    }
    
    if (isLiveVideo) {
        self.fullPlayBtn.enabled = NO;
    }else{
        self.fullPlayBtn.enabled = YES;
    }
    //NSLog(@"videoViewFrame:%@",NSStringFromCGRect(self.videoBgView.frame));
    //NSLog(@"remoteFrame:%@",NSStringFromCGRect(remoteView.frame));
    //[self remoteViewSizeFit];
    //三秒后自动隐藏工具栏
    [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
}





//退出全屏
-(void)exitFullScreen
{
    //[self.videoPlayBgScrollerView setZoomScale:1];
    //[self remoteViewSizeFit];
    windowMode = videoPlayModeSmallWindow;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFullVideoPlayBar) object:nil];
    [self.fullScreenTopControlBar removeFromSuperview];
    [self.fullScreenBottomControlBar removeFromSuperview];
    self.safeguardBtn.isFace = self.safeguardBtn_full.isFace;
    
    if (isShared == NO) {
        
        [self.historyView removeFromSuperview];
        self.historyView.frame = CGRectMake(0, self.view.height*0.45, self.view.bounds.size.width, 55);
        self.historyView.viewType = ViewTypeSmallMode;
        [self.historyView reloadData];
        if (self.videoBottomBar.hidden) {
            self.historyView.hidden = YES;
        }else{
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
        }
        [self.view addSubview:self.historyView];
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        [self.videoBgView removeFromSuperview];
        self.loadingBgView.layer.transform = CATransform3DIdentity;
        [self.view addSubview:self.videoBgView];
        
        self.videoBgView.transform = CGAffineTransformIdentity;
        self.videoBgView.frame = CGRectMake(0, 0, self.view.width, self.view.height*0.45);
        self.videoPlayBgScrollerView.frame = self.videoBgView.bounds;
//        self.videoPlayBgScrollerView.maximumZoomScale = maxZoomScale;
//        self.videoPlayBgScrollerView.minimumZoomScale = 1.0;
         [JFGSDK appendStringToLogFile:@"exitFullScreen remoteViewSizeFit"];
        [self remoteViewSizeFit];
        self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
        
        self.loadingBgView.width = self.videoBgView.width;
        self.loadingBgView.height = self.videoBgView.height;
        self.loadingBgView.center = CGPointMake(self.videoBgView.width*0.5, self.videoBgView.height*0.5);
        self.loadingImageView1.x = self.loadingBgView.x;
        self.loadingImageView1.y = self.loadingBgView.y;
        self.videoBgView.left = 0;
        self.videoBgView.top = 0;
        
        self.rateLabel.right = self.videoBgView.width-10;
        self.rateLabel.top = 10;
        
    } completion:^(BOOL finished) {
        
        [self.videoPlayTipLabel removeFromSuperview];
        self.videoPlayTipLabel.x = self.view.width*0.5;
        self.videoPlayTipLabel.bottom = self.videoBgView.height-8;
        [self.videoBgView addSubview:self.videoPlayTipLabel];
        
    }];
    
    UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
        PanoramicIosView *panView = (PanoramicIosView *)remoteView;
        [panView detectOrientationChange];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark- 特殊状态视图显示隐藏
-(void)showVideoPlayBar
{
    if (self.devModel.safeIdle) {
        return;
    }
    
    UIView *bgView = [self.videoBgView viewWithTag:123451];
    //如果显示了视频连接错误界面，不显示播放按钮
    if (bgView) {
        return;
    }
    
    if (isLiveVideo) {
        self.playButton.hidden = YES;
    }else{
        self.playButton.hidden = NO;
    }
    
    
    self.videoBottomBar.hidden = NO;
    
    if (isShared == NO) {
        if (self.historyView.dataArray.count > 0) {
            self.historyView.hidden = NO;
        }
    }
    
    if (self.videoBottomBar.superview == nil) {
        [self.videoBgView addSubview:self.videoBottomBar];
        [self.videoBgView addSubview:self.playButton];
    }
    [self.videoBgView bringSubviewToFront:self.videoBottomBar];
    [self.videoBgView bringSubviewToFront:self.playButton];
    [self.videoBgView bringSubviewToFront:self.videoPlayTipLabel];
    [UIView animateWithDuration:0.5 animations:^{
        
        if (playState == videoPlayStatePlaying) {
            self.playButton.alpha = 1;
           
            self.videoBottomBar.alpha = 1;
            self.videoBottomBar.bottom = self.videoBgView.bottom;
            
            if (isShared == NO) {
                self.historyView.alpha = 1;
            }
            
        }else{
            self.playButton.alpha = 1;
            self.videoBottomBar.alpha = 1;
            self.videoBottomBar.bottom = self.videoBgView.bottom;
        }
    }];
}


-(void)hideVideoPlayBar
{

    [UIView animateWithDuration:0.5 animations:^{
        
        self.playButton.alpha = 0;
        self.videoBottomBar.alpha = 0;
        self.videoBottomBar.top = self.videoBgView.height+10;
        if (windowMode == videoPlayModeSmallWindow) {
            
            if (isShared == NO) {
                self.historyView.alpha = 0;
            }
            
        }
        
        
    } completion:^(BOOL finished) {
        
        self.playButton.hidden = YES;
        self.videoBottomBar.hidden = YES;
        if (windowMode == videoPlayModeSmallWindow) {
            if (isShared == NO) {
                self.historyView.hidden = YES;
            }
        }
        
        
    }];
    if (windowMode == videoPlayModeFullScreen){
        if (isShared == NO) {
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
        }
    }
    
   
}

-(void)showFullVideoPlayBar
{
    [self.videoBgView bringSubviewToFront:self.videoPlayTipLabel];
    [self.videoBgView bringSubviewToFront:self.fullScreenTopControlBar];
    [self.videoBgView bringSubviewToFront:self.fullScreenBottomControlBar];
    if (self.historyView.dataArray) {
        self.historyView.hidden = NO;
    }else{
        self.historyView.hidden = YES;
    }
    
    if (isLiveVideo) {
        self.fullPlayBtn.enabled = NO;
    }else{
        self.fullPlayBtn.enabled = YES;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.videoPlayTipLabel.bottom = Kwidth-self.fullScreenBottomControlBar.height-10;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
       
        
        self.fullScreenTopControlBar.top = 0;
        self.fullScreenBottomControlBar.top = [UIScreen mainScreen].bounds.size.width-self.fullScreenBottomControlBar.height;
        self.rateLabel.top = 60;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideFullVideoPlayBar
{
    [UIView animateWithDuration:0.7 animations:^{
        self.videoPlayTipLabel.bottom = Kwidth - 10;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.fullScreenTopControlBar.top = -self.fullScreenTopControlBar.height;
        self.fullScreenBottomControlBar.top = [UIScreen mainScreen].bounds.size.width;
        self.rateLabel.top = 10;
        
    } completion:^(BOOL finished) {
        
    }];
}

//显示待机视图
-(void)showIdleView
{
    if (self.idleModeBgView.superview == nil || self.idleModeBgView.hidden == YES ) {
        [self.videoBgView addSubview:self.idleModeBgView];
        self.idleModeBgView.hidden = NO;
        self.videoBgView.backgroundColor = [UIColor colorWithHexString:@"#31506f"];
        [self idleModelSubView];
        [self hideVideoPlayBar];
        [self hideDisconnectNetView];
        [self stopLoadingAnimation];
        [self.videoPlayTipLabel removeFromSuperview];
        if (isShared == NO) {
            self.historyView.hidden = YES;
        }
    }
   
}

-(void)hideIdleView
{
    if (self.idleModeBgView || !self.idleModeBgView.hidden) {
        [self.idleModeBgView removeFromSuperview];
        self.idleModeBgView.hidden = YES;
    }
}

-(void)showDisconnectViewWithText:(NSString *)text
{
    if (windowMode == videoPlayModeFullScreen) {
        [self exitFullScreen];
    }
    [self stopLoadingAnimation];
    [self hideVideoPlayBar];
    UIView *bgView = [self.videoBgView viewWithTag:123451];
    if (bgView) {
        UILabel *textLab = [bgView viewWithTag:20005];
        if (textLab) {
            
            textLab.text = text;
            
        }
        return;
    }
    
    self.videoPlayBgScrollerView.hidden = YES;
    
    bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.videoBgView.width, 170*0.5+30)];
    bgView.center = CGPointMake(self.videoBgView.width*0.5, self.videoBgView.height*0.5);
    bgView.tag = 123451;
    self.videoBgView.backgroundColor = [UIColor blackColor];
    [self.videoBgView addSubview:bgView];
    
    UIButton *iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    iconBtn.frame = CGRectMake(bgView.width*0.5-25, 0, 50, 50);
    [iconBtn setImage:[UIImage imageNamed:@"camera_icon_no-network"] forState:UIControlStateNormal];
    [iconBtn addTarget:self action:@selector(disconnectNetAction) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:iconBtn];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, iconBtn.bottom+15, bgView.width, 35)];
    label.tag = 20005;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor  = [UIColor colorWithHexString:@"#dddddd"];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:label];
    
    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    helpBtn.frame = CGRectMake(0, label.bottom+5, 80, 15);
    helpBtn.x = bgView.width*0.5;
    [helpBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SEE_HELP"] forState:UIControlStateNormal];
    [helpBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(helpAction) forControlEvents:UIControlEventTouchUpInside];
    helpBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:helpBtn];
    
    [self.snapeImageView removeFromSuperview];
}

-(void)helpAction
{
    JFGHelpViewController *helpController = [JFGHelpViewController new];
    [self.navigationController pushViewController:helpController animated:YES];
}

-(void)hideDisconnectNetView
{
    UIView *bgView = [self.videoBgView viewWithTag:123451];
    if (bgView) {
        [bgView removeFromSuperview];
    }
}

#pragma mark- getter，视图创建
-(UIView *)videoBgView
{
    if (!_videoBgView) {
        
        CGFloat height = 0;
        NSInteger pid = [self.devModel.pid integerValue];
        
        if (pid == 5 || pid == 7 || pid == 13 || pid == 4 || pid == 16 || pid == 17 || pid == 1071 ) {
            height = self.view.height*0.45;
        }else{
            height = self.view.width;
        }

        
        _videoBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, height)];
        _videoBgView.backgroundColor = [UIColor blackColor];
        _videoBgView.clipsToBounds = YES;
        _videoBgView.userInteractionEnabled = YES;
       
    }
    return _videoBgView;
}


-(UIScrollView *)videoPlayBgScrollerView
{
    if (!_videoPlayBgScrollerView) {
        _videoPlayBgScrollerView = [[UIScrollView alloc]initWithFrame:self.videoBgView.bounds];
        _videoPlayBgScrollerView.showsHorizontalScrollIndicator = YES;
        _videoPlayBgScrollerView.showsVerticalScrollIndicator = YES;
        _videoPlayBgScrollerView.bounces = NO;
        _videoPlayBgScrollerView.delegate = self;
        _videoPlayBgScrollerView.scrollEnabled = YES;
        _videoPlayBgScrollerView.directionalLockEnabled = YES;
        _videoPlayBgScrollerView.bouncesZoom = NO;
        //_videoPlayBgScrollerView.minimumZoomScale = 1.0;
        //_videoPlayBgScrollerView.maximumZoomScale = maxZoomScale;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoViewTap)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        videoTapGesture = tap;
        [_videoPlayBgScrollerView addGestureRecognizer:tap];
    }
    return _videoPlayBgScrollerView;
}


//待机界面背景视图视图
-(UIView *)idleModeBgView
{
    if (!_idleModeBgView) {
        _idleModeBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
        _idleModeBgView.y = self.videoBgView.height*0.5;
        _idleModeBgView.hidden = YES;
        _idleModeBgView.backgroundColor = [UIColor clearColor];
    }
    return _idleModeBgView;
}

-(void)idleModelSubView
{
    UIImageView *idleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    idleImageView.center = CGPointMake(self.idleModeBgView.width*0.5, 20);
    idleImageView.image = [UIImage imageNamed:@"camera_icon_standby"];
    [self.idleModeBgView addSubview:idleImageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.idleModeBgView.width*0.5-320*0.5, idleImageView.bottom+17, 320, 35*0.5)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Standby"];
    label.textAlignment = NSTextAlignmentCenter;
    [self.idleModeBgView addSubview:label];
    
    
    //被分享设备不显示前往设置按钮
    if (!isShared) {
        UIButton *gotoSet = [UIButton buttonWithType:UIButtonTypeCustom];
        gotoSet.frame = CGRectMake(self.idleModeBgView.width*0.5-152*0.5, label.bottom, 152, 30);
        [gotoSet setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Standby_OffTips"] forState:UIControlStateNormal];
        [gotoSet setTitleColor:[UIColor colorWithHexString:@"#36bdff"] forState:UIControlStateNormal];
        gotoSet.titleLabel.font = [UIFont systemFontOfSize:13];
        gotoSet.titleLabel.textAlignment = NSTextAlignmentCenter;
        [gotoSet addTarget:self action:@selector(gotoIdleSetting) forControlEvents:UIControlEventTouchUpInside];
        [self.idleModeBgView addSubview:gotoSet];
    }
    [self.videoPlayBgScrollerView removeFromSuperview];
}





-(SafaButton *)safeguardBtn
{
    if (!_safeguardBtn) {
        _safeguardBtn = [SafaButton buttonWithType:UIButtonTypeCustom];
        _safeguardBtn.frame = CGRectMake(15, 0, 75, 24);
        _safeguardBtn.bottom = self.videoBottomBar.height-10;
        _safeguardBtn.adjustsImageWhenHighlighted = NO;
        [_safeguardBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SECURE"] forState:UIControlStateNormal];
        [_safeguardBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        _safeguardBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_safeguardBtn addTarget:self action:@selector(safeguarAction:) forControlEvents:UIControlEventTouchUpInside];
        if (isShared) {
            _safeguardBtn.bounds = CGRectMake(0, 0, 0, 0);
        }
        _safeguardBtn.clipsToBounds = YES;
    }
    return _safeguardBtn;
}

-(SafaButton *)safeguardBtn_full
{
    if (!_safeguardBtn_full) {
        _safeguardBtn_full = [SafaButton buttonWithType:UIButtonTypeCustom];
        _safeguardBtn_full.frame = CGRectMake(0, 13, 75, 24);
        _safeguardBtn_full.right = [UIScreen mainScreen].bounds.size.height-5;
        _safeguardBtn_full.adjustsImageWhenHighlighted = NO;
        [_safeguardBtn_full setTitle:[JfgLanguage getLanTextStrByKey:@"SECURE"] forState:UIControlStateNormal];
        [_safeguardBtn_full setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        _safeguardBtn_full.isFace = self.safeguardBtn.isFace;
        _safeguardBtn_full.titleLabel.font = [UIFont systemFontOfSize:12];
        [_safeguardBtn_full addTarget:self action:@selector(safeguarAction:) forControlEvents:UIControlEventTouchUpInside];
        _safeguardBtn_full.clipsToBounds = YES;
        if (isShared) {
            _safeguardBtn_full.bounds = CGRectMake(0, 0, 0, 0);
        }
    }
    return _safeguardBtn_full;
}

-(UILabel *)videoPlayTipLabel
{
    if (!_videoPlayTipLabel) {
        _videoPlayTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 24)];
        _videoPlayTipLabel.x = self.view.width*0.5;
        _videoPlayTipLabel.bottom = self.videoBottomBar.height-8;
        _videoPlayTipLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _videoPlayTipLabel.textColor = [UIColor whiteColor];
        _videoPlayTipLabel.font = [UIFont systemFontOfSize:12];
        _videoPlayTipLabel.textAlignment = NSTextAlignmentCenter;
        _videoPlayTipLabel.text = [NSString stringWithFormat:@"%@|5/16 12:30",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_VideoLive"]];
        _videoPlayTipLabel.userInteractionEnabled = YES;
        [_videoPlayTipLabel setCornerRadius:3];
        
        if (isShared == YES) {
            _videoPlayTipLabel.bounds = CGRectMake(0, 0, 0, 0);
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(historyVideoSelectAction)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_videoPlayTipLabel addGestureRecognizer:tap];
        
    }
    return _videoPlayTipLabel;
}

-(UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenBtn.frame = CGRectMake(0, 0, 24, 24);
        _fullScreenBtn.right = self.view.width-15;
        _fullScreenBtn.bottom = self.videoBottomBar.height-7;
        [_fullScreenBtn setImage:[UIImage imageNamed:@"camera_icon_zoom"] forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

-(UIImageView *)videoBottomBar
{
    if (!_videoBottomBar) {
        _videoBottomBar = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.videoBgView.height-40, self.videoBgView.width, 40)];
        _videoBottomBar.top = self.videoBgView.height+10;
        _videoBottomBar.alpha = 0;
        _videoBottomBar.hidden = YES;
        _videoBottomBar.userInteractionEnabled = YES;
        _videoBottomBar.image = [UIImage imageNamed:@"camera_sahdow2"];
        
        if (!isShared) {
            [_videoBottomBar addSubview:self.safeguardBtn];
        }

        //[_videoBottomBar addSubview:self.videoPlayTipLabel];
        [_videoBottomBar addSubview:self.fullScreenBtn];
    }
    return _videoBottomBar;
}


-(UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(0, 0, 50, 50);
        _playButton.x = self.videoBgView.width*0.5;
        _playButton.top = self.view.height*0.16;
        [_playButton setImage:[UIImage imageNamed:@"camera_btn_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"camera_btn_pause"] forState:UIControlStateSelected];
        _playButton.selected = YES;
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.hidden = YES;
        _playButton.alpha = 0;
    }
    return _playButton;
}

-(UILabel *)rateLabel
{
    if (!_rateLabel) {
        _rateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 50, 22)];
        _rateLabel.right = self.videoBgView.width-10;
        _rateLabel.alpha = 0;
        _rateLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_rateLabel setCornerRadius:3];
        _rateLabel.textAlignment = NSTextAlignmentCenter;
        _rateLabel.font = [UIFont systemFontOfSize:12];
        _rateLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _rateLabel.text = @"0k/s";
    }
    return _rateLabel;
}


-(UIImageView *)snapeImageView
{
    if (!_snapeImageView) {
        _snapeImageView = [[VideoSnapImageView alloc]initWithFrame:self.videoBgView.bounds];
        _snapeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _snapeImageView.userInteractionEnabled = YES;
        _snapeImageView.backgroundColor = [UIColor blackColor];
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",snapShotKey,self.cid]];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            _snapeImageView.image = image;
        }else{
            _snapeImageView.image = [UIImage imageNamed:@"camera_bg"];
        }
    }
    return _snapeImageView;
}

-(UIImageView *)loadingImageView1
{
    if (!_loadingImageView1) {
        _loadingImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.playButton.width, self.playButton.height)];
        _loadingImageView1.x = self.loadingBgView.width*0.5;
        _loadingImageView1.y = self.loadingBgView.height*0.5;
        _loadingImageView1.image = [UIImage imageNamed:@"camera_loading"];
        _loadingImageView1.userInteractionEnabled = YES;
    }
    return _loadingImageView1;
}

-(UIView *)loadingBgView
{
    if (!_loadingBgView) {
        _loadingBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.videoBgView.width, self.videoBgView.height)];
        _loadingBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    return _loadingBgView;
}

-(void)startLodingAnimation
{
    if (isLoading) {
        return;
    }
    [self hideDisconnectNetView];
    if (self.loadingBgView.superview == nil) {
        [self.videoBgView addSubview:self.loadingBgView];
        [self.loadingBgView addSubview:self.loadingImageView1];
    }
    isLoading = YES;
    //加载控件与播放按钮控件同一位置，避免遮挡
    self.playButton.hidden = YES;
    self.loadingBgView.hidden = NO;
    [self.videoBgView bringSubviewToFront:self.loadingBgView];
    
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
    [self.loadingImageView1.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
}

-(void)stopLoadingAnimation
{
    isLoading = NO;
    if (self.loadingBgView.hidden) {
        return;
    }
    self.loadingBgView.hidden = YES;
    [self.loadingImageView1.layer pop_removeAnimationForKey:@"rotation"];
}

- (DownloadUtils *)downLoadUtils
{
    if (_downLoadUtils == nil)
    {
        _downLoadUtils = [[DownloadUtils alloc] init];
    }
    
    return _downLoadUtils;
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
        if (![CommonMethod isPanoCameraWithType:[self.devModel.pid intValue]])
        {
            [JFGSDK checkDevVersionWithCid:self.cid pid:[self.devModel.pid intValue] version:ask.ver];
        }
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
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"isInCurrentVC [%d]", isDidAppear]];
    if (isInCurrentView)
    {
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Device_UpgradeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
            upgradeDevice.cid = self.cid;
            upgradeDevice.pType = (productType)[self.devModel.pid intValue];
            [self.navigationController pushViewController:upgradeDevice animated:YES];
        }];
    }
}



#pragma mark- 底部三个按钮

-(void)layoutBottomBtn
{
    self.voiceButton.top = self.videoBgView.bottom+110;
    self.microphoneBtn.top = self.videoBgView.bottom+110-5;
    self.snapBtn.top = self.videoBgView.bottom+110;
}

-(UIButton *)voiceButton
{
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.frame = CGRectMake(96*0.5, self.videoBgView.bottom+110, 50, 50);
        [_voiceButton setImage:[UIImage imageNamed:@"camera_ico_voice"] forState:UIControlStateSelected];
        [_voiceButton setImage:[UIImage imageNamed:@"btn_closevoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"camera_ico_voicedisabled"] forState:UIControlStateDisabled];
        _voiceButton.adjustsImageWhenDisabled = YES;
        [_voiceButton addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

-(UIButton *)microphoneBtn
{
    if (!_microphoneBtn) {
        
        _microphoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _microphoneBtn.frame = CGRectMake(96*0.5, self.videoBgView.bottom+110-5, 60, 60);
        _microphoneBtn.x = self.view.width*0.5;
        [_microphoneBtn setImage:[UIImage imageNamed:@"camera_ico_ talk"] forState:UIControlStateNormal];
        [_microphoneBtn setImage:[UIImage imageNamed:@"camera_ico_ talkbule"] forState:UIControlStateSelected];
        [_microphoneBtn addTarget:self action:@selector(microphoneAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _microphoneBtn;
}

-(UIButton *)snapBtn
{
    if (!_snapBtn) {
        _snapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _snapBtn.frame = CGRectMake(96*0.5, self.videoBgView.bottom+110, 50, 50);
        _snapBtn.right = self.view.width-96*0.5;
        [_snapBtn setImage:[UIImage imageNamed:@"camera_icon_takepic"] forState:UIControlStateNormal];
        [_snapBtn setImage:[UIImage imageNamed:@"camera_icon_takepicdisabled"] forState:UIControlStateDisabled];
        [_snapBtn addTarget:self action:@selector(snap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _snapBtn;
}


-(UIView *)snapAnimationView
{
    if (!_snapAnimationView) {
        _snapAnimationView = [[UIView alloc]initWithFrame:self.videoBgView.bounds];
        _snapAnimationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _snapAnimationView.alpha = 1;
    }
    return _snapAnimationView;
}

//截屏动画
-(void)snapAnimation
{
    if (windowMode == videoPlayModeFullScreen) {
        
        UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
        self.snapAnimationView.frame = keyWindows.bounds;
        [keyWindows addSubview:self.snapAnimationView];
    }else{
        
        self.snapAnimationView.frame = self.videoBgView.bounds;
        [self.videoBgView addSubview:self.snapAnimationView];
    }
    
    self.snapAnimationView.alpha = 1;
    self.snapAnimationView.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.snapAnimationView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.snapAnimationView removeFromSuperview];
    }];
}

-(UIView *)fullScreenTopControlBar
{
    if (!_fullScreenTopControlBar) {
        _fullScreenTopControlBar = [self fullBar];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(10, 5, 40, 40);
        [backBtn setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(exitFullScreen) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenTopControlBar addSubview:backBtn];
        
        UILabel *titleLalbe = [[UILabel alloc]initWithFrame:CGRectMake(backBtn.right, 15, 150, 20)];
        NSString *tit;
        if ([self.devModel.alias isEqualToString:@""]) {
            tit = self.cid;
        }else{
            tit = self.devModel.alias;
        }
        
        titleLalbe.text = [NSString stringWithFormat:@"%@",tit];
        titleLalbe.font = [UIFont systemFontOfSize:16];
        titleLalbe.textColor = [UIColor whiteColor];
        titleLalbe.textAlignment = NSTextAlignmentLeft;
        [_fullScreenTopControlBar addSubview:titleLalbe];
        
        self.fullSnapBtn.right = _fullScreenTopControlBar.width-20;
        self.fullMicBtn.right = self.fullSnapBtn.left-15;
        self.fullVoideBtn.right = self.fullMicBtn.left-15;
        
        [_fullScreenTopControlBar addSubview:self.fullMicBtn];
        [_fullScreenTopControlBar addSubview:self.fullVoideBtn];
        [_fullScreenTopControlBar addSubview:self.fullSnapBtn];
        
    }
    return _fullScreenTopControlBar;
}

-(UIButton *)fullSnapBtn
{
    if (!_fullSnapBtn) {
        _fullSnapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullSnapBtn.frame = CGRectMake(0, 0, 50, 50);
        [_fullSnapBtn setImage:[UIImage imageNamed:@"full-screen_icon_takepic"] forState:UIControlStateNormal];
        [_fullSnapBtn addTarget:self action:@selector(snap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullSnapBtn;
}

-(UIButton *)fullMicBtn
{
    if (!_fullMicBtn) {
        _fullMicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullMicBtn.frame = CGRectMake(0, 0, 50, 50);
        [_fullMicBtn setImage:[UIImage imageNamed:@"full-screen_ico_-talk"] forState:UIControlStateSelected];
         [_fullMicBtn setImage:[UIImage imageNamed:@"full-screen_icon_closetalk"] forState:UIControlStateNormal];
        //full-screen_icon_closetalk
//        [_microphoneBtn setImage:[UIImage imageNamed:@"camera_ico_ talk"] forState:UIControlStateNormal];
//        [_microphoneBtn setImage:[UIImage imageNamed:@"camera_ico_ talkbule"] forState:UIControlStateSelected];
        [_fullMicBtn addTarget:self action:@selector(microphoneAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullMicBtn;
}

-(UIButton *)fullVoideBtn
{
    if (!_fullVoideBtn) {
        _fullVoideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullVoideBtn.frame = CGRectMake(0, 0, 50, 50);
        [_fullVoideBtn addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
        [_fullVoideBtn setImage:[UIImage imageNamed:@"full-screen_ico_voice"] forState:UIControlStateSelected];
        [_fullVoideBtn setImage:[UIImage imageNamed:@"full-screen_ico_closevoice"] forState:UIControlStateNormal];
    }
    return _fullVoideBtn;
}

-(UIView *)fullScreenBottomControlBar
{
    if (!_fullScreenBottomControlBar) {
        _fullScreenBottomControlBar = [self fullBar];
        _fullScreenBottomControlBar.height = 50;
        [_fullScreenBottomControlBar addSubview:self.fullPlayBtn];
    }
    return _fullScreenBottomControlBar;
}

-(UIView *)fullBar
{
    UIView *bar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 50)];
    bar.backgroundColor =[UIColor colorWithWhite:0 alpha:0.6];
    return bar;
}

-(UIView *)fullShadeView
{
    if (!_fullShadeView) {
        _fullShadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _fullShadeView.backgroundColor = [UIColor blackColor];
    }
    return _fullShadeView;
}


-(UIButton *)fullPlayBtn
{
    if (!_fullPlayBtn) {
        _fullPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullPlayBtn.frame = CGRectMake(20, 0, 50, 50);
        [_fullPlayBtn setImage:[UIImage imageNamed:@"full-screen_icon_pause"] forState:UIControlStateSelected];
        [_fullPlayBtn setImage:[UIImage imageNamed:@"full-screen_icon_play"] forState:UIControlStateNormal];
        [_fullPlayBtn addTarget:self action:@selector(fullPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        _fullPlayBtn.selected = YES;
        _fullPlayBtn.adjustsImageWhenDisabled = YES;
    }
    return _fullPlayBtn;
}

-(HorizontalHistoryRecordView *)historyView
{
    if (!_historyView) {
        _historyView = [[HorizontalHistoryRecordView alloc]initWithFrame:CGRectMake(0, self.videoBgView.height, self.view.bounds.size.width, 55) forCid:self.cid];
        _historyView.cid = self.cid;
        _historyView.hidden = YES;
        _historyView.delegate = self;
    }
    return _historyView;
}

-(UIImageView *)snapSmallWidows
{
    if (!_snapSmallWidows) {
        
        _snapSmallWidows = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 134*0.5, 45)];
        _snapSmallWidows.x = self.snapBtn.x;
        _snapSmallWidows.bottom = self.snapBtn.top;
        _snapSmallWidows.layer.cornerRadius = 8;
        _snapSmallWidows.layer.masksToBounds = YES;
        _snapSmallWidows.userInteractionEnabled = YES;
        _snapSmallWidows.layer.borderColor = [UIColor colorWithHexString:@"#36bdff"].CGColor;
        _snapSmallWidows.layer.borderWidth = 1;
        _snapSmallWidows.multipleTouchEnabled = YES;
        UITapGestureRecognizer *_tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigSnapView:)];
        _tap.numberOfTouchesRequired = 1;
        _tap.numberOfTapsRequired = 1;
        [_snapSmallWidows addGestureRecognizer:_tap];
        
    }
    return _snapSmallWidows;
}


-(void)showBigSnapView:(UITapGestureRecognizer *)tap
{
    UIImageView *tapView = (UIImageView *)tap.view;
    JFGBigImageView *bigimageView = [JFGBigImageView initWithImage:tapView.image];
    [bigimageView show];
}


#pragma mark 角度变化 回调
- (void)angleChanged:(int)angleType
{
    [self angleChangedAciton:angleType];
}

- (void)angleChangedWithNotification:(NSNotification *)notification
{
    int angleType = [notification.object intValue];
    [self angleChangedAciton:angleType];
}

- (void)angleChangedAciton:(int)angleType
{
    if ([CommonMethod isConnecttedDeviceWifiWithPid:[self.devModel.pid intValue]]) {
        
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"ap_angleChnaed:%d",angleType]];
        self.angleType = angleType;
        
    }else{
        
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"angleChnaed:%d",angleType]];
        DataPointSeg * seg = [[DataPointSeg alloc]init];
        NSError * error = nil;
        seg.msgId = dpMsgCamera_Angle;
        seg.value = [MPMessagePackWriter writeObject:[NSString stringWithFormat:@"%d",angleType] error:&error];
        NSArray * dps = @[seg];
        
        [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
            
            self.angleType = [[dic objectForKey:dpMsgCameraAngleKey] intValue];
            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
            
        } failed:^(RobotDataRequestErrorType error) {
            
        }];
    }
}
#pragma mark- 引导tip
//角度视图Tip
-(void)showAngleTip
{
    AngleView *vw = [[AngleView alloc]initWithFrame:CGRectMake(0, 0, self.videoBgView.width, self.videoBgView.height)];
    vw.tag = 13145202;
    [self.videoBgView addSubview:vw];
    
    [vw.cancelButton addTarget:self action:@selector(viewDidAppear:) forControlEvents:UIControlEventTouchUpInside];
    [vw.setAngleButton addTarget:self action:@selector(gotoSetAngle) forControlEvents:UIControlEventTouchUpInside];
}

-(void)gotoSetAngle
{
    SetAngleVC *angleVC = [[SetAngleVC alloc] init];
    angleVC.angleDelegate = self;
    angleVC.oldAngleType = self.angleType;
    [self.navigationController pushViewController:angleVC animated:YES];
}

//显示安全防护引导tip
-(void)showSafeTip
{
    if (isShared == NO && isDidAppear) {
        [self showTipWithFrame:CGRectMake(5, 64+self.videoBgView.height-40-35+4, 95, 35) triangleLeft:15 content:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_SetProtectionTips"]];
        showTip = YES;
    }
    
}

//显示切换直播引导
-(void)showTransionLiveVideoTip
{
    [self showTipWithFrame:CGRectMake(self.view.width-12-95, 64+self.view.height*0.45-24, 95, 35) triangleLeft:73 content:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_BackLiveTips"]];
    showTip = YES;
}

-(void)showTipWithFrame:(CGRect)frame triangleLeft:(CGFloat)left content:(NSString *)content
{
    FLTipsBaseView *tipBaseView = [FLTipsBaseView tipBaseView];
    
    UIView *tipBgView = [[UIView alloc]initWithFrame:frame];
    tipBgView.backgroundColor = [UIColor clearColor];
    
    [tipBaseView addTipView:tipBgView];
    
    UIImageView *tipbgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, tipBgView.width, 29)];
    tipbgImageView.image = [UIImage imageNamed:@"tip_bg2"];
    
    
    UIImageView *roleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(left, tipbgImageView.bottom, 12, 6)];
    roleImageView.transform = CGAffineTransformMakeRotation(180 * (M_PI / 180.0f));
    roleImageView.image = [UIImage imageNamed:@"tip_bg"];
    [tipBgView addSubview:roleImageView];
    
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tipbgImageView.width, tipbgImageView.height)];
    tipLabel.text = content;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont systemFontOfSize:13];
    [tipbgImageView addSubview:tipLabel];
    
    [tipBgView addSubview:tipbgImageView];
    
    [tipBaseView show];
}

-(void)showSnapSmallWidow:(UIImage *)image
{
    self.snapBtn.userInteractionEnabled = NO;
    self.snapSmallWidows.image = image;
    self.snapSmallWidows.alpha = 0;
    
    if (self.snapSmallWidows.superview == nil) {
        [self.view addSubview:self.snapSmallWidows];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.snapSmallWidows.alpha = 1;
    } completion:^(BOOL finished) {
        
        int64_t delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [UIView animateWithDuration:0.5 animations:^{
                self.snapSmallWidows.alpha = 0;
            } completion:^(BOOL finished) {
                [self.snapSmallWidows removeFromSuperview];
                self.snapSmallWidows = nil;
                self.snapBtn.userInteractionEnabled = YES;
            }];
            
        });
        
    }];
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
