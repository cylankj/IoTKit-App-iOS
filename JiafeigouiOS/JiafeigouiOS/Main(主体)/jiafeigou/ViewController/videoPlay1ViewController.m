//
//  videoPlay1ViewController.m
//  JiafeigouiOS
//
//  Created by yangli on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//  此类代码太乱，要修改

#import "videoPlay1ViewController.h"
#import "NetworkMonitor.h"
#import "UIView+FLExtensionForFrame.h"
#import <AVFoundation/AVFoundation.h>
#import "JfgUserDefaultKey.h"
#import "UIColor+FLExtension.h"
#import <JFGSDK/JFGSDK.h>
#import "SafaButton.h"
#import "SetAngleVC.h"
#import <POP.h>
#import "HorizontalHistoryRecordView.h"
#import "NewHistoryDateSelectedPicker.h"
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
#import "JfgMsgDefine.h"
#import "DevPropertyManager.h"
#import "CommentFrameButton.h"
#import "Masonry.h"
#import "jfgConfigManager.h"
#import "TelephonyManager.h"
#import "PropertyManager.h"
#import "JfgCacheManager.h"
#import <KVOController.h>

#define RPBtnTagBase 10024
#define ViewModeBtnTagBase 10124
#define fpingMacCount 3

typedef NS_ENUM(NSUInteger, VIEW_CONTROL_TAG)
{
    LABEL_TITLE_TAG = 10001,
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
NSString *const fristhistoryVideoKey =  @"fristhistoryVideoKey1";
NSString *const fristIntoAngleVideoViewKey = @"fristIntoAngleVideoViewKey_";
NSString *const fristShowWANNnetKey = @"fristShowWANNnetKey_";

@interface videoPlay1ViewController ()<NetworkMonitorDelegate,UIScrollViewDelegate,JFGSDKCallbackDelegate,HorizontalHistoryRecordViewDelegate,NewHistoryDateSelectedPickerDelegate,FullScreenHistoryDatePickerDelegate,UITextFieldDelegate,UIAlertViewDelegate, setAngleDelegate,TelephonyManagerDelegate>
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
    BOOL isStartRender;
    BOOL isAddVideoNotificaiton;
    
    
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
    BOOL isSupportSDCard;
    NSInteger sdCardErrorCode;
    CGFloat maxZoomScale;
    NSTimer *safeTipTimer;
    BOOL isLoading;
    BOOL isLowSpeed;
    int fpingcount;
    NSString *devMac;
    NSString *devIp;
    NSString *rpVersion;//支持速率调节设备版本号
    BOOL isCanShowHistoryView;
    AngleView *angleV;
    BOOL historyViewScrolling;//历史录像进度条正在拖动
    BOOL isEnterBackground;
    BOOL isGetSDCard;       // 是否 获取过 SDCard ？
    BOOL isShowAngle;
    
    SFDisplayMode defaultDispalyMode;
    BOOL isOpenShake;//是否开启摇一摇
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

//全屏摇一摇按钮
@property (nonatomic,strong)UIButton *shakeBtn;

//历史视频滚动条
@property (nonatomic,strong)HorizontalHistoryRecordView *historyView;

@property (nonatomic,strong)UIImageView *snapSmallWidows;

@property (nonatomic, strong) DownloadUtils *downLoadUtils;

@property (nonatomic, assign) int angleType;

@property (nonatomic, assign) BOOL isInCurrentVC; // 是否在 当前界面

@property (nonatomic,strong)NSLock *renderLock;

@property (nonatomic,strong)UIView *rpBgView;

@property (nonatomic,strong)UIView *viewModeBgView;

@property (nonatomic,strong)NSDateFormatter *dateFormatter;

@property (nonatomic,strong)UIButton *reqHistoryBtn;

@property (nonatomic,strong)UIView *handTipForHistory;

@property (nonatomic,strong)TelephonyManager *phonyManager;

@property (nonatomic,strong)UIButton *viewModeSwitchBtn;

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
    defaultDispalyMode = SFM_Normal;
    [self.view addSubview:self.videoBgView];
    [self.videoBgView addSubview:self.videoPlayBgScrollerView];
    [self.view addSubview:self.snapBtn];
    [self.view addSubview:self.microphoneBtn];
    [self.view addSubview:self.voiceButton];
    self.historyView.hidden = YES;
    self.historyView.alpha = 0;
    self.reqHistoryBtn.hidden = YES;
    self.reqHistoryBtn.alpha = 0;
    [self.view addSubview:self.historyView];
    [self.view addSubview:self.reqHistoryBtn];
    [self.phonyManager startMonitor];//监控来电
    [self voiceAndMicBtnDisableState];
    
    //低电量提醒
    [self battreyForPid:self.devModel.pid];
    
    //是否支持sd功能
    PropertyManager *propert =[[PropertyManager alloc]init];
    propert.propertyFilePath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"json"];
    isSupportSDCard = [propert showRowWithPid:[self.devModel.pid intValue] key:pSDCardKey];
    
    if (!isShared) {
        isShowAngle = [PropertyManager showPropertiesRowWithPid:[self.devModel.pid intValue] key:pAngleKey];
    }else{
        isShowAngle = [PropertyManager showSharePropertiesRowWithPid:[self.devModel.pid intValue] key:pAngleKey];
    }
    
    if (![PropertyManager showPropertiesRowWithPid:[self.devModel.pid intValue] key:pRemoteWatchKey] || isShared) {
        self.devModel.deepSleep = NO;
    }
    if(self.isShow) {
        [self startVideoActionPrepare];
    }
    
    if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360 || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeSinglefisheyeCamera) {
        
        SFCParamModel *paramModel =[CommonMethod panoramicViewParamModelForCid:self.devModel.uuid];
        if (!paramModel) {
            //单鱼眼设备，获取坐标值
            [self getResolving];
        }
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (safeTipTimer && [safeTipTimer isValid]) {
        [safeTipTimer invalidate];
    }
    [self getIsLive];
    [self getDeepSleep];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.isInCurrentVC = YES;
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"%@",[NSThread currentThread]]];
    [JFGSDK appendStringToLogFile:@"VideoPlayView viewDidAppear"];
    
    [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgCamera_Angle)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        
        self.angleType = [[dic objectForKey:dpMsgCameraAngleKey] intValue];
        
    } FailBlock:^(RobotDataRequestErrorType error) {
        
    }];
    
    [self jfgFpingRequest];
    [self addVideoNotification];
    if (self.isShow) {
        [self startVideoActionPrepare];
    }
    if (!isShared) {
        [self warnSensitivity];
    }
    if ([DevPropertyManager isSupportRPSwitchForPid:self.devModel.pid]) {
        [self rpDevDataReq];
    }
    
    [self historyViewState];
    [super viewDidAppear:animated];
}


-(void)motionEnded
{
    if (defaultDispalyMode == SFM_Normal && isOpenShake) {
        
        UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
            PanoramicIosViewRS * _remoteView = (PanoramicIosViewRS *)remoteView;
            [_remoteView enableAutoRotation:YES];
            [_remoteView phoneShook];
        }
        
    }
}

-(void)getDeepSleep
{
    if ([PropertyManager showPropertiesRowWithPid:[self.devModel.pid intValue] key:pRemoteWatchKey]) {
        [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@404] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
            
            for (NSArray *subArr in idDataList) {
                for (DataPointSeg *seg in subArr) {
                    
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if(seg.msgId == 404){
                        if ([obj isKindOfClass:[NSArray class]]) {
                            
                            /**
                             enbale bool 是否开启
                             beginTime int64 开始时间，单位秒
                             endTime int64 结束时间，单位秒
                             */
                            NSArray *sourceArr = obj;
                            if (sourceArr.count > 2) {
                                
                                BOOL isOpen = [sourceArr[0] boolValue];
                            
                                int64_t beginTime = [sourceArr[1] longLongValue];
                                int64_t endTime = [sourceArr[2] longLongValue];
                                
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                                [dateFormatter setDateFormat:@"HH"];
                                int currentHour = [[dateFormatter stringFromDate:[NSDate date]] intValue];
                                // 0  -- 24
                                // 22 -- 8
                                
                                int setBeginHour = (int)beginTime/60/60;
                                int setEndHour = (int)endTime/60/60;
                                
                                if (isOpen) {
                                    if (setBeginHour < setEndHour) {
                                        //没有跨天
                                        if (currentHour>=setBeginHour && currentHour <= setEndHour) {
                                            self.devModel.deepSleep = YES;
                                        }else{
                                            self.devModel.deepSleep = NO;
                                        }
                                        
                                        
                                    }else{
                                        //设置时间跨天了
                                        if (currentHour >= setBeginHour || currentHour <= setEndHour) {
                                            self.devModel.deepSleep = YES;
                                        }else{
                                            self.devModel.deepSleep = NO;
                                        }
                                        
                                    }
                                }else{
                                    
                                    self.devModel.deepSleep = NO;
                                    
                                }
                                
                                if (self.devModel.deepSleep) {
                                    
                                    if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                                        [self stopVideoPlay];
                                    }
                                    [self hiddenSmallWindowBottomBar];
                                    [self hideSmallWindowPlayBtn];
                                    [self showIdleViewForType:1];
                                    if (isShared == NO) {
                                        self.historyView.hidden = YES;
                                        self.reqHistoryBtn.enabled = NO;
                                    }
                                }else{
                                    [self hideIdleView];
                                    [self historyViewState];
                                }
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
    }
}

-(void)getResolving
{
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.devModel.uuid msgIds:@[@510] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                id obj = [MPMessagePackReader readData:seg.value error:nil];
                if ([obj isKindOfClass:[NSArray class]]) {
                    
                    NSArray *objArr = obj;
                    if (objArr.count>4) {
                        
                        SFCParamModel *paramModel = [[SFCParamModel alloc]init];
                        paramModel.x = [objArr[0] intValue];
                        paramModel.y = [objArr[1] intValue];
                        paramModel.r = [objArr[2] intValue];
                        paramModel.w = [objArr[3] intValue];
                        paramModel.h = [objArr[4] intValue];
                        paramModel.cid = self.devModel.uuid;
                        [JfgCacheManager cachesfcParamModel:paramModel];
                        
                        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"圆心位置：%@",obj]];
                        
                    }
                }
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}

-(void)fullHistoryViewState
{
    //支持sd卡，并且不是待机状态,不是被分享
    self.reqHistoryBtn.hidden = YES;
    if (isSupportSDCard && !self.devModel.safeIdle && !isShared && !self.devModel.deepSleep) {
        
        if (self.historyView.dataArray.count) {
            
            if ([self.fullScreenBottomControlBar viewWithTag:10006]) {
                UIView *v = [self.fullScreenBottomControlBar viewWithTag:10006];
                [v removeFromSuperview];
                v = nil;
            }
            self.historyView.hidden = NO;
            self.historyView.alpha = 1;
            if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
                self.historyView.hidden = YES;
            }
            
        }else{
            
            self.historyView.hidden = YES;
            self.historyView.alpha = 0;
            if (![self.fullScreenBottomControlBar viewWithTag:10006]) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(90, 0, 100, 50);
                btn.x = self.fullScreenBottomControlBar.width*0.5;
                [btn setTitle:[JfgLanguage getLanTextStrByKey:@"History_video"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithHexString:@"#cecece"] forState:UIControlStateDisabled];
                btn.titleLabel.font = [UIFont systemFontOfSize:15];
                btn.tag = 10006;
                [btn addTarget:self action:@selector(reqHistoryAction) forControlEvents:UIControlEventTouchUpInside];
                [self.fullScreenBottomControlBar addSubview:btn];
            }else{
                UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
                btn.enabled = YES;
                btn.hidden = NO;
            }
            
            BOOL isApModel = [CommonMethod isAPModelCurrentNetForCid:self.devModel.uuid pid:self.devModel.pid];
            if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline || self.historyView.isLoadingData || isApModel) {
                UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
                btn.enabled = NO;
            }
            
        }
        
    }else if (isSupportSDCard && self.devModel.safeIdle && !isShared){
        
        self.historyView.hidden = YES;
        if (self.historyView.dataArray.count) {
            if ([self.fullScreenBottomControlBar viewWithTag:10006]) {
                UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
                [btn removeFromSuperview];
                btn = nil;
            }
        }else{
            if ([self.fullScreenBottomControlBar viewWithTag:10006]) {
                UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
                btn.enabled = NO;
            }else{
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(90, 0, 100, 50);
                btn.x = self.fullScreenBottomControlBar.width*0.5;
                [btn setTitle:[JfgLanguage getLanTextStrByKey:@"History_video"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithHexString:@"#cecece"] forState:UIControlStateDisabled];
                btn.titleLabel.font = [UIFont systemFontOfSize:15];
                btn.tag = 10006;
                [btn addTarget:self action:@selector(reqHistoryAction) forControlEvents:UIControlEventTouchUpInside];
                btn.enabled = NO;
                [self.fullScreenBottomControlBar addSubview:btn];
            }
            
        }
        
    }else{
        
        if ([self.fullScreenBottomControlBar viewWithTag:10006]) {
            UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
            [btn removeFromSuperview];
            btn = nil;
        }
        self.historyView.hidden =  YES;
    }
    
    
}

-(void)historyViewState
{
    //支持sd卡，并且不是待机状态,不是被分享
    if (isSupportSDCard && !self.devModel.safeIdle && !isShared && !self.devModel.deepSleep) {
        
        if (self.historyView.dataArray.count) {
            
            self.reqHistoryBtn.hidden = YES;
            self.reqHistoryBtn.alpha = 0;
            self.historyView.hidden = NO;
            self.historyView.alpha = 1;
            if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
                self.historyView.hidden = YES;
            }
            
        }else{
            
            self.reqHistoryBtn.hidden = NO;
            self.reqHistoryBtn.alpha = 1;
            self.historyView.hidden = YES;
            self.historyView.alpha = 0;
            self.reqHistoryBtn.enabled = YES;
            
            BOOL isApModel = [CommonMethod isAPModelCurrentNetForCid:self.devModel.uuid pid:self.devModel.pid];
            if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline || self.historyView.isLoadingData || isApModel || self.devModel.netType == JFGNetTypeOffline) {
                self.reqHistoryBtn.enabled = NO;
            }
            
        }
        
    }else if (isSupportSDCard && self.devModel.safeIdle && !isShared){
        
        self.historyView.hidden = YES;
        if (self.historyView.dataArray.count) {
            self.reqHistoryBtn.hidden = YES;
        }else{
            self.reqHistoryBtn.enabled = NO;
        }
        
    }else{
    
        self.reqHistoryBtn.hidden = YES;
        self.historyView.hidden =  YES;
    }
}

-(void)rpDevDataReq
{
    //获取版本号，获取速率状态
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@513,@207] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                if (seg.msgId == 513) {
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        int type = [obj intValue];
                        [self resetRPBtnTitleForType:type];
                        break;
                    }
                }else if (seg.msgId == 207){
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSString class]]) {
                        NSString *version = obj;
                        rpVersion = [NSString stringWithString:version];
                        break;
                    }
                }
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //防止退出此页面，tip仍然显示问题
    [FLTipsBaseView dismissAll];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [JFGSDK appendStringToLogFile:@"VideoPlayView viewDidDisappear"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationDidEnterBackgroundBeforeEnvchange" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnUpdateHistoryErrorCodeNotification" object:nil];
    
    [JFGSDK appendStringToLogFile:@"removeNotifacation"];
    isAddVideoNotificaiton = NO;
    [self stopVideoAction];
    self.isInCurrentVC = NO;
    if (angleV && angleV.superview) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristIntoAngleVideoViewKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [super viewDidDisappear:animated];
}

-(void)removeHistoryDelegate
{
    self.historyView.delegate = nil;
}

-(void)onNotifyResolutionOvertime
{
    [self playRequestTimeoutDeal];
}

#pragma mark- 开始视频播放准备
-(void)startVideoActionPrepare
{
    [JFGSDK appendStringToLogFile:@"startVideoAction"];
    if (self.devModel.deepSleep) {
        //移除角度提示Tip
        if (angleV) {
            [angleV removeFromSuperview];
            angleV = nil;
        }
        isCanShowHistoryView = NO;
        [self hiddenSmallWindowBottomBar];
        [self hideSmallWindowPlayBtn];
        [self showIdleViewForType:1];
        
    }else if ([NetworkMonitor sharedManager].currentNetworkStatu == NotReachable) {
        
        [self showDisconnectViewWithText:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
        playState = videoPlayStateNotNet;
        [self hideIdleView];
        
    }else{
        
        [self hideDisconnectNetView];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:fristIntoAngleVideoViewKey] && isShowAngle && self.devModel.shareState != DevShareStatuOther) {
            
            //显示那个角度提示
            [self showAngleTip];
            
        }else{
            
            //移除角度提示Tip
            if (angleV) {
                [angleV removeFromSuperview];
                angleV = nil;
            }
            if (self.devModel.safeIdle) {
                
                isCanShowHistoryView = NO;
                [self hiddenSmallWindowBottomBar];
                [self hideSmallWindowPlayBtn];
                [self showIdleViewForType:0];
                
            }else{
                
                isCanShowHistoryView = YES;
                if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                    return;
                }
                UIView *bgView = [self.videoBgView viewWithTag:123451];
                //如果显示了视频连接错误界面，不显示播放按钮
                if (bgView ) {
                    [bgView removeFromSuperview];
                    bgView = nil;
                }
                [self hideIdleView];
                [self showSmallWindowPlayBtn];
                self.playButton.selected = NO;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSmallWindowPlayBtn) object:nil];
               
            }
        }
    }
    [self historyViewState];
    
}

//结束视频
-(void)stopVideoAction
{
    if (!self.historyView.isLoadingData && !self.devModel.deepSleep) {
        [JFGSDK appendStringToLogFile:@"stopVideoAction"];
        if (playState == videoPlayStatePlaying) {
            self.playButton.selected = YES;
            [self playAction:self.playButton];
            self.playButton.selected = NO;
        }else{
            [self stopVideoPlay];
        }
        [self hiddenSmallWindowBottomBar];
        [self showSmallWindowPlayBtn];
    }
    playState = videoPlayStatePause;
}


#pragma mark- sd卡状态
-(void)getIsLive
{
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(dpMsgCamera_isLive)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
               if (seg.msgId == dpMsgCamera_isLive){
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
                                        [self hiddenSmallWindowBottomBar];
                                        [self hideSmallWindowPlayBtn];
                                        [self showIdleViewForType:0];
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

#pragma mark- 获取历史视频按钮点击事件
-(void)reqHistoryAction
{
//    if (sdCardErrorCode != 0) {
//        [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"]];
//        return;
//    }
    
    if (!isHasSDCard) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getSDCardTimeout) object:nil];
        [self performSelector:@selector(getSDCardTimeout) withObject:nil afterDelay:5];
        
        self.reqHistoryBtn.enabled = NO;
        __weak typeof(self) weakSelf = self;
        [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.devModel.uuid msgIds:@[@204] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getSDCardTimeout) object:nil];
            
            for (NSArray *subArr in idDataList) {
                for (DataPointSeg *seg in subArr) {
                    
                    if (seg.msgId == 204)
                    {
                        isGetSDCard = YES;
                        JFGDeviceSDCardInfo *sdInfo = [JFGDataPointValueAnalysis dpFor204Msg:seg];
                        if (sdInfo) {
                            
                            isHasSDCard = sdInfo.isHaveCard;
                            sdCardErrorCode = sdInfo.errorCode;
                            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"hasSDCard:%d errorCode:%ld",isHasSDCard,(long)sdCardErrorCode]];
                           
                            if (sdCardErrorCode != 0 || !isHasSDCard) {
                                weakSelf.reqHistoryBtn.enabled = YES;
                            }
                            [weakSelf sdCardDeal];
                            
                            
                        }
                    }
                }
            }
            
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
    
    }else{
        
        [self sdCardDeal];
        
    }
    
    
}

-(void)getSDCardTimeout
{
    self.reqHistoryBtn.enabled = YES;
}

-(void)sdCardDeal
{
    if (!isHasSDCard) {
        [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
        return;
    }
    
    if (sdCardErrorCode != 0) {
        [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"]];
        return;
    }
    
    if (isHasSDCard) {
        
        if (playState == videoPlayStatePlayPreparing || playState == videoPlayStatePlaying) {
            [self stopVideoPlay];
        }
        
        //移除角度提醒
        if (angleV) {
            [angleV removeFromSuperview];
            angleV = nil;
        }
        
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showHistoryLoadingView];
        });
        
        if (windowMode == videoPlayModeFullScreen) {
            self.historyView.hidden = YES;
            UIButton *reqhi = [self.fullScreenBottomControlBar viewWithTag:10006];
            if (reqhi) {
                reqhi.enabled = NO;
            }
        }else{
            self.reqHistoryBtn.enabled = NO;
        }
        [self.historyView requestData];
        [self performSelector:@selector(historyReqTimeout) withObject:self afterDelay:30];
        
    }
}

//历史录像请求超时
-(void)historyReqTimeout
{
    if (self.isShow) {
        [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"Historical_LoadFail"]];
    }
    if (windowMode == videoPlayModeFullScreen) {
        UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
        if (btn) {
            btn.enabled = YES;
        }
        self.playButton.hidden = YES;
        [self showFullVideoPlayBar];
        [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
        
    }else{
        self.reqHistoryBtn.enabled = YES;
    }
    [self hiddenHistoryLoadingView];
    [self startVideoActionPrepare];
}

//显示历史录像加载控件
-(void)showHistoryLoadingView
{
    [self startLodingAnimation];
    
    if (![self.loadingBgView viewWithTag:123589]) {
        UILabel *loadingText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.videoBgView.width, 17)];
        if (windowMode == videoPlayModeFullScreen) {
            loadingText.width = self.view.height;
        }
        loadingText.top = self.loadingImageView1.bottom+10;
        loadingText.font = [UIFont systemFontOfSize:15];
        loadingText.textColor = [UIColor colorWithHexString:@"#ffffff"];
        loadingText.text = [JfgLanguage getLanTextStrByKey:@"VIDEO_REFRESHING"];
        loadingText.tag = 123589;
        loadingText.textAlignment = NSTextAlignmentCenter;
        [self.loadingBgView addSubview:loadingText];
    }
    
}

//隐藏历史录像加载控件
-(void)hiddenHistoryLoadingView
{
    UIView *v = [self.loadingBgView viewWithTag:123589];
    if (v) {
        [v removeFromSuperview];
        v = nil;
    }
    [self stopLoadingAnimation];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoAction) name:VideoPlayViewDismissNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didScrolerVideoView) name:VideoPlayViewShowingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doorCalling:) name:JFGDoorBellIsCallingKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(angleChangedWithNotification:) name:angleChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doorBellSnap:) name:@"DoorBellCallSnapImage" object:nil];
    /**
     *  开始生成 设备旋转 通知
     */
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    /**
     *  添加 设备旋转 通知
     *
     *  当监听到 UIDeviceOrientationDidChangeNotification 通知时，调用handleDeviceOrientationDidChange:方法
     *  @param handleDeviceOrientationDidChange: handleDeviceOrientationDidChange: description
     *
     *  @return return value description
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];


}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    
    
    
    
    /**
     *  2.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            //NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            //NSLog(@"屏幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            //NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:{
            //NSLog(@"屏幕向左横置");//
            
            if (playState == videoPlayStatePlaying && windowMode == videoPlayModeSmallWindow && self.isShow && self.isInCurrentVC) {
                [self fullScreen];
            }
            
        }
            
            break;
            
        case UIDeviceOrientationLandscapeRight:
            //NSLog(@"屏幕向右橫置");//
            break;
            
        case UIDeviceOrientationPortrait:{
            NSLog(@"屏幕直立");//
            if (playState == videoPlayStatePlaying && windowMode == videoPlayModeFullScreen && self.isShow && self.isInCurrentVC) {
                [self exitFullScreen];
            }
        }
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            //NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            //NSLog(@"无法辨识");
            break;
    }
    
}


-(void)doorBellSnap:(NSNotification *)notification
{
    if ([notification isKindOfClass:[NSNotification class]]) {
    
        NSDictionary *dict = notification.object;
        UIImage *image= dict[@"snapImage"];
        NSString *cid = dict[@"cid"];
        if ([cid isEqualToString:self.devModel.uuid]) {
            
            self.snapeImageView.image = image;
            
        }
        
    }
    
}

-(void)setHistoryVideoForTimestamp:(uint64_t)timestamp
{
    if (isShared == NO && isSupportSDCard) {
        
        isLiveVideo = NO;
        if (self.historyView.dataArray.count) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"transformToVideoTime:%lld",timestamp/1000]];
            
            historyLastestTimeStamp = timestamp/1000;
            if (self.historyView.dataArray.count) {
                [self.historyView setHistoryTableViewOffsetByTimeStamp:historyLastestTimeStamp];
            }
            if (!self.devModel.safeIdle && [JFGSDK currentNetworkStatus] != JFGNetTypeOffline && !self.devModel.deepSleep) {
                if (self.playButton.selected) {
                    self.playButton.selected = NO;
                }
                [self playAction:self.playButton];
            }else{
                [self startVideoActionPrepare];
            }
           
        }else{
            //reqHistoryAction
            historyLastestTimeStamp = timestamp/1000;
            [self reqHistoryAction];
        }
        
    }
}

-(void)removeAllNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//视频播放相关代理
-(void)addVideoNotification
{
    if (isAddVideoNotificaiton) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:@"applicationDidEnterBackgroundBeforeEnvchange" object:nil];//APP进入后台，但是还没有调用停止http服务之前调用
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onRecvDisconnectForRemote:) name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historyErrorCode:) name:@"JFGSDKOnUpdateHistoryErrorCodeNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotifyResolution:) name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotificatyRTCP:) name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
        isAddVideoNotificaiton = YES;
    [JFGSDK appendStringToLogFile:@"addNotification"];
}


//滚动到当前界面
-(void)didScrolerVideoView
{
    if (!self.historyView.isLoadingData) {
        [self startVideoActionPrepare];
    }
}

-(void)didBecomeActive
{
    isEnterBackground = NO;
    if (self.isShow) {
        
        if (!self.historyView.isLoadingData) {
            [self startVideoActionPrepare];
        }
    }
}

-(void)didEnterBackground
{
    if (!self.historyView.isLoadingData) {
        //如果在加载历史视频数据，不需要停止视频（因为已经停止了）
        [self stopVideoAction];
    }
    if (windowMode == videoPlayModeFullScreen) {
        //退出全屏
        [self exitFullScreen];
    }
    isEnterBackground = YES;
}

-(void)doorCalling:(NSNotification *)notification
{
    //NSString *cid = notification.object;
    if (windowMode == videoPlayModeFullScreen) {
        [self exitFullScreen];
    }
    [self viewDidDisappear:YES];
}



#pragma mark- HistoryDatePickerDelegate
-(void)cancel
{
    
}

-(void)didSelectedYearString:(NSString *)year hour:(NSInteger)hour minute:(NSInteger)minute
{
    HistoryVideoDayModel *selectedModel = nil;
    NSRange ranger = [year rangeOfString:@"_"];
    NSString *newYear;
    if (ranger.location != NSNotFound) {
        
        newYear = [year substringToIndex:ranger.location];
        
    }
    
    for (HistoryVideoDayModel *model in historyVideoDateLimits) {
        if ([newYear isEqualToString:model.timeStr]) {
            selectedModel = model;
            break;
        }
    }
    if (selectedModel) {
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:selectedModel.timestamp];
        NSCalendar *greCalendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
        NSDateComponents *dateComponent = [greCalendar components:unitFlags fromDate:date];
        
        NSDateComponents *dateComponent2 = [greCalendar components:unitFlags fromDate:[NSDate date]];
        
        if (dateComponent2.month == dateComponent.month && dateComponent2.day == dateComponent.day) {
            
            if (dateComponent2.hour < hour ) {
                
                
                [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"RECORD_NO_FIND"]];
                return;
                
            }
            
        }
        
        NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
        [dateComponentsForDate setDay:dateComponent.day];
        [dateComponentsForDate setMonth:dateComponent.month];
        [dateComponentsForDate setYear:dateComponent.year];
        [dateComponentsForDate setHour:hour];
        [dateComponentsForDate setMinute:minute];
        [dateComponentsForDate setSecond:0];
        NSDate *startDate = [greCalendar dateFromComponents:dateComponentsForDate];
        
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"选择历史录像时间：%@",startDate]];
        
        uint64_t timestamp = [startDate timeIntervalSince1970];
    
        historyLastestTimeStamp = timestamp;
        isLiveVideo = NO;
        
        if (playState == videoPlayStatePlaying) {
            //[CylanJFGSDK switchLiveVideo:NO beigenTime:model.timestamp];
            [CylanJFGSDK playVideoByTime:historyLastestTimeStamp cid:self.cid];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"playCid:%@",self.cid]];
            [self voiceAndMicBtnNomalState];
            //[self fullVoiceAndMicBtnDisableState];
            self.fullMicBtn.enabled = NO;
            self.fullSnapBtn.enabled = YES;
            self.fullVoideBtn.enabled = YES;
            self.videoPlayBgScrollerView.hidden = NO;
            if (self.videoPlayBgScrollerView.contentSize.width > 0) {
                self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
            }else{
                self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.bounds.size.width, self.videoPlayBgScrollerView.bounds.size.height);
            }
            self.rpBgView.hidden = YES;
            UIButton *switchViewModeBtn = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
            if (switchViewModeBtn) {
                switchViewModeBtn.enabled = NO;
                switchViewModeBtn.hidden = NO;
                self.viewModeBgView.hidden = NO;
            }
            UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
            if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
                PanoramicIosViewRS * _remoteView = (PanoramicIosViewRS *)remoteView;
                [_remoteView setDisplayMode:SFM_Normal];
            }
        }else{
            [self playHistoryVideoForZeroWithTimestamp:historyLastestTimeStamp];
        }
        [self.historyView setHistoryTableViewOffsetByTimeStamp:historyLastestTimeStamp];
        if (windowMode == videoPlayModeFullScreen) {
            [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
        }
    }
}


-(void)hudViewForText:(NSString *)test
{
    if (windowMode == videoPlayModeSmallWindow) {
        
        [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:test position:FLProgressHUDPositionCenter];
        [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1.5];
        
    }else{
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [FLProressHUD hideAllHUDForView:window animation:NO delay:0];
        FLProressHUD *hud = [[FLProressHUD alloc]initWithStyle:FLProgressHUDStyleDark];
        hud.textLabel.text = test;
        hud.position = FLProgressHUDPositionCenter;
        hud.showProgressIndicatorView = NO;
        hud.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        [hud showInView:window animated:YES];
        [FLProressHUD hideAllHUDForView:window animation:YES delay:1.5];
    }
}

-(void)didSelectedItem:(NSString *)item indexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%@",item);
    HistoryVideoDayModel *model = [historyVideoDateLimits objectAtIndex:indexPath.row];
    
    for (NSArray *subArr in self.historyView.dataArray) {
        
        for (historyVideoDurationTimeModel *md in subArr) {
            
            if (md.startTimestamp == model.timestamp && md.startPosition == model.startPosition) {
                currentHistoryModel = md;
                historyLastestTimeStamp = md.startTimestamp;
                break;
            }
            
        }
        
    }
    
    //NSLog(@"%@",model.timeStr);
    }

-(void)selectedItem:(NSString *)item index:(NSInteger)index
{
    HistoryVideoDayModel *model = [historyVideoDateLimits objectAtIndex:index];
    isLiveVideo = NO;
    if (playState == videoPlayStatePlaying) {
        //[CylanJFGSDK switchLiveVideo:NO beigenTime:model.timestamp];
        [CylanJFGSDK playVideoByTime:model.timestamp cid:self.cid];
         [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"playCid:%@",self.cid]];
        [self voiceAndMicBtnNomalState];
        self.fullMicBtn.enabled = NO;
        self.fullSnapBtn.enabled = YES;
        self.fullVoideBtn.enabled = YES;

    }else{
        [self playHistoryVideoForZeroWithTimestamp:model.timestamp];
    }
    [self.historyView startHistoryVideoFromDay:model];
    
    for (NSArray *subArr in self.historyView.dataArray) {
        
        for (historyVideoDurationTimeModel *md in subArr) {
            
            if (md.startTimestamp == model.timestamp && md.startPosition == model.startPosition) {
                currentHistoryModel = md;
                historyLastestTimeStamp = md.startTimestamp;
                break;
            }
        }
        
    }
    
}

#pragma mark- telephoneDelegate
-(void)callState:(TelephonyCallState)state
{
    if (self.isShow) {
    
        if (state == TelephonyCallStateIncoming) {
            //来电话了
            if (!self.historyView.isLoadingData) {
                [self didEnterBackground];
                [self startVideoActionPrepare];
            }else{
                [self stopVideoPlay];
            }
            [JFGSDK appendStringToLogFile:@"来电话了"];
            
        }else if (state == TelephonyCallstateNoDone){
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            if (!self.historyView.isLoadingData) {
                [self startVideoActionPrepare];
            }
            [JFGSDK appendStringToLogFile:@"啥事没干"];
            
        }else if (state == TelephonyCallStateDisconnect){
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            if (!self.historyView.isLoadingData) {
                [self startVideoActionPrepare];
            }
            [JFGSDK appendStringToLogFile:@"挂断电话"];
        }
        
    }
}

#pragma mark- HorizontalHistoryRecordViewDelegate
//开始滚动历史视频进度条
-(void)historyBarStartScroll
{
    historyViewScrolling = YES;
}


//停止滚动历史视频进度条
-(void)historyBarEndScroll
{
    historyViewScrolling = NO;
}

//历史录像滚动条
-(void)scrollerDidScrollForHistoryVideoDate:(NSDate *)date
{
    NSMutableString *dat =  [NSMutableString stringWithString:[self.dateFormatter stringFromDate:date]];
    NSString *str = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Playback"];
    if (str.length > 7) {
        str = [NSString stringWithFormat:@"%@...",[str substringToIndex:4]];
    }
    NSString *liveLanguage = [NSString stringWithFormat:@"%@| ",str];
    [dat insertString:liveLanguage atIndex:0];
    self.videoPlayTipLabel.text = dat;
}

//历史视频滚动条目前指示位置的视频模型数据
-(void)currentHistoryVideoModel:(historyVideoDurationTimeModel *)model
{
    currentHistoryModel = model;
    historyLastestTimeStamp = model.startPlayTimestamp;
    isLiveVideo = NO;
    if (playState == videoPlayStatePlaying) {
        [self playCurrentHistoryVideo];
    }else{
        [self playHistoryVideoForZeroWithTimestamp:model.startPlayTimestamp];
    }
    self.playButton.selected = YES;
    self.fullPlayBtn.selected = YES;
    self.fullPlayBtn.enabled = YES;
    if (windowMode == videoPlayModeSmallWindow) {
        
    }else{
        [self.fullPlayBtn setImage:[UIImage imageNamed:@"full-screen_icon_play"] forState:UIControlStateNormal];
    }
    
    [self voiceAndMicBtnNomalState];
    
}

//所有有历史视频的日期
-(void)historyVideoDateLimits:(NSArray<HistoryVideoDayModel *> *)limits
{
    historyVideoDateLimits = [[NSMutableArray alloc]initWithArray:limits];
    if (self.devModel.safeIdle || isShared) {
        self.historyView.hidden = YES;
        return;
    }
    
    if (limits.count > 0) {
        isLiveVideo = NO;
        //HistoryVideoDayModel*model = limits[0];
        historyLastestTimeStamp = 0;
    }
    
    if (windowMode == videoPlayModeSmallWindow) {
        
        if (limits.count) {
        
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
            self.reqHistoryBtn.hidden = YES;
            self.reqHistoryBtn.alpha = 0;
            if (![[NSUserDefaults standardUserDefaults] boolForKey:fristhistoryVideoKey]) {
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                if (keyWindow) {
                    [keyWindow addSubview:self.handTipForHistory];
                }
            }
            
        }else{
           
            [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"NO_CONTENTS_2"]];
            self.historyView.hidden = YES;
            self.reqHistoryBtn.enabled = YES;
            
        }

    }else{
        
        if (limits.count) {
            
            UIView *v = [self.fullScreenBottomControlBar viewWithTag:1239];
            if (v) {
                v.hidden = NO;
            }
            UIView *v2 = [self.fullScreenBottomControlBar viewWithTag:1234];
            if (v2) {
                v2.hidden = NO;
            }
            UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
            btn.hidden = YES;
            [btn removeFromSuperview];
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
            
        }else{
            
            [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"NO_CONTENTS_2"]];
            self.historyView.hidden = YES;
            UIButton *btn = [self.fullScreenBottomControlBar viewWithTag:10006];
            if (btn) {
                btn.enabled = YES;
            }
        }
        
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(historyReqTimeout) object:self];
    UIView *v = [self.loadingBgView viewWithTag:123589];
    if (v) {
        [self hiddenHistoryLoadingView];
    }

    if (playState != videoPlayStatePlayPreparing && playState != videoPlayStatePlaying) {
        
        if (isEnterBackground) {
            
            [self startVideoActionPrepare];
            
        }else{
            
            if (windowMode == videoPlayModeFullScreen) {
                self.fullPlayBtn.selected = NO;
                [self fullPlayAction:self.fullPlayBtn];
                [self showFullVideoPlayBar];
                [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
            }else{
                
                self.playButton.selected = NO;
                [self playAction:self.playButton];
                
            }
        }
        
        
       
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
    [self startLiveVideo];
    if ([JFGSDK currentNetworkStatus] != JFGNetTypeWifi && [JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
        [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"LIVE_DATA"]];
    }
    UIButton *switchViewModeBtn = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
    if (switchViewModeBtn) {
        switchViewModeBtn.enabled = YES;
    }
    //
}

#pragma mark- 视频播放
-(void)startLiveVideo
{
    if (playState == videoPlayStatePlaying) {
        return;
    }
    if (angleV) {
        [angleV removeFromSuperview];
        angleV = nil;
    }
    playState = videoPlayStatePlayPreparing;
    [self startLodingAnimation];
    timeoutRequestCount = 0;
    [self startTimeoutRequestForDelay:30];
    /*!
     *  开始视频直播 获取视频播放视图
     *  可以通过回调#jfgRTCPNotifyBitRate:videoRecved:frameRate:timesTamp: 查看视频加载情况
        长时间接收视频数据为0，则为网络状况差或者超时。
     */
    
    isLiveVideo = YES;
    [CylanJFGSDK connectCamera:self.cid];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"playCid:%@",self.cid]];
    self.videoPlayBgScrollerView.hidden = NO;
    self.playButton.selected = YES;
    
    
    if (self.videoPlayBgScrollerView.superview != self.videoBgView) {
        [self.videoBgView addSubview:self.videoPlayBgScrollerView];
        [self.videoBgView bringSubviewToFront:self.loadingBgView];
    }
    if (self.historyView) {
        self.historyView.isSelectedHistory = NO;
    }
    UIButton *switchViewModeBtn = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
    if (switchViewModeBtn) {
        switchViewModeBtn.enabled = YES;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
}


#pragma mark- dp主动推送
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
                            if ([[CommonMethod viewControllerForView:self.view] isKindOfClass:[VideoPlayViewController class]] && self.isShow &&  !isShared)
                            {
                                isHasSDCard = NO;
                                self.historyView.hidden = YES;
                                [self.historyView.dataArray removeAllObjects];
                                if (self.reqHistoryBtn.superview == nil) {
                                    [self.view addSubview:self.reqHistoryBtn];
                                }
                                self.reqHistoryBtn.hidden = NO;
                                self.reqHistoryBtn.alpha = 1;
                                self.reqHistoryBtn.enabled = YES;
                                
                                if (!isLiveVideo) {
                                    [self stopVideoPlay];
                                }

                                __weak typeof(self) weakSelf = self;
                                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                                    
                                } OKBlock:^{
                                    if (!isLiveVideo) {
                                        
                                        isLiveVideo = YES;
                                        if (windowMode == videoPlayModeSmallWindow) {
                                            weakSelf.playButton.selected = NO;
                                            [weakSelf playAction:weakSelf.playButton];
                                        }else{
                                            weakSelf.fullPlayBtn.selected = NO;
                                            [weakSelf fullPlayAction:weakSelf.fullPlayBtn];
                                        }
                                    }
                                }];
                                
                                
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
                                        [self hiddenSmallWindowBottomBar];
                                        [self hideSmallWindowPlayBtn];
                                        [self showIdleViewForType:0];
                                        if (isShared == NO) {
                                            self.historyView.hidden = YES;
                                        }
                                    }
                                }else{
                                    self.devModel.safeIdle = NO;
                                    
                                    if (self.isShow) {
                                        [self hideIdleView];
                                        [self startVideoActionPrepare];
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
                        [self switchVideoViewHangMode];
                    }
                }
                    break;
                    
                case 203:{//格式化sd卡
                    
                    self.historyView.hidden = YES;
                    [self.historyView.dataArray removeAllObjects];
                    
                    if (!isLiveVideo) {
                        [self stopVideoPlay];
                    }
                    
                    if (self.isShow)
                    {
                        
                        __weak typeof(self) weakSelf = self;
                        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips6"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                            
                        } OKBlock:^{
                            if (!isLiveVideo) {
                                isLiveVideo = YES;
                                if (windowMode == videoPlayModeSmallWindow) {
                                    [weakSelf playAction:weakSelf.playButton];
                                }else{
                                    [weakSelf fullPlayAction:weakSelf.fullPlayBtn];
                                }
                            }
                        }];
                        
                    }
                }
                    break;
                    
                case 513:{//清晰度
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        int type = [obj intValue];
                        [self resetRPBtnTitleForType:type];
                    }
                    
                }
                    break;
                case 404:{
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    NSArray *sourceArr = obj;
                    if (sourceArr.count > 2) {
                        
                        BOOL isOpen = [sourceArr[0] boolValue];
                        
                        int64_t beginTime = [sourceArr[1] longLongValue];
                        int64_t endTime = [sourceArr[2] longLongValue];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"HH"];
                        int currentHour = [[dateFormatter stringFromDate:[NSDate date]] intValue];
                        // 0  -- 24
                        // 22 -- 8
                        
                        int setBeginHour = (int)beginTime/60/60;
                        int setEndHour = (int)endTime/60/60;
                        
                        if (isOpen) {
                            if (setBeginHour < setEndHour) {
                                //没有跨天
                                if (currentHour>=setBeginHour && currentHour <= setEndHour) {
                                    self.devModel.deepSleep = YES;
                                }else{
                                    self.devModel.deepSleep = NO;
                                }
                                
                                
                            }else{
                                //设置时间跨天了
                                if (currentHour >= setBeginHour || currentHour <= setEndHour) {
                                    self.devModel.deepSleep = YES;
                                }else{
                                    self.devModel.deepSleep = NO;
                                }
                                
                            }
                        }else{
                            
                            self.devModel.deepSleep = NO;
                            
                        }
                        if (self.devModel.deepSleep) {
                            
                            if (playState == videoPlayStatePlaying || playState == videoPlayStatePlayPreparing) {
                                [self stopVideoPlay];
                            }
                            [self hiddenSmallWindowBottomBar];
                            [self hideSmallWindowPlayBtn];
                            [self showIdleViewForType:1];
                            if (isShared == NO) {
                                self.historyView.hidden = YES;
                                self.reqHistoryBtn.enabled = NO;
                            }
                        }else{
                            [self hideIdleView];
                            [self historyViewState];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
    
}

#pragma mark- ###################################################
#pragma mark- 视频播放相关回调代理
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
    
    if (playState == videoPlayStatePause) {
        return;
    }
    
    [self stopVideoPlay];
    NSString *errorMsg = @"";
    
    JFGSDKHistoryVideoErrorInfo *errorInfo = notification.object;
    if (errorInfo.code == 2030) {
       //历史录像播放完成
        errorMsg = [JfgLanguage getLanTextStrByKey:@"FILE_FINISHED"];
        
    }else if (errorInfo.code == 2031){
        //历史录像读取失败
        errorMsg = [JfgLanguage getLanTextStrByKey:@"FILE_ERR"];
        
    }else if (errorInfo.code == 2032){
        //sd卡错误
        errorMsg = [JfgLanguage getLanTextStrByKey:@"SD_ERR"];
    }

    __weak typeof(self) weakSelf = self;
    
    if (windowMode == videoPlayModeSmallWindow) {
        
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"TIPS"] Message:errorMsg CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            
            if (windowMode == videoPlayModeSmallWindow) {
                [weakSelf playAction:weakSelf.playButton];
            }else{
                [weakSelf fullPlayAction:weakSelf.fullPlayBtn];
            }
            
        }];
        
    }else{
        
        [LSAlertView showAlertForTransformRotateWithTitle:[JfgLanguage getLanTextStrByKey:@"TIPS"] Message:errorMsg CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            if (windowMode == videoPlayModeSmallWindow) {
                [weakSelf playAction:weakSelf.playButton];
            }else{
                [weakSelf fullPlayAction:weakSelf.fullPlayBtn];
            }
        }];
        
    }
    
    //保留播放控件
    if (windowMode == videoPlayModeSmallWindow) {
        self.playButton.selected = NO;
    }else{
        self.fullPlayBtn.selected = NO;
    }
//    isLiveVideo = YES;    此时 是 历史录像 失败，但不能说 就是 是在直播？
}

-(void)onNotifyResolution:(NSNotification *)notification
{
   // [self.renderLock lock];
    NSDictionary *dict = notification.object;
    if (dict) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onNotifyResolutionOvertime) object:nil];
        int width = [[dict objectForKey:@"width"] intValue];
        int height = [[dict objectForKey:@"height"] intValue];
        NSLog(@"originSize:%@",NSStringFromCGSize(CGSizeMake(width, height)));
        CGSize size = CGSizeMake(width, height);
        
        //防止多次接受通知
        if (playState == videoPlayStatePlaying) {
            [JFGSDK appendStringToLogFile:@"isStartRender-videoPlayStatePlaying"];
            return;
        }
        
        UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        
        if (self.videoPlayBgScrollerView.superview == nil) {
            [self.videoBgView addSubview:self.videoPlayBgScrollerView];
        }else{
            [self.videoBgView bringSubviewToFront:self.videoPlayBgScrollerView];
        }
        
        if (remoteView) {
            [remoteView removeFromSuperview];
            remoteView = nil;
        }
        BOOL isRS = [DevPropertyManager isRSDevForPid:self.devModel.pid];

        UIView *_remoteView;
        if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360 || ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeSinglefisheyeCamera && isRS)){
            
            width = self.view.width;
            height= width;
            size = CGSizeMake(width, width);
            PanoramicIosViewRS * __remoteView = [[PanoramicIosViewRS alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, size.width, size.height)];
            SFCParamModel *paramModel =[CommonMethod panoramicViewParamModelForCid:self.devModel.uuid];
        
            if (paramModel) {
                struct SFCParamIos param;
                param.cx = paramModel.x;
                param.cy = paramModel.y;
                param.r = paramModel.r;
                param.w = paramModel.w;
                param.h = paramModel.h;
                param.fov = 180;
                [__remoteView configV360:param];
                [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"x:%d y:%d r:%d w:%d h:%d",paramModel.x,paramModel.y,paramModel.r,paramModel.w,paramModel.h]];
                
            }else{
                struct SFCParamIos param;
                param.cx = 640;
                param.cy = 480;
                param.r = 480;
                param.w = 1280;
                param.h = 960;
                param.fov = 180;
                [__remoteView configV360:param];
            }
            if (self.angleType == 1) {
                //挂壁
                [__remoteView setMountMode:MOUNT_WALL];
            }else{
                //吊顶
                [__remoteView setMountMode:MOUNT_TOP];
            }
            
            BOOL isSupportAngleSwitch = YES;
            if (!isShared) {
                isSupportAngleSwitch = [PropertyManager showPropertiesRowWithPid:[self.devModel.pid intValue] key:pAngleKey];
            }else{
                isSupportAngleSwitch = [PropertyManager showSharePropertiesRowWithPid:[self.devModel.pid intValue] key:pAngleKey];
            }
            if (!isSupportAngleSwitch) {
                self.angleType = 1;
                [__remoteView setMountMode:MOUNT_WALL];
            }
            
            //如果是支持圆柱，四分图这种视图切换，但是不支持视角切换，默认设置视角为俯视
            if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360 && !isSupportAngleSwitch) {
                self.angleType = 0;
                [__remoteView setMountMode:MOUNT_TOP];
            }
            
            [__remoteView setDisplayMode:defaultDispalyMode];
            if (!isLiveVideo) {
                [__remoteView setDisplayMode:SFM_Normal];
            }
            
            UITapGestureRecognizer *panTap = [__remoteView getDoubleTapRecognizer];
            [videoTapGesture requireGestureRecognizerToFail:panTap];
            _remoteView = __remoteView;
            
            
        }else if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeSinglefisheyeCamera) {
            
            width = self.view.width;
            height= width;
            size = CGSizeMake(width, width);
            PanoramicIosView * __remoteView = [[PanoramicIosView alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, size.width, size.height)];
            SFCParamModel *paramModel = [CommonMethod panoramicViewParamModelForCid:self.devModel.uuid];
            if (paramModel) {
                struct SFCParamIos param;
                param.cx = paramModel.x;
                param.cy = paramModel.y;
                param.r = paramModel.r;
                param.w = paramModel.w;
                param.h = paramModel.h;
                param.fov = 180;
                [__remoteView configV360:param];
            }else{
                struct SFCParamIos param;
                param.cx = 640;
                param.cy = 480;
                param.r = 480;
                param.w = 1280;
                param.h = 960;
                param.fov = 180;
                [__remoteView configV360:param];
            }
            
            _remoteView = __remoteView;
            //MODE_TOP = 0 吊顶 MODE_WALL = 1 壁挂
            if (self.angleType == 1) {
                //挂壁
                [__remoteView setMountMode:MOUNT_WALL];
            }else{
                //吊顶
                [__remoteView setMountMode:MOUNT_TOP];
            }
            BOOL isSupportAngleSwitch = YES;
            if (!isShared) {
                isSupportAngleSwitch = [PropertyManager showPropertiesRowWithPid:[self.devModel.pid intValue] key:pAngleKey];
            }else{
                isSupportAngleSwitch = [PropertyManager showSharePropertiesRowWithPid:[self.devModel.pid intValue] key:pAngleKey];
            }
            if (!isSupportAngleSwitch) {
                self.angleType = 0;
                [__remoteView setMountMode:MOUNT_WALL];
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
        
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"addRemoteView"]];
        
        [CylanJFGSDK startRenderRemoteView:_remoteView];
        remoteCallViewSize = size;
        
        isStartRender = YES;
        self.playButton.selected = YES;
        self.fullPlayBtn.selected = YES;
        if (isLiveVideo == NO) {
            [self voiceAndMicBtnNomalState];
            [self fullVideoAndMicBtnNomal];
        }

        [self remoteViewSizeFit];
        if (playState != videoPlayStatePlaying)
        {
            [self voiceAndMicBtnNomalState];
            [self fullVideoAndMicBtnNomal];
        }
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
            self.rpBgView.bottom = self.videoBgView.height - 47;
            self.viewModeBgView.y = self.rpBgView.y;
        }else{
            self.videoPlayTipLabel.x = kheight*0.5;
            self.videoPlayTipLabel.bottom = self.fullScreenBottomControlBar.top-10;
        }
        playState = videoPlayStatePlaying;
        self.videoPlayTipLabel.hidden = NO;
        if (self.videoPlayTipLabel.superview == nil) {
            [self.videoBgView addSubview:self.videoPlayTipLabel];
        }else{
            [self.videoPlayTipLabel bringSubviewToFront:self.videoPlayTipLabel];
        }
        
        if (isHasSDCard && isShared == NO) {
            
           [self.view bringSubviewToFront:self.reqHistoryBtn];
            if (self.historyView.dataArray.count) {
                self.historyView.alpha = 1;
                self.historyView.hidden = NO;
                self.reqHistoryBtn.hidden = YES;
             }else{
                self.historyView.hidden = YES;
                self.reqHistoryBtn.alpha = 1;
                self.reqHistoryBtn.hidden = NO;
            }
        }
    
        if (windowMode == videoPlayModeSmallWindow) {
            [self showSmallWindowBottomBar];
            [self performSelector:@selector(hideSmallWindowPlayBtn) withObject:nil afterDelay:3];
        }
        
        //开启屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
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
        
        if (bitRate == 0) {
            
            UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
            if (remoteView) {
                [self startTimeoutRequestForDelay:10];
            }else{
                [self startTimeoutRequestForDelay:30];
            }
            
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
            if (isStartRender) {
                [self stopLoadingAnimation];
            }
            
            isLowSpeed = NO;
        }
        
        NSMutableString *dat = [NSMutableString new];
        if (isLiveVideo) {
            
            dat =  [NSMutableString stringWithString:[self.dateFormatter stringFromDate:[NSDate date]]];
            
            NSString *liveLanguage = [NSString stringWithFormat:@"%@| ",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_VideoLive"]];
            
            //[NSString stringWithFormat:@"%@|5/16 12:30",[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_VideoLive"]];
            [dat insertString:liveLanguage atIndex:0];
            
        }else{

            if (timesTamp == 0) {
//                dat =  [NSMutableString stringWithString:[dateFormatter stringFromDate:[NSDate date]]];
            }else{
                dat =  [NSMutableString stringWithString:[self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timesTamp]]];
            }
            
            NSString *str = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Playback"];
            if (str.length > 7) {
                str = [NSString stringWithFormat:@"%@...",[str substringToIndex:4]];
            }
            
            NSString *liveLanguage = [NSString stringWithFormat:@"%@| ",str];
            [dat insertString:liveLanguage atIndex:0];
            
            if (self.historyView.dataArray.count && timesTamp != 0) {
                [self.historyView setHistoryTableViewOffsetByTimeStamp:timesTamp];
            }
            
        }
        
        if (playState == videoPlayStatePlaying) {
            //保留播放控件
            if (windowMode == videoPlayModeSmallWindow) {
                self.playButton.selected = YES;
            }else{
                self.fullPlayBtn.selected = YES;
            }
            self.rateLabel.hidden = NO;
        }
        
        //时间戳为0或者正在拖动中，不修改
        if (dat && !historyViewScrolling) {
            self.videoPlayTipLabel.text = dat;
        }
        
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
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"RecvDisconnect:%@ errorType:%@",remoteID,dict[@"error"]]];
    
    if ([remoteID isEqualToString:self.cid] || [remoteID isEqualToString:@"server"]) {
        
        JFGErrorType errorType = (JFGErrorType)[dict[@"error"] intValue];
        if (errorType == JFGErrorTypeVideoPeerNotExist) {
            
            BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_AI_Camera Cid:self.devModel.uuid];
            BOOL isAP2 = [CommonMethod isConnectedAPWithPid:productType_AI_Camera_outdoor Cid:self.devModel.uuid];
            if (isAP || isAP2) {
                return;
            }
            self.reqHistoryBtn.enabled = NO;
            self.historyView.hidden = YES;
        }
        [self stopVideoPlay];
        [self showDisconnectViewWithText:[CommonMethod languaeKeyForLiveVideoErrorType:errorType]];
        playState = videoPlayStateDisconnectCamera;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
        
//        if (isShared == NO) {
//            self.historyView.hidden = YES;
//        }
    }
    
}

-(void)startTimeoutRequestForDelay:(NSInteger)delay
{
    if (timeoutRequestCount == 0) {
        [self performSelector:@selector(playRequestTimeoutDeal) withObject:nil afterDelay:delay];
        timeoutRequestCount = 1;
    }
}

-(void)stopTimeoutRequest
{
    if (timeoutRequestCount == 1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playRequestTimeoutDeal) object:nil];
        timeoutRequestCount = 0;
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
    if (statu == NotReachable && self.isShow) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.devModel.safeIdle) {
                return ;
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
            [self hiddenHistoryLoadingView];
            [self hiddenSmallWindowBottomBar];
            [self stopVideoPlay];
            [self startVideoActionPrepare];
            playState = videoPlayStateNotNet;
            if (isShared == NO) {
                self.historyView.hidden = YES;
                self.reqHistoryBtn.hidden = YES;
                if (windowMode == videoPlayModeFullScreen) {
                    if ([self.fullScreenBottomControlBar viewWithTag:10006]) {
                        UIView *v = [self.fullScreenBottomControlBar viewWithTag:10006];
                        [v removeFromSuperview];
                        v = nil;
                    }
                }
            }
            [self showDisconnectViewWithText:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
            
        });
    
    }else{
        
        if (statu == ReachableViaWWAN && self.isShow) {
            if (playState == videoPlayStatePlaying) {
                
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_DATA"]];
                
            }
        }
    }
}

-(void)playRequestTimeoutDeal
{
    if (windowMode == videoPlayModeFullScreen) {
        [self exitFullScreen];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playRequestTimeoutDeal) object:nil];
    playState = videoPlayStateDisconnectCamera;
    [self hiddenSmallWindowBottomBar];
    [self stopVideoPlay];
    [self startVideoActionPrepare];
    self.videoPlayTipLabel.hidden = YES;
    [self showDisconnectViewWithText:[JfgLanguage getLanTextStrByKey:@"Tips_Device_TimeoutRetry"]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
}


//停止视频播放
-(void)stopVideoPlay
{
    if (playState == videoPlayStatePlaying ) {
        [self snapScreen];
        [CylanJFGSDK setAudio:YES openMic:NO openSpeaker:NO];
    }
    
    [CylanJFGSDK stopRenderView:NO withCid:self.cid];
    if (self.cid) {
        [CylanJFGSDK disconnectVideo:self.cid];
    }else{
        [CylanJFGSDK disconnectVideo:@""];
    }
    
    self.rateLabel.hidden = YES;
    [self voiceAndMicBtnDisableState];
    playState = videoPlayStatePause;
    
    UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
            PanoramicIosView *rvc = (PanoramicIosView *)remoteView;
            [rvc stopRender];
        }else if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
            PanoramicIosViewRS *rpv = (PanoramicIosViewRS *)remoteView;
            [rpv stopRender];
        }
        [remoteView removeFromSuperview];
        remoteView = nil;
        [JFGSDK appendStringToLogFile:@"remoteRemoveFromSuperView"];
    }
  
    isStartRender = NO;
    self.videoPlayTipLabel.hidden = YES;
    self.snapeImageView.hidden = NO;
    self.snapeImageView.left = 0;
    self.snapeImageView.width = self.videoPlayBgScrollerView.width;
    self.snapeImageView.height = self.videoPlayBgScrollerView.height;
    [self stopLoadingAnimation];
    [self stopTimeoutRequest];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onNotifyResolutionOvertime) object:nil];
    if (windowMode == videoPlayModeSmallWindow) {
        [self hiddenSmallWindowBottomBar];
    }
    
    //关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}



#pragma mark  ------调整 视频View  -----------
//等比缩放
- (void)remoteViewSizeFit
{
    CGFloat ratio = remoteCallViewSize.height/remoteCallViewSize.width;
    CGFloat width = 0;
    CGFloat height = 0;
    BOOL isRS = [DevPropertyManager isRSDevForPid:self.devModel.pid];
    if (isRS || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360) {
        
        if (windowMode == videoPlayModeFullScreen) {
            height = self.view.bounds.size.width;
            width = height/ratio;
        }else{
            width = self.view.bounds.size.width;
            height = width * ratio;
        }
        
    }else{
        
        if (windowMode == videoPlayModeFullScreen) {
            width = self.view.bounds.size.height;
        }else{
            width = self.view.bounds.size.width;
        }
        height = width * ratio;
        if (windowMode == videoPlayModeFullScreen) {
            if (height < self.view.bounds.size.width) {
                height = self.view.bounds.size.width;
                width = height/ratio;
            }
        }
    }
    
    UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (windowMode == videoPlayModeFullScreen && ![remoteView isKindOfClass:[VideoRenderIosView class]] ) {
        width = self.view.bounds.size.height;
        height = self.view.bounds.size.width;
    }
    
    [self.videoPlayBgScrollerView setContentSize:CGSizeMake(self.videoBgView.bounds.size.width, height)];
    
    if (windowMode == videoPlayModeSmallWindow) {
        
        self.videoBgView.height = height;
        self.videoPlayBgScrollerView.height = height;
        self.playButton.y = height*0.5;
        self.historyView.top = height;
        self.loadingBgView.height = height;
        self.loadingImageView1.y = height*0.5;
        self.reqHistoryBtn.top = height;
        UIView *handTip = [self.handTipForHistory viewWithTag:12879];
        if (handTip) {
            handTip.top = self.videoBgView.height+64+20;
        }
    }
    if (remoteView) {
        
        remoteView.frame = CGRectMake(0, 0, width, height);
        remoteView.x = self.videoPlayBgScrollerView.width*0.5;
        if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
            
            if (windowMode == videoPlayModeFullScreen) {
                remoteView.height = self.view.width;
            }
            PanoramicIosView *rpv = (PanoramicIosView *)remoteView;
            [rpv detectOrientationChange];
            
        }else if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
            
            if (windowMode == videoPlayModeFullScreen) {
                remoteView.height = self.view.width;
            }
            PanoramicIosViewRS *rpv = (PanoramicIosViewRS *)remoteView;
            [rpv detectOrientationChange];
        }
    }
    [self layoutBottomBtn];
    self.snapeImageView.frame = remoteView.bounds;
    self.snapeImageView.hidden = YES;
    [self.videoPlayBgScrollerView setContentOffset:CGPointMake(0, 0)];
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"remoteViewSize:%@" ,NSStringFromCGRect(remoteView.frame)]];
    
    if (windowMode == videoPlayModeSmallWindow) {
        
        CGSize size = CGSizeMake(self.videoBgView.width, self.videoBgView.height);
        NSString *key = [NSString stringWithFormat:@"remoteSize_%@",self.devModel.uuid];
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromCGSize(size) forKey:key];
        
    }
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
        
    }else if (remoteView && [remoteView isKindOfClass:[PanoramicIosViewRS class]]){
        PanoramicIosViewRS *_remoteView =(PanoramicIosViewRS *)remoteView;
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


-(void)shakeBtnAction:(UIButton *)sender
{
    if (sender.selected) {
        isOpenShake = NO;
    }else{
        isOpenShake = YES;
    }
    sender.selected = !sender.selected;
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
        
        
        
        UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        UIImage *image = nil;
        
        if (remoteView && [remoteView isKindOfClass:[PanoramicIosView class]]) {
            
            PanoramicIosView *_remoteView =(PanoramicIosView *)remoteView;
            image = [_remoteView takeSnapshot];
            
        }else if (remoteView && [remoteView isKindOfClass:[PanoramicIosViewRS class]]){
            PanoramicIosViewRS *_remoteView =(PanoramicIosViewRS *)remoteView;
            image = [_remoteView takeSnapshot];
        }else{
            image = [CylanJFGSDK imageForSnapshot];
        }
        
        
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
                        JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
                        NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,self.cid,fileName];
                        [JFGSDK uploadFile:[self saveImage:image] toCloudFolderPath:wonderFilePath];
                        
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
-(void)gotoIdleSetting:(UIButton *)sender
{
    if (sender.tag == 1000) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JFGGotoSettingKey object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:JFGGotoDeepSleepKey object:nil];
    }
    
}

//无网络连接，重试按钮事件
-(void)disconnectNetAction
{
    if ([NetworkMonitor sharedManager].currentNetworkStatu != NotReachable) {
        if ([LoginManager sharedManager].loginStatus ==JFGSDKCurrentLoginStatusSuccess) {
            
            if ([JFGSDK currentNetworkStatus] != JFGNetTypeWifi && [JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_DATA"]];
            }
            [self hideDisconnectNetView];
            [self historyViewState];
            if (isLiveVideo) {
                [self startLiveVideo];
            }else{
                [self playCurrentHistoryVideo];
                [self voiceAndMicBtnNomalState];
            }
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
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSmallWindowPlayBtn) object:nil];
        if (self.playButton.hidden) {
            [self showSmallWindowPlayBtn];
            [self performSelector:@selector(hideSmallWindowPlayBtn) withObject:nil afterDelay:3];
        }else{
            if (playState == videoPlayStatePlaying) {
                [self hideSmallWindowPlayBtn];
            }
            
        }
    }
    
    
}


#pragma mark- 安全防护
//安全防护
-(void)safeguarAction:(SafaButton *)safeSender
{
    //__block BOOL isSafe = NO
    JFG_WS(weakSelf);
    if (safeSender.isFace && warnSensitivity && isHasSDCard) {
        
        if (safeSender == self.safeguardBtn_full) {
            
            [LSAlertView showAlertForTransformRotateWithTitle:@"" Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_MotionDetection_OffTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] CancelBlock:^{
                
                [weakSelf switchSafeForOpen:!safeSender.isFace];
                
            } OKBlock:^{
                
                
                
            }];

        }else{
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_MotionDetection_OffTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"MAGNETISM_OFF"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] CancelBlock:^{
                
                [weakSelf switchSafeForOpen:!weakSelf.safeguardBtn.isFace];
                
            } OKBlock:^{
                
                
                
            }];
            
        }
        
        return;
        
    }else{
        
        if (safeSender.isFace) {
            
            __weak typeof(self) weakSelf = self;
            
            
            if (safeSender == self.safeguardBtn_full) {
                
                [LSAlertView showAlertForTransformRotateWithTitle:@"" Message:[JfgLanguage getLanTextStrByKey:@"Detection_Pop"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"MAGNETISM_OFF"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] CancelBlock:^{
                    
                    [weakSelf switchSafeForOpen:!safeSender.isFace];
                    
                } OKBlock:^{
                    
                    
                    
                }];
                
            }else{
                
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Detection_Pop"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"MAGNETISM_OFF"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] CancelBlock:^{
                    
                    [weakSelf switchSafeForOpen:!weakSelf.safeguardBtn.isFace];
                    
                } OKBlock:^{
                    
                    
                    
                }];
                
            }
            
            
            return;
            
        }
        
        
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
    if (isShared || !isSupportSDCard) {
        return;
    }
    
    if (isGetSDCard) {
        
        if (isHasSDCard) {
            
            if (sdCardErrorCode != 0) {
                
                [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"]];
                
                
            }else{
                
                //有可使用的sd卡，但是没有获取到录像数据
                if (!self.historyView.dataArray.count) {
                    
                    NSString *ts = @"";
                    if (self.historyView.isLoadHistoryData) {
                        ts = [JfgLanguage getLanTextStrByKey:@"NO_CONTENTS_2"];
                    }else{
                        ts = [JfgLanguage getLanTextStrByKey:@"History_video_Firstly"];
                    }
                    [self hudViewForText:ts];
            
                }else{
                    
                    [self showHistoryAleartView];
                    
                }
                
            }
            
            
            
        }else{
            [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
        }
        
    }else{
        
        [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"History_video_Firstly"]];
    }
    
}


-(void)showHistoryAleartView
{
    if (windowMode == videoPlayModeSmallWindow) {
        
        NewHistoryDateSelectedPicker *picker = [NewHistoryDateSelectedPicker historyDatePicker];
        NSMutableArray *dateList = [[NSMutableArray alloc]init];
        NSMutableArray *hoursList = [NSMutableArray new];
        NSMutableArray *minList = [NSMutableArray new];
        
        for (HistoryVideoDayModel *model in historyVideoDateLimits) {
            NSString *week = [self weekdayStringFromDate:[NSDate dateWithTimeIntervalSince1970:model.timestamp]];
            [dateList addObject:[NSString stringWithFormat:@"%@_%@",model.timeStr,week]];
        }
        
        for (int i=0; i<24; i++) {
            [hoursList addObject:[NSString stringWithFormat:@"%d%@",i,[JfgLanguage getLanTextStrByKey:@"HOUR"]]];
        }
        
        for (int i=0; i<60; i++) {
            [minList addObject:[NSString stringWithFormat:@"%d%@",i,[JfgLanguage getLanTextStrByKey:@"MINUTE"]]];
        }
        
        picker.dataArray = (NSMutableArray *)[NSArray arrayWithObjects:dateList,hoursList,minList, nil];
        CGFloat widht = (self.view.width - 200)/2.0;
        picker.widthForComponents = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:200],[NSNumber numberWithFloat:widht],[NSNumber numberWithFloat:widht], nil];
        picker.delegate = self;
        [picker show];
        
    }else{
        
        NewHistoryDateSelectedPicker *picker = [NewHistoryDateSelectedPicker historyDatePicker];
        NSMutableArray *dateList = [[NSMutableArray alloc]init];
        NSMutableArray *hoursList = [NSMutableArray new];
        NSMutableArray *minList = [NSMutableArray new];
        for (HistoryVideoDayModel *model in historyVideoDateLimits) {
            NSString *week = [self weekdayStringFromDate:[NSDate dateWithTimeIntervalSince1970:model.timestamp]];
            [dateList addObject:[NSString stringWithFormat:@"%@_%@",model.timeStr,week]];
        }
        
        for (int i=0; i<24; i++) {
            [hoursList addObject:[NSString stringWithFormat:@"%d%@",i,[JfgLanguage getLanTextStrByKey:@"HOUR"]]];
        }
        
        for (int i=0; i<60; i++) {
            [minList addObject:[NSString stringWithFormat:@"%d%@",i,[JfgLanguage getLanTextStrByKey:@"MINUTE"]]];
        }
        
        picker.dataArray = (NSMutableArray *)[NSArray arrayWithObjects:dateList,hoursList,minList, nil];
        CGFloat widht = (self.view.width - 220)/2.0;
        picker.widthForComponents = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:220],[NSNumber numberWithFloat:widht],[NSNumber numberWithFloat:widht], nil];
        picker.delegate = self;
        picker.isFullScreen = YES;
        picker.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        picker.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        picker.pickerBgView.frame = CGRectMake(0, self.view.width, self.view.height, 205);
        picker._pickerView.frame = CGRectMake(0, 44, self.view.height, 163);
        picker.maskView.frame = picker.bounds;
        picker.doBtn.right = picker.pickerBgView.width - 17;
        [picker show];
        NSLog(@"%@",NSStringFromCGRect(picker.frame));
        
    }
}

- (NSString*)weekdayStringFromDate:(NSDate*)inputDate
{
    /*
     "MON_Hisvideo_Timeselector" = "周一";
     "TUE_Hisvideo_Timeselector" = "周二";
     "WED_Hisvideo_Timeselector" = "周三";
     "THU_Hisvideo_Timeselector" = "周四";
     "FRI_Hisvideo_Timeselector" = "周五";
     "SAT_Hisvideo_Timeselector" = "周六";
     "SUN_Hisvideo_Timeselector" = "周日";
     "HOUR" = "时";
     "MINUTE" = "分";
     */
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], [JfgLanguage getLanTextStrByKey:@"SUN_Hisvideo_Timeselector"], [JfgLanguage getLanTextStrByKey:@"MON_Hisvideo_Timeselector"], [JfgLanguage getLanTextStrByKey:@"TUE_Hisvideo_Timeselector"], [JfgLanguage getLanTextStrByKey:@"WED_Hisvideo_Timeselector"], [JfgLanguage getLanTextStrByKey:@"THU_Hisvideo_Timeselector"], [JfgLanguage getLanTextStrByKey:@"FRI_Hisvideo_Timeselector"], [JfgLanguage getLanTextStrByKey:@"SAT_Hisvideo_Timeselector"], nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    return [weekdays objectAtIndex:theComponents.weekday];
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
            [self voiceAndMicBtnNomalState];
        }
        sender.selected = YES;
        
        if ([JFGSDK currentNetworkStatus] != JFGNetTypeWifi && [JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
             [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_DATA"]];
        }
        //点击播放按钮才开始加载历史视频数据
        
    }else{
        //暂停
        [self stopVideoPlay];
        sender.selected = NO;
        //防止执行停止播放后，rtcp回调代理处会把按钮状态改变
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            sender.selected = NO;
        });
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSmallWindowPlayBtn) object:nil];
    }
    self.fullPlayBtn.selected = sender.selected;
}

-(void)playHistoryVideoForZeroWithTimestamp:(int64_t)time
{
    historyLastestTimeStamp = time;
    if (playState != videoPlayStatePlaying && isLiveVideo == NO) {
        
        self.playButton.selected = YES;
        [self startLodingAnimation];
        //[CylanJFGSDK connectCamera:self.cid];
        [CylanJFGSDK playVideoByTime:historyLastestTimeStamp cid:self.cid];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"playCid:%@",self.cid]];
        self.fullMicBtn.enabled = NO;
        self.fullSnapBtn.enabled = YES;
        self.fullVoideBtn.enabled = YES;
        
        self.videoPlayBgScrollerView.hidden = NO;
        if (self.videoPlayBgScrollerView.contentSize.width > 0) {
            self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
        }else{
            self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.bounds.size.width, self.videoPlayBgScrollerView.bounds.size.height);
        }
        self.rpBgView.hidden = YES;
        UIButton *switchViewModeBtn = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
        if (switchViewModeBtn) {
            switchViewModeBtn.enabled = NO;
            switchViewModeBtn.hidden = NO;
            self.viewModeBgView.hidden = NO;
        }
        UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
            PanoramicIosViewRS * _remoteView = (PanoramicIosViewRS *)remoteView;
            [_remoteView setDisplayMode:SFM_Normal];
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
            [self voiceAndMicBtnNomalState];
        }
        sender.selected = YES;
        if ([JFGSDK currentNetworkStatus] != JFGNetTypeWifi && [JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
           
            [self hudViewForText:[JfgLanguage getLanTextStrByKey:@"LIVE_DATA"]];
        }
        
        
    }else{
        //暂停
        [self stopVideoPlay];
        [self historyCurrentModeByTimestamp];
        sender.selected = NO;
        self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
        self.loadingBgView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
        
    }
    [self fullVoiceAndMicBtnDisableState];
    self.playButton.selected = sender.selected;

//    int64_t delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        self.playButton.selected = sender.selected;
//    });
    
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
                    historyLastestTimeStamp = model.startTimestamp;
                    break;
                }
            }
        }
    }
}

-(void)playCurrentHistoryVideo
{
    if (angleV) {
        [angleV removeFromSuperview];
        angleV = nil;
    }
    if (isLiveVideo == NO) {
        
        if (playState == videoPlayStatePlaying) {
            [CylanJFGSDK playVideoByTime:historyLastestTimeStamp cid:self.cid];
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"playCid:%@",self.cid]];
            self.fullMicBtn.enabled = NO;
            self.fullSnapBtn.enabled = YES;
            self.fullVoideBtn.enabled = YES;
            self.rpBgView.hidden = YES;
            UIButton *switchViewModeBtn = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
            if (switchViewModeBtn) {
                switchViewModeBtn.enabled = NO;
            }
            self.viewModeBgView.hidden = NO;
            UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
            if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
                PanoramicIosViewRS * _remoteView = (PanoramicIosViewRS *)remoteView;
                [_remoteView setDisplayMode:SFM_Normal];
            }
            
        }else{
            [self playHistoryVideoForZeroWithTimestamp:historyLastestTimeStamp];
        }
    }
    
}

#pragma mark- 状态设置
-(void)isFristIntoView
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:fristSafeKey]) {
        
        if (self.isShow && playState == videoPlayStatePlayPreparing) {
            //[self showSafeTip];
            //第一次进入页面
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristSafeKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
//            safeTipTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
//                
//                if (self.isShow && playState == videoPlayStatePlayPreparing) {
//                   // [self showSafeTip];
//                    [timer invalidate];
//                    //第一次进入页面
//                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristSafeKey];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                }
//                
//            } repeats:YES];
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
    if (self.viewModeSwitchBtn && isLiveVideo) {
        self.viewModeSwitchBtn.enabled = YES;
    }
    self.snapBtn.enabled = YES;
    isTalkBack = NO;
    isAudio = NO;
    
    if (isLiveVideo) {
        [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
        if (playState == videoPlayStatePlaying) {
            [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
        }
        
    }else{
        self.microphoneBtn.enabled = NO;
        [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
        if (playState == videoPlayStatePlaying) {
            [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
        }

    }
    
   
}



//下方三个按钮设置不可点击状态
-(void)voiceAndMicBtnDisableState
{
    isTalkBack = NO;
    isAudio = NO;
    [CylanJFGSDK setAudio:YES openMic:isTalkBack openSpeaker:isAudio];
    if (playState == videoPlayStatePlaying) {
        [CylanJFGSDK setAudio:NO openMic:YES openSpeaker:NO];
    }
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
    if (self.viewModeSwitchBtn) {
        self.viewModeSwitchBtn.enabled = NO;
    }
}

-(void)fullVideoAndMicBtnNomal
{
    self.fullVoideBtn.selected = NO;
    self.fullMicBtn.selected = NO;
    self.fullVoideBtn.enabled = YES;
    self.fullMicBtn.enabled = YES;
    self.fullSnapBtn.enabled = YES;
    self.fullPlayBtn.enabled = YES;
    if (self.viewModeSwitchBtn && isLiveVideo) {
        self.viewModeSwitchBtn.enabled = YES;
    }
    if (!isLiveVideo) {
        self.fullMicBtn.enabled = NO;
    }
}



#pragma mark- *********************全屏 小屏切换******************************
//全屏
-(void)fullScreen
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    windowMode = videoPlayModeFullScreen;
    [self hiddenSmallWindowBottomBar];
    self.playButton.hidden = YES;
    [self hideSmallWindowPlayBtn];
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
        
        [self.historyView removeFromSuperview];
        self.historyView.frame = CGRectMake(90, 0, [UIScreen mainScreen].bounds.size.height-90-90, 55);
        [self.fullScreenBottomControlBar addSubview:self.historyView];
        self.historyView.viewType = ViewTypeFullMode;
        [self.historyView reloadData];
        [self fullHistoryViewState];
        
    }
    
    
    
    //历史视频底部Bar分割线
    if (![self.fullScreenBottomControlBar viewWithTag:1234]) {
        UIView *leftLine = [[UIView alloc]initWithFrame:CGRectMake(90, 0, 2, 50)];
        leftLine.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1];
        leftLine.tag = 1234;
        if (!self.historyView.dataArray.count) {
            leftLine.hidden = YES;
        }
        [self.fullScreenBottomControlBar addSubview:leftLine];
        
    }
    
    if (![self.fullScreenBottomControlBar viewWithTag:1239]) {
        UIView *rightLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 50)];
        rightLine.backgroundColor = [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1];
        rightLine.right = [UIScreen mainScreen].bounds.size.height-90;
        rightLine.tag = 1239;
        if (!self.historyView.dataArray.count) {
            rightLine.hidden = YES;
        }
        [self.fullScreenBottomControlBar addSubview:rightLine];
    }
    
    
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    
    //添加黑色背景
    [keyWindows addSubview:self.fullShadeView];
    [self.videoPlayTipLabel removeFromSuperview];
    [self.rpBgView removeFromSuperview];
    [self.viewModeBgView removeFromSuperview];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    
        [self.videoBgView removeFromSuperview];
        
        [keyWindows addSubview:self.videoBgView];
       
        self.videoBgView.transform = CGAffineTransformMakeRotation(90 * (M_PI / 180.0f));
        self.videoBgView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        self.videoPlayBgScrollerView.frame = self.videoBgView.bounds;
        if (self.videoPlayBgScrollerView.contentSize.width < self.videoPlayBgScrollerView.frame.size.width) {
            self.videoPlayBgScrollerView.contentSize = self.videoBgView.bounds.size;
        }
        [JFGSDK appendStringToLogFile:@"fullScreen remoteViewSizeFit"];
        [self remoteViewSizeFit];
        
        if (![DevPropertyManager isRSDevForPid:self.devModel.pid]) {
            self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
        }
    
        self.rateLabel.top = 60;
        self.rateLabel.right = self.videoBgView.height-10;
        
    } completion:^(BOOL finished) {
        
        self.videoPlayTipLabel.x = kheight*0.5;
        self.videoPlayTipLabel.bottom = self.fullScreenBottomControlBar.top-10;
        self.rpBgView.right = kheight - 15;
        self.rpBgView.bottom = self.fullScreenBottomControlBar.top-10;
        self.rpBgView.hidden = NO;
        self.rpBgView.alpha = 1;
        self.viewModeBgView.y = self.rpBgView.y;
        self.viewModeBgView.left = 18;
        self.viewModeBgView.alpha = 1;
        [self.videoBgView addSubview:self.videoPlayTipLabel];
        [self.videoBgView addSubview:self.fullScreenTopControlBar];
        [self.videoBgView addSubview:self.fullScreenBottomControlBar];
        [self.videoBgView addSubview:self.rpBgView];
        [self.videoBgView addSubview:self.viewModeBgView];
        [self.fullShadeView removeFromSuperview];
        
        self.loadingBgView.frame = self.videoBgView.bounds;
        self.loadingImageView1.x = self.loadingBgView.x;
        self.loadingImageView1.y = self.loadingBgView.y;
        
    }];
    
    UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
        PanoramicIosView *panView = (PanoramicIosView *)remoteView;
        [panView detectOrientationChange];
    }else if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
        PanoramicIosViewRS *panView = (PanoramicIosViewRS *)remoteView;
        [panView detectOrientationChange];
    }
    
//    [self.fullPlayBtn setImage:[UIImage imageNamed:@"full-screen_icon_pause"] forState:UIControlStateSelected];
//    [self.fullPlayBtn setImage:[UIImage imageNamed:@"full-screen_icon_play"] forState:UIControlStateNormal];
    
    
    if (playState == videoPlayStatePlaying) {
        self.fullPlayBtn.selected = YES;
    }else{
        self.fullPlayBtn.selected = NO;
    }
    
    //remove一次后按钮设置状态相关属性会丢失
    if (defaultDispalyMode == SFM_Normal) {
        self.shakeBtn.enabled = YES;
    }else{
        self.shakeBtn.enabled = NO;
    }

    //三秒后自动隐藏工具栏
    [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
}





//退出全屏
-(void)exitFullScreen
{
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
        if (self.historyView.dataArray.count) {
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
            self.reqHistoryBtn.hidden = YES;
        }else{
            self.reqHistoryBtn.hidden = NO;
            self.historyView.alpha = 0;
            self.historyView.hidden = YES;
        }
        [self.view addSubview:self.historyView];
        
    }else{
        
        self.historyView.alpha = 0;
        self.historyView.hidden = YES;
    }

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        [self.videoBgView removeFromSuperview];
        self.loadingBgView.layer.transform = CATransform3DIdentity;
        [self.view addSubview:self.videoBgView];
        
        self.videoBgView.transform = CGAffineTransformIdentity;
        self.videoBgView.frame = CGRectMake(0, 0, self.view.width, self.view.height*0.45);
        self.videoPlayBgScrollerView.frame = self.videoBgView.bounds;
        if (self.videoPlayBgScrollerView.contentSize.width < self.videoPlayBgScrollerView.frame.size.width) {
            self.videoPlayBgScrollerView.contentSize = self.videoBgView.bounds.size;
        }
        if (self.videoPlayBgScrollerView.superview == nil) {
            
            [self.videoBgView addSubview:self.videoPlayBgScrollerView];
            
        }
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
        [self.rpBgView removeFromSuperview];
        [self.viewModeBgView removeFromSuperview];
        [self hideRpLeftBtn];
        [self closeViewModelAnimation:NO];
        
        self.rpBgView.hidden = NO;
        self.rpBgView.alpha = 1;
        self.viewModeBgView.alpha = 1;
        self.rpBgView.right = self.videoBgView.width-20;
        self.rpBgView.bottom = self.videoBgView.height - 47;
        self.viewModeBgView.y = self.rpBgView.y;
        self.viewModeBgView.left = 18;
        self.videoPlayTipLabel.x = self.view.width*0.5;
        self.videoPlayTipLabel.bottom = self.videoBgView.height-8;
        [self.videoBgView addSubview:self.videoPlayTipLabel];
        [self.videoBgView addSubview:self.rpBgView];
        [self.videoBgView addSubview:self.viewModeBgView];
        
    }];
    
    [self.playButton setImage:[UIImage imageNamed:@"camera_btn_play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"camera_btn_pause"] forState:UIControlStateSelected];
    
    UIView *remoteView =[self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if ([remoteView isKindOfClass:[PanoramicIosView class]]) {
        PanoramicIosView *panView = (PanoramicIosView *)remoteView;
        [panView detectOrientationChange];
    
    }else if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
        PanoramicIosViewRS *rpv = (PanoramicIosViewRS *)remoteView;
        [rpv detectOrientationChange];
    }
    
    @try {
        //来电话的时候，退出全屏有崩溃风险
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    } @catch (NSException *exception) {
        NSLog(@"崩溃了");
    } @finally {
        
    }
   
    
    if (playState == videoPlayStatePlaying) {
        [self showSmallWindowPlayBtn];
        [self performSelector:@selector(hideSmallWindowPlayBtn) withObject:nil afterDelay:3];
        [self showSmallWindowBottomBar];
    }else{
        [self showSmallWindowPlayBtn];
        self.rpBgView.hidden = YES;//动画会导致切换的时候消失不自然
        [self hiddenSmallWindowBottomBar];
    }
}

-(void)showSmallWindowBottomBar
{
    if (self.devModel.safeIdle) {
        return;
    }
    
    UIView *bgView = [self.videoBgView viewWithTag:123451];
    //如果显示了视频连接错误界面，不显示播放按钮
    if (bgView) {
        return;
    }
    self.videoBottomBar.hidden = NO;
    if (isLiveVideo) {
        self.rpBgView.hidden = NO;
    }else{
        self.rpBgView.hidden = YES;
        UIButton *switchViewModeBtn = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
        if (switchViewModeBtn) {
            switchViewModeBtn.enabled = NO;
            switchViewModeBtn.hidden = NO;
        }
    }
    
    if (isShared == NO) {
        if (self.historyView.dataArray.count > 0) {
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
        }
    }
    if (self.videoBottomBar.superview == nil) {
        [self.videoBgView addSubview:self.videoBottomBar];
        [self.videoBgView addSubview:self.rpBgView];
        [self.videoBgView addSubview:self.playButton];
        [self.videoBgView addSubview:self.viewModeBgView];
    }
    [self.videoBgView bringSubviewToFront:self.videoBottomBar];
    [self.videoBgView bringSubviewToFront:self.videoPlayTipLabel];
    [self.videoBgView bringSubviewToFront:self.rpBgView];
    [self.videoBgView bringSubviewToFront:self.viewModeBgView];

    [UIView animateWithDuration:0.5 animations:^{
        self.videoBottomBar.alpha = 1;
        if (playState == videoPlayStatePlaying) {
            self.videoBottomBar.bottom = self.videoBgView.bottom;
            if (isShared == NO) {
                self.historyView.alpha = 1;
            }
        }else{
            self.videoBottomBar.bottom = self.videoBgView.bottom;
        }
        self.rpBgView.alpha = 1;
        self.viewModeBgView.alpha = 1;
    }];
}

#pragma mark- 特殊状态视图显示隐藏
-(void)showSmallWindowPlayBtn
{
    if (self.devModel.safeIdle) {
        return;
    }
    UIView *bgView = [self.videoBgView viewWithTag:123451];
    //如果显示了视频连接错误界面，不显示播放按钮
    if (bgView || angleV) {
        return;
    }
    
    if (self.videoPlayBgScrollerView.superview == nil) {
        [self.videoBgView addSubview:self.videoPlayBgScrollerView];
        self.videoPlayBgScrollerView.hidden = NO;
    }
    //显示截图
    if (self.snapeImageView.superview != self.videoPlayBgScrollerView) {
        [self.videoPlayBgScrollerView addSubview:self.snapeImageView];
    }
    self.snapeImageView.hidden = NO;
    
    if (self.videoPlayBgScrollerView.contentSize.width > 0) {
        self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.contentSize.width, self.videoPlayBgScrollerView.contentSize.height);
    }else{
        self.snapeImageView.frame = CGRectMake(0, 0, self.videoPlayBgScrollerView.bounds.size.width, self.videoPlayBgScrollerView.bounds.size.height);
    }
    if (self.videoBottomBar.superview == nil) {
        [self.videoBgView addSubview:self.playButton];
        [self.videoBgView addSubview:self.videoBottomBar];
        [self.videoBgView addSubview:self.rpBgView];
        [self.videoBgView addSubview:self.viewModeBgView];
    }
    [self.videoBgView bringSubviewToFront:self.playButton];
    [self stopLoadingAnimation];
    self.playButton.y = self.videoBgView.height * 0.5;
    if (playState != videoPlayStatePlayPreparing && windowMode != videoPlayModeFullScreen) {
        
        self.playButton.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.playButton.alpha = 1;
        }];
        
    }
    
}

-(void)hiddenSmallWindowBottomBar
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.videoBottomBar.alpha = 0;
        self.rpBgView.alpha = 0;
        self.viewModeBgView.alpha = 0;
        self.videoBottomBar.top = self.videoBgView.height+10;
 
    } completion:^(BOOL finished) {

        self.videoBottomBar.hidden = YES;
        self.rpBgView.hidden = YES;
        [self hideRpLeftBtn];
        [self closeViewModelAnimation:NO];
    }];
    
    if (windowMode == videoPlayModeFullScreen){
        if (isShared == NO && self.historyView.dataArray.count) {
            self.historyView.alpha = 1;
            self.historyView.hidden = NO;
        }
    }
}

-(void)hideSmallWindowPlayBtn
{
    [UIView animateWithDuration:0.5 animations:^{
        self.playButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.playButton.hidden = YES;
    }];
}

-(void)showFullVideoPlayBar
{
    [self.videoBgView bringSubviewToFront:self.videoPlayTipLabel];
    [self.videoBgView bringSubviewToFront:self.fullScreenTopControlBar];
    [self.videoBgView bringSubviewToFront:self.fullScreenBottomControlBar];
    if (self.historyView.dataArray.count) {
        self.historyView.alpha = 1;
        self.historyView.hidden = NO;
    }else{
        self.historyView.hidden = YES;
    }
    self.rpBgView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.videoPlayTipLabel.bottom = Kwidth-self.fullScreenBottomControlBar.height-10;
        self.rpBgView.top = [UIScreen mainScreen].bounds.size.width-self.fullScreenBottomControlBar.height - 10 -22;
        self.viewModeBgView.y = self.rpBgView.y;
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
    if (historyViewScrolling) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFullVideoPlayBar) object:nil];
        [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:3];
        
        return;
    }
    
    
    [UIView animateWithDuration:0.7 animations:^{
        self.videoPlayTipLabel.bottom = Kwidth - 10;
        self.rpBgView.top = Kwidth;
        self.viewModeBgView.top = Kwidth;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.fullScreenTopControlBar.top = -self.fullScreenTopControlBar.height;
        self.fullScreenBottomControlBar.top = [UIScreen mainScreen].bounds.size.width;
        self.rateLabel.top = 10;
        
    } completion:^(BOOL finished) {
        
        [self hideRpLeftBtn];
        [self closeViewModelAnimation:NO];
        
    }];
}

//显示待机视图
-(void)showIdleViewForType:(int)type
{
    if (self.idleModeBgView.superview == nil || self.idleModeBgView.hidden == YES ) {
        
        [self.videoBgView addSubview:self.idleModeBgView];
        self.idleModeBgView.hidden = NO;
        self.videoBgView.backgroundColor = [UIColor colorWithHexString:@"#31506f"];
        
        [self idleModelSubViewForType:type];
        [self hiddenSmallWindowBottomBar];
        [self hideSmallWindowPlayBtn];
        [self hideDisconnectNetView];
        [self stopLoadingAnimation];
        [self.videoPlayTipLabel removeFromSuperview];
        [self historyViewState];
    }else{
        [self.videoBgView bringSubviewToFront:self.idleModeBgView];
    }
   
}

-(void)hideIdleView
{
    [self.idleModeBgView removeFromSuperview];
    self.idleModeBgView.hidden = YES;
    self.videoBgView.backgroundColor = [UIColor blackColor];
}

-(void)showDisconnectViewWithText:(NSString *)text
{
    if (windowMode == videoPlayModeFullScreen) {
        [self exitFullScreen];
    }
    
    [self stopLoadingAnimation];
    [self hideSmallWindowPlayBtn];
    [self hiddenSmallWindowBottomBar];
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
        //NSInteger pid = [self.devModel.pid integerValue];
        if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360 || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeSinglefisheyeCamera) {
            height = self.view.width;
        }else{
            NSString *key = [NSString stringWithFormat:@"remoteSize_%@",self.devModel.uuid];
            NSString *sizeStr = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if (sizeStr) {
                CGSize size = CGSizeFromString(sizeStr);
                height = size.height;
            }else{
                height = self.view.height*0.45;
            }
            
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

-(void)idleModelSubViewForType:(int)type
{
    UIImageView *idleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    idleImageView.center = CGPointMake(self.idleModeBgView.width*0.5, 20);
    idleImageView.image = [UIImage imageNamed:@"camera_icon_standby"];
    if (type == 1) {
        idleImageView.image = [UIImage imageNamed:@"pic_powersaving"];
    }
    [self.idleModeBgView addSubview:idleImageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.idleModeBgView.width*0.5-320*0.5, idleImageView.bottom+17, 320, 35*0.5)];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Standby"];
    if (type == 1) {
        label.text = [JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_MODE_ON"];
    }
    label.textAlignment = NSTextAlignmentCenter;
    [self.idleModeBgView addSubview:label];
    
    
    //被分享设备不显示前往设置按钮
    if (!isShared) {
        UIButton *gotoSet = [UIButton buttonWithType:UIButtonTypeCustom];
        gotoSet.tag = type+1000;
        gotoSet.frame = CGRectMake(self.idleModeBgView.width*0.5-152*0.5, label.bottom, 152, 30);
        [gotoSet setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Standby_OffTips"] forState:UIControlStateNormal];
        [gotoSet setTitleColor:[UIColor colorWithHexString:@"#36bdff"] forState:UIControlStateNormal];
        gotoSet.titleLabel.font = [UIFont systemFontOfSize:13];
        gotoSet.titleLabel.textAlignment = NSTextAlignmentCenter;
        [gotoSet addTarget:self action:@selector(gotoIdleSetting:) forControlEvents:UIControlEventTouchUpInside];
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
        if (isShared || ![jfgConfigManager devIsSupportSafetyForPid:self.devModel.pid]) {
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
        if (isShared || ![jfgConfigManager devIsSupportSafetyForPid:self.devModel.pid]) {
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
        _videoPlayTipLabel.adjustsFontSizeToFitWidth = YES;
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
        _playButton.y = self.view.height*0.16;
        [_playButton setImage:[UIImage imageNamed:@"camera_btn_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"camera_btn_pause"] forState:UIControlStateSelected];
        _playButton.selected = NO;
        [_playButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
        //_playButton.hidden = YES;
        //_playButton.alpha = 0;
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
    UIView *histLoading = [self.loadingBgView viewWithTag:123589];
    if (histLoading) {
        [histLoading removeFromSuperview];
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
        devIp = [[NSString alloc]initWithString:ask.address];
        devMac = [[NSString alloc]initWithString:ask.mac];
        if ([DevPropertyManager isSupportRPSwitchForPid:self.devModel.pid]) {
            
            rpVersion = [NSString stringWithString:ask.ver];
            
        }
    }
}

- (void)jfgDevVersionUpgradInfo:(JFGSDKDeviceVersionInfo *)info
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"isHaveNewPackage [%d] cid[%@] ", info.hasNewPkg, info.cid]];
    
    if (info.hasNewPkg && [self.cid isEqualToString:info.cid])
    {
        [self showAlterView];
    }
}

- (void)showAlterView
{

    if (self.isInCurrentVC)
    {
        NSUserDefaults *stdDefault = [NSUserDefaults standardUserDefaults];
        double showedTime = [[stdDefault objectForKey:[NSString stringWithFormat:@"_showUpgradeViewTime_%@",self.cid]] doubleValue];
        BOOL isToday = [JfgTimeFormat isToday:showedTime];
        
        if (!isToday)
        {
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Device_UpgradeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
                upgradeDevice.cid = self.cid;
                upgradeDevice.pType = (productType)[self.devModel.pid intValue];
                [self.navigationController pushViewController:upgradeDevice animated:YES];
            }];
            
            [stdDefault setObject:@([[NSDate date] timeIntervalSince1970]) forKey:[NSString stringWithFormat:@"_showUpgradeViewTime_%@",self.cid]];
            
        }
        
        [stdDefault synchronize];
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
        if ([CommonMethod isOutdoorDevForOS:self.devModel.pid]) {
         
            _voiceButton.left = 90;
            
        }
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
        if ([CommonMethod isOutdoorDevForOS:self.devModel.pid]) {
            _microphoneBtn.hidden = YES;
            _microphoneBtn.alpha = 0;
        }
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
        if ([CommonMethod isOutdoorDevForOS:self.devModel.pid]) {
            _snapBtn.right = self.view.width - 90;
        }
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

-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"MM/dd HH:mm"];
    }
    return _dateFormatter;
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


-(void)battreyForPid:(NSString *)pid
{
    BOOL isGetPorwer = NO;
    float porwer = 0;
    NSArray *porwers = [jfgConfigManager getPoewerModel];
    for (PorwerWarnModel *model in porwers) {
        
        for (NSNumber *num in model.osList) {
            
            if ([num intValue] == [pid intValue]) {
                
                isGetPorwer = YES;
                porwer = [model.porwer floatValue];
                break;
                
            }
            
        }
        if (isGetPorwer) {
            break;
        }
        
    }
    
    
    if (isGetPorwer) {
        
        
        [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.devModel.uuid msgIds:@[@206] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
            
            for (NSArray *subArr in idDataList) {
                for (DataPointSeg *seg in subArr) {
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if ([obj isKindOfClass:[NSNumber class]]) {
                        
                        int battery = [obj intValue];
                        
                        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"battery:%d",battery]];
                        NSString *ukey = [NSString stringWithFormat:@"fcLowerBattrey_%@",self.devModel.uuid];
                        
                        
                        BOOL isAlwayrsShow = YES;
                        
                        NSDate *dat = [[NSUserDefaults standardUserDefaults] objectForKey:ukey];
                        
                        NSDateFormatter *__dateFormatter = [[NSDateFormatter alloc]init];
                        [__dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        
                        NSString *currentDats = [__dateFormatter stringFromDate:[NSDate date]];
                        NSString *lasterDats = [__dateFormatter stringFromDate:dat];
                        
                        if (!lasterDats) {
                            isAlwayrsShow = NO;
                        }else{
                            if (![lasterDats isEqualToString:currentDats]) {
                                isAlwayrsShow = NO;
                            }
                        }
                        
                        if (!isAlwayrsShow && battery<=porwer*100) {
                            
                            //__weak typeof(self) weakSelf = self;
                            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_LowPower"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                                
                                
                            } OKBlock:^{
                                
                            }];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:ukey];
                            
                        }
                        
                        if (battery > porwer*100) {
                            
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ukey];
                            
                        }
                    }
                }
            }
            
        } failure:^(RobotDataRequestErrorType type) {
            
            
            
        }];
        
    }
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
        self.shakeBtn.right = self.fullVoideBtn.left - 15;
        
        if ([CommonMethod isOutdoorDevForOS:self.devModel.pid]) {
            self.fullMicBtn.hidden = YES;
            self.fullVoideBtn.right = self.fullSnapBtn.left-15;
        }else{
            self.fullMicBtn.right = self.fullSnapBtn.left-15;
            self.fullVoideBtn.right = self.fullMicBtn.left-15;
        }
        
        [_fullScreenTopControlBar addSubview:self.fullMicBtn];
        [_fullScreenTopControlBar addSubview:self.fullVoideBtn];
        [_fullScreenTopControlBar addSubview:self.fullSnapBtn];
        [_fullScreenTopControlBar addSubview:self.shakeBtn];
        
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

-(UIButton *)shakeBtn
{
    if (!_shakeBtn) {
        _shakeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shakeBtn.frame = CGRectMake(0, 0, 50, 50);
        [_shakeBtn setImage:[UIImage imageNamed:@"icon_xunhuan_close"] forState:UIControlStateNormal];
        [_shakeBtn setImage:[UIImage imageNamed:@"icon_xunhuan_open"] forState:UIControlStateSelected];
        [_shakeBtn setImage:[UIImage imageNamed:@"icon_xunhuan_close_disable"] forState:UIControlStateDisabled];
        [_shakeBtn addTarget:self action:@selector(shakeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        if ([CommonMethod devBigTypeForOS:self.devModel.pid] != JFGDevBigType360) {
            _shakeBtn.frame = CGRectMake(0, 0, 0, 0);
            _shakeBtn.hidden = YES;
        }
    }
    return _shakeBtn;
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

-(UIButton *)reqHistoryBtn
{
    if (!_reqHistoryBtn) {
        _reqHistoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _reqHistoryBtn.frame = CGRectMake(0, self.videoBgView.bottom, self.videoBgView.width, 56);
        _reqHistoryBtn.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
        [_reqHistoryBtn setTitle:[JfgLanguage getLanTextStrByKey:@"History_video"] forState:UIControlStateNormal];
        [_reqHistoryBtn setTitleColor:[UIColor colorWithHexString:@"#cecece"] forState:UIControlStateDisabled];
        [_reqHistoryBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        _reqHistoryBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _reqHistoryBtn.hidden = YES;
        [_reqHistoryBtn addTarget:self action:@selector(reqHistoryAction) forControlEvents:UIControlEventTouchUpInside];
        [_reqHistoryBtn setBackgroundImage:[UIImage imageNamed:@"btn_cam_history"] forState:UIControlStateNormal];
    }
    return _reqHistoryBtn;
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

-(UIView *)handTipForHistory
{
    if (!_handTipForHistory) {
        
        _handTipForHistory = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _handTipForHistory.backgroundColor = [UIColor colorWithRed:8/255.0 green:8/255.0 blue:8/255.0 alpha:0.6];
    
        UIView *bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 146)];
        bgview.top = self.videoBgView.bottom+64;
        bgview.backgroundColor = [UIColor clearColor];
        bgview.tag = 12879;
        
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_hand"]];
        imageView.top = 0;
        imageView.x = bgview.width*0.5;
        [bgview addSubview:imageView];
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom+7, self.view.width, 18)];
        tLabel.font = [UIFont systemFontOfSize:16];
        tLabel.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        tLabel.textAlignment = NSTextAlignmentCenter;
        tLabel.text = [JfgLanguage getLanTextStrByKey:@"Sliding_Timeline"];
        [bgview addSubview:tLabel];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 100, 38);
        btn.top = tLabel.bottom + 26;
        btn.x = self.view.width*0.5;
        [btn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = 19;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn addTarget:self action:@selector(handTipDone) forControlEvents:UIControlEventTouchUpInside];
        [bgview addSubview:btn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handTipDone)];
        [_handTipForHistory addGestureRecognizer:tap];
        [_handTipForHistory addSubview:bgview];
        
    }
    return _handTipForHistory;
}

-(void)handTipDone
{
    [self.handTipForHistory removeFromSuperview];
    [self showHistoryVideoTip];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristhistoryVideoKey];
}

-(UIView *)rpBgView
{
    if (!_rpBgView) {
        _rpBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 324*0.5, 22)];
        _rpBgView.backgroundColor = [UIColor clearColor];
        _rpBgView.right = self.videoBgView.width-20;
        _rpBgView.bottom = self.videoBgView.height - 47;
        _rpBgView.hidden = YES;
        BOOL versionSupport = YES;

        if (rpVersion && ![rpVersion isEqualToString:@""]) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"分辨率调节版本号：%@",rpVersion]];
            int rpv = [[rpVersion stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
            int supportV = 1001008;
            if ([self.devModel.pid isEqualToString:@"18"]) {
                supportV = 3001011;
            }
            if (rpv >= supportV) {
                versionSupport = YES;
            }else{
                versionSupport = NO;
            }
            
        }
        
        //允许显示的设备才加载这些视图
        if ([DevPropertyManager isSupportRPSwitchForPid:self.devModel.pid] && versionSupport) {
        
            NSArray *titleArr = @[[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"],[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_SD"],[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Auto"]];
            [titleArr enumerateObjectsUsingBlock:^(NSString *_title, NSUInteger idx, BOOL * _Nonnull stop) {
                
                UIButton *btn;
                
                CGRect rect = CGRectMake(2*56, 0, 44, 22);
                
                if (idx == 2) {
                    
                    rect.size.width = 50;
                    btn = [[CommentFrameButton alloc]initWithFrame:rect titleFrame:CGRectMake(19, 0, 27, 22) imageRect:CGRectMake(7, 6.5, 6, 9)];
                    [btn setImage:[UIImage imageNamed:@"icon_rate_arrow"] forState:UIControlStateNormal];
                    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
                    
                }else{
                    
                    btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = rect;
                    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
                    btn.alpha = 0;
                    
                }
                [btn setTitle:_title forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:12];
                btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 3;
                btn.tag = RPBtnTagBase+idx;
                [btn addTarget:self action:@selector(setRpAction:) forControlEvents:UIControlEventTouchUpInside];
                [_rpBgView addSubview:btn];
                
            }];
        }
    }
    return _rpBgView;
}

//设置分辨率按钮文字显示
//type 模式   2高清 1标清 0自动
-(void)resetRPBtnTitleForType:(int)type
{
    UIButton *leftBtn2 = [self.rpBgView viewWithTag:RPBtnTagBase+2];
    UIButton *leftBtn1 = [self.rpBgView viewWithTag:RPBtnTagBase+1];
    UIButton *leftBtn = [self.rpBgView viewWithTag:RPBtnTagBase];
    
    if (!leftBtn) {
        return;
    }
    
    if (type == 0) {
        
        [leftBtn2 setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Auto"] forState:UIControlStateNormal];
        [leftBtn1 setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_SD"] forState:UIControlStateNormal];
        [leftBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"] forState:UIControlStateNormal];
        
    }else if (type == 1){
        
        [leftBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Auto"] forState:UIControlStateNormal];
        [leftBtn2 setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_SD"] forState:UIControlStateNormal];
        [leftBtn1 setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"] forState:UIControlStateNormal];
        
    }else if (type == 2){
        
        [leftBtn1 setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Auto"] forState:UIControlStateNormal];
        [leftBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_SD"] forState:UIControlStateNormal];
        [leftBtn2 setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"] forState:UIControlStateNormal];
    }
}


//设置分辨率按钮点击
-(void)setRpAction:(UIButton *)sender
{
    //防止刚点按就消失了
    if (windowMode != videoPlayModeSmallWindow) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFullVideoPlayBar) object:nil];
        [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:5];
        
    }
    
    UIButton *leftBtn = [self.rpBgView viewWithTag:RPBtnTagBase+1];
    UIButton *leftBtn2 = [self.rpBgView viewWithTag:RPBtnTagBase];
    if (sender.tag == RPBtnTagBase+2) {
        //点按伸缩图标
        if (leftBtn.left == sender.left) {
            [self closeViewModelAnimation:NO];
            //需要展开
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                leftBtn.alpha = leftBtn2.alpha = 1;
                leftBtn2.left = 0;
                leftBtn.left = 56;
                
            } completion:^(BOOL finished) {
                
            }];

        }else{
            
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                
                leftBtn2.left = sender.left;
                leftBtn.left = sender.left;
                leftBtn.alpha = leftBtn2.alpha = 0;
                
            } completion:^(BOOL finished) {
                
            }];
            
        }
        
    }else{
        
        UIButton *rightBtn = [self.rpBgView viewWithTag:RPBtnTagBase+2];
        NSString *title = sender.titleLabel.text;
        
        int type = 0;
        if ([title isEqualToString:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"]]) {
            type = 2;
        }else if ([title isEqualToString:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_SD"]]){
            type = 1;
        }else if ([title isEqualToString:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_Auto"]]){
            type = 0;
        }
        
        [self resetRPBtnTitleForType:type];
        
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            leftBtn2.left = rightBtn.left;
            leftBtn.left = rightBtn.left;
            leftBtn.alpha = leftBtn2.alpha = 0;
            
        } completion:^(BOOL finished) {
            
        }];
        
        
        if (devMac && ![devMac isEqualToString:@""] && devIp && ![devIp isEqualToString:@""]) {
            
            //udp请求(发三次，防止丢包)
            [JFGSDK udpSetBitrateForCid:self.devModel.uuid mac:devMac ip:devIp bitrate:type];
            [JFGSDK udpSetBitrateForCid:self.devModel.uuid mac:devMac ip:devIp bitrate:type];
            [JFGSDK udpSetBitrateForCid:self.devModel.uuid mac:devMac ip:devIp bitrate:type];
            
        }else{
            
            DataPointSeg *seg = [[DataPointSeg alloc]init];
            seg.value = [MPMessagePackWriter writeObject:[NSNumber numberWithInt:type] error:nil];
            seg.msgId = 513;
            seg.version = 0;
            [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.devModel.uuid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                
                for (DataPointIDVerRetSeg *_seg in dataList) {
                    NSLog(@"setRPResult:%d",_seg.ret);
                }
                
            } failure:^(RobotDataRequestErrorType type) {
                
            }];
            
        }
        
        
    }
}

-(void)hideRpLeftBtn
{
    UIButton *leftBtn2 = [self.rpBgView viewWithTag:RPBtnTagBase+2];
    UIButton *leftBtn1 = [self.rpBgView viewWithTag:RPBtnTagBase+1];
    UIButton *leftBtn = [self.rpBgView viewWithTag:RPBtnTagBase];
    if (leftBtn2 && leftBtn1 && leftBtn && leftBtn2.left != leftBtn.left) {
        leftBtn.left = leftBtn1.left = leftBtn2.left;
        leftBtn.alpha = leftBtn1.alpha = 0;
    }
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
        [self switchVideoViewHangMode];
        
    }else{
        
        self.angleType = angleType;
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"angleChnaed:%d",angleType]];
        [self switchVideoViewHangMode];
//        DataPointSeg * seg = [[DataPointSeg alloc]init];
//        NSError * error = nil;
//        seg.msgId = dpMsgCamera_Angle;
//        seg.value = [MPMessagePackWriter writeObject:[NSString stringWithFormat:@"%d",angleType] error:&error];
//        NSArray * dps = @[seg];
//        
//        __weak typeof(self) weakSelf = self;
//        [[dataPointMsg shared] setdpDataWithCid:self.cid dps:dps success:^(NSMutableDictionary *dic) {
//            
//            weakSelf.angleType = [[dic objectForKey:dpMsgCameraAngleKey] intValue];
//            [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
//            
//            
//        } failed:^(RobotDataRequestErrorType error) {
//            
//        }];
    }
}
#pragma mark- 引导tip
//角度视图Tip
-(void)showAngleTip
{
    if (!angleV) {
        angleV = [[AngleView alloc]initWithFrame:CGRectMake(0, 0, self.videoBgView.width, self.videoBgView.height)];
        [self.videoBgView addSubview:angleV];
        [angleV.cancelButton addTarget:self action:@selector(cancelAngleTip) forControlEvents:UIControlEventTouchUpInside];
        [angleV.setAngleButton addTarget:self action:@selector(gotoSetAngle) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.videoBgView bringSubviewToFront:angleV];
    }
}

-(void)cancelAngleTip
{
    if (angleV) {
        [angleV removeFromSuperview];
        angleV = nil;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristIntoAngleVideoViewKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self startVideoActionPrepare];
}

-(void)gotoSetAngle
{
    SetAngleVC *angleVC = [[SetAngleVC alloc] init];
    angleVC.angleDelegate = self;
    angleVC.oldAngleType = self.angleType;
    if (angleV) {
        [angleV removeFromSuperview];
        angleV = nil;
    }
    [self.navigationController pushViewController:angleVC animated:YES];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fristIntoAngleVideoViewKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//显示安全防护引导tip
-(void)showSafeTip
{
    if (isShared == NO && self.isShow) {
        [self showTipWithFrame:CGRectMake(5, 64+self.videoBgView.height-40-35+4, 95, 35) triangleLeft:15 content:[JfgLanguage getLanTextStrByKey:@"SECURE"]];
        showTip = YES;
    }
    
}

-(void)showHistoryVideoTip
{
    if (!showTip) {
        [self showTipWithFrame:CGRectMake(self.view.width - 12 - 95, 64+self.videoBgView.height - 25, 95, 35) triangleLeft:75 content:[JfgLanguage getLanTextStrByKey:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_BackLiveTips"]]];
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

-(NSLock *)renderLock
{
    if (!_renderLock) {
        _renderLock = [[NSLock alloc]init];
    }
    return _renderLock;
}

-(TelephonyManager *)phonyManager
{
    if (!_phonyManager) {
        _phonyManager = [[TelephonyManager alloc]init];
        _phonyManager.delegate = self;
    }
    return _phonyManager;
}

-(UIView *)viewModeBgView
{
    if (!_viewModeBgView) {
        _viewModeBgView = [[UIView alloc]initWithFrame:CGRectMake(18, self.rpBgView.top, 174, 30)];
        _viewModeBgView.backgroundColor = [UIColor clearColor];
        _viewModeBgView.hidden = YES;
        _viewModeBgView.y = self.rpBgView.y;
        
        if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360) {
            
            NSArray *imagesNamal = @[@"icon_view_switch",@"icon_circular",@"icon_column",@"icon_four"];
            NSArray *imagesSelected = @[@"",@"icon_circular_hl",@"icon_column_hl",@"icon_four_hl"];
            
            for (int i=0; i<4; i++) {
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, 30, 30);
                btn.backgroundColor = [UIColor clearColor];
                btn.tag = ViewModeBtnTagBase+i;
                
                [btn setImage:[UIImage imageNamed:imagesNamal[i]] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:imagesSelected[i]] forState:UIControlStateSelected];
                if (i==0) {
                    [btn setImage:[UIImage imageNamed:@"icon_view_switch_disable@"] forState:UIControlStateDisabled];
                    [btn setImage:[UIImage imageNamed:@"icon_view_switch_press"] forState:UIControlStateHighlighted];
                    [btn addTarget:self action:@selector(openOrCloseViewMode:) forControlEvents:UIControlEventTouchUpInside];
                    btn.selected = NO;
                    btn.alpha = 1;
                    self.viewModeSwitchBtn = btn;
                }else{
                   
                    btn.alpha = 0;
                    [btn addTarget:self action:@selector(viewModeSwitchForBtn:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                
                if (defaultDispalyMode == SFM_Normal && i==1) {
                    btn.selected = YES;
                }else if (defaultDispalyMode == SFM_Cylinder && i==2){
                    btn.selected = YES;
                }else if (defaultDispalyMode == SFM_Quad && i==3){
                    btn.selected = YES;
                }
                
                [_viewModeBgView addSubview:btn];
                
            }
            
            if (self.angleType == 1) {
                UIButton *btn = [_viewModeBgView viewWithTag:ViewModeBtnTagBase+1];
                UIButton *btn1 = [_viewModeBgView viewWithTag:ViewModeBtnTagBase+2];
                UIButton *btn2 = [_viewModeBgView viewWithTag:ViewModeBtnTagBase+3];
                btn.selected = YES;
                btn1.selected = NO;
                btn2.selected = NO;
            }
            
            [self addKvoForRPBgView];
            
        }else{
            
            _viewModeBgView.frame = CGRectMake(0, 0, 0, 0);
            _viewModeBgView.backgroundColor = [UIColor clearColor];
            
        }
        
        
    }
    return _viewModeBgView;
}

-(void)openViewModel
{
    [self hideRpLeftBtn];
    
    UIButton *btn  = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
    UIButton *btn1 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+1];
    UIButton *btn2 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+2];
    UIButton *btn3 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+3];
    if (btn1.alpha == 0) {
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            btn1.left = btn.right+15;
            btn2.left = btn1.right+15;
            btn3.left = btn2.right+15;
            btn1.alpha = btn2.alpha = btn3.alpha = 1;
            
        } completion:^(BOOL finished) {
            
        }];
        btn.selected = YES;
    }
}

-(void)closeViewModelAnimation:(BOOL)animation
{
    UIButton *btn = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase];
    UIButton *btn1 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+1];
    UIButton *btn2 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+2];
    UIButton *btn3 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+3];
    
    if (btn && btn1 && btn2 && btn3) {
        if (btn3.alpha == 1) {
            
            if (animation) {
                [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    
                    btn1.left = btn.left;
                    btn2.left = btn.left;
                    btn3.left = btn.left;
                    btn1.alpha = btn2.alpha = btn3.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    
                }];
            }else{
                
                btn1.left = btn.left;
                btn2.left = btn.left;
                btn3.left = btn.left;
                btn1.alpha = btn2.alpha = btn3.alpha = 0;
                
            }
            btn.selected = NO;
            
        }
    }
    
    
    
}

-(void)addKvoForRPBgView
{
    __weak typeof(self) weakSelf = self;
    [self.KVOController observe:self.rpBgView keyPath:@"hidden" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        if (!isLiveVideo && weakSelf.rpBgView.hidden) {
            
        }else{
            weakSelf.viewModeBgView.hidden = weakSelf.rpBgView.hidden;
        }
    }];
    
}

#pragma mark- 视图模式切换事件
-(void)viewModeSwitchForBtn:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    
    if (self.angleType == 1) {

        if (windowMode == videoPlayModeSmallWindow) {
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"SWITCH_VIEW_POP"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                
                BOOL isAPModel = [CommonMethod isAPModelCurrentNetForCid:weakSelf.devModel.uuid pid:weakSelf.devModel.pid];
                if (isAPModel) {
                    
                    weakSelf.angleType = 0;
                    [weakSelf switchVideoViewHangMode];
                    [weakSelf hudViewForText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                    
                }else{
                    
                    DataPointSeg *seg = [[DataPointSeg alloc]init];
                    seg.msgId = 509;
                    seg.value = [MPMessagePackWriter writeObject:@"0" error:nil];
                    //509
                    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.devModel.uuid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                        
                        for (DataPointIDVerRetSeg *_seg in dataList) {
                            
                            if (_seg.ret == 0) {
                                
                                weakSelf.angleType = 0;
                                [weakSelf switchVideoViewHangMode];
                                [weakSelf hudViewForText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                                
                            }
                        }
                        
                    } failure:^(RobotDataRequestErrorType type) {
                        
                    }];
                }
                
                
            }];
            
        }else{
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertForTransformRotateWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"SWITCH_VIEW_POP"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                
                BOOL isAPModel = [CommonMethod isAPModelCurrentNetForCid:weakSelf.devModel.uuid pid:weakSelf.devModel.pid];
                if (isAPModel) {
                    
                    weakSelf.angleType = 0;
                    [weakSelf switchVideoViewHangMode];
                    [weakSelf hudViewForText:@"SCENE_SAVED"];
                    
                }else{
                    
                    DataPointSeg *seg = [[DataPointSeg alloc]init];
                    seg.msgId = 509;
                    seg.value = [MPMessagePackWriter writeObject:[NSNumber numberWithInt:0] error:nil];
                    //509
                    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.devModel.uuid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                        
                        for (DataPointIDVerRetSeg *_seg in dataList) {
                            
                            if (_seg.ret == 0) {
                                
                                weakSelf.angleType = 0;
                                [weakSelf switchVideoViewHangMode];
                                [weakSelf hudViewForText:@"SCENE_SAVED"];
                                
                            }
                        }
                        
                    } failure:^(RobotDataRequestErrorType type) {
                        
                    }];
                }
                
                
            }];
        }
        return;
    }
    
    UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    PanoramicIosViewRS * _remoteView = nil;
    if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
        _remoteView = (PanoramicIosViewRS *)remoteView;
    }
    if (!_remoteView) {
        return;
    }
    if (sender.tag == ViewModeBtnTagBase+1) {
        //圆※
        [_remoteView setDisplayMode:SFM_Normal];
        defaultDispalyMode = SFM_Normal;
        self.shakeBtn.enabled = YES;
        [self closeViewModelAnimation:YES];
    }else if (sender.tag == ViewModeBtnTagBase+2){
        //圆柱体
        [_remoteView setDisplayMode:SFM_Cylinder];
        defaultDispalyMode = SFM_Cylinder;
        self.shakeBtn.enabled = NO;
        [self closeViewModelAnimation:YES];
    }else if (sender.tag == ViewModeBtnTagBase+3){
        //四分
        [_remoteView setDisplayMode:SFM_Quad];
        defaultDispalyMode = SFM_Quad;
        self.shakeBtn.enabled = NO;
        [self closeViewModelAnimation:YES];
    }
    UIButton *btn1 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+1];
    UIButton *btn2 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+2];
    UIButton *btn3 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+3];
    btn3.selected = NO;
    btn2.selected = NO;
    btn1.selected = NO;
    sender.selected = YES;
}

//设置默认显示模式为圆形
-(void)defaultViewMode
{
    UIButton *btn1 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+1];
    UIButton *btn2 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+2];
    UIButton *btn3 = [self.viewModeBgView viewWithTag:ViewModeBtnTagBase+3];
    btn1.selected = YES;
    btn2.selected = NO;
    btn3.selected = NO;
    UIView *remoteView = [self.videoPlayBgScrollerView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
        PanoramicIosViewRS * _remoteView = (PanoramicIosViewRS *)remoteView;
        
        [_remoteView setDisplayMode:SFM_Normal];
        defaultDispalyMode = SFM_Normal;
    }
}

-(void)switchVideoViewHangMode
{
    if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360) {
        [self defaultViewMode];
    }
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
    }else if ([remoteView isKindOfClass:[PanoramicIosViewRS class]]){
        PanoramicIosViewRS * _remoteView = (PanoramicIosViewRS *)remoteView;
        if (self.angleType == 1) {
            //挂壁
            [_remoteView setMountMode:MOUNT_WALL];
            [self defaultViewMode];
        }else{
            //吊顶
            [_remoteView setMountMode:MOUNT_TOP];
        }
    }
}

-(void)openOrCloseViewMode:(UIButton *)sender
{
    if (windowMode == videoPlayModeFullScreen) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFullVideoPlayBar) object:nil];
        [self performSelector:@selector(hideFullVideoPlayBar) withObject:nil afterDelay:5];
    }
    if (sender.selected) {
        [self closeViewModelAnimation:YES];
        sender.selected = NO;
    }else{
        [self openViewModel];
        sender.selected = YES;
    }
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
