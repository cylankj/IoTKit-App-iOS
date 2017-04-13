//
//  VideoPlayFor720ViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/11.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "VideoPlayFor720ViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+FLExtension.h"
#import "DeviceSettingVC.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import <POP.h>
#import <JFGSDK/CylanJFGSDK.h>
#import "CommonMethod.h"
#import "JfgLanguage.h"
#import <KVOController.h>
#import "JfgMsgDefine.h"
#import "JFGTakePhotoButton.h"
#import "UIButton+Addition.h"
#import "JFGTimepieceView.h"
#import "NSTimer+FLExtension.h"
#import "UIAlertView+FLExtension.h"
#import "JFGShortVideoRecordAnimation.h"
#import "Pano720PhotoVC.h"
#import <JFGSDK/JFGSDKSock.h>
#import <JFGSDK/JFGSDK.h>
#import "ProgressHUD.h"
#import "JFGMsgForwardDataDownload.h"
#import <commoncrypto/commondigest.h>
#import "LoginManager.h"

#define VIEW_REMOTERENDE_VIEW_TAG  10023

//录像状态
typedef NS_ENUM(NSInteger,VideoRecordStatue) {
    VideoRecordStatueNone,//没有录像
    VideoRecordStatue8SRecording,//短视频录制
    VideoRecordStatueLongRecording,//长视频录制
};

@interface VideoPlayFor720ViewController ()<JFGTakePhotoTouchActionDelegate,JFGSDKSockCBDelegate,JFGSDKCallbackDelegate,JFGMsgForwardDataDownloadDelegate>
{
    videoPlayState playState;//视频播放状态
    VideoRecordStatue recordState;//录像状态
    int batteryRl;//设备电池电量
    int timeoutRequestCount;//连接超时计算
    BOOL isLowSpeed;//是否速率低于5k/s
    BOOL isWifi;//设备是否wifi在线
    BOOL isCarameMode;//是否是拍照模式
    BOOL isShooting;//是否视频拍摄中
    BOOL isPrower;//充电中
    NSTimer *shortVideoTimer;//短视频录制计时器
    int shortVideoTimeCount;//短视频时间记录
    NSTimer *fpingTimer;
    JFGMsgForwardDataDownload *downloadManager;
}
@property (nonatomic,strong)UIButton *settingBtn;

//底部一系类控件
@property (nonatomic,strong)UIView *bottomBgView;
@property (nonatomic,strong)UIButton *cameraModeBtn;
@property (nonatomic,strong)UIButton *videoModeBtn;
@property (nonatomic,strong)UIButton *albumsBtn;
@property (nonatomic,strong)JFGTakePhotoButton *takePhotoBtn;

//更多按钮相关
@property (nonatomic,strong)UIButton *moreBtn;
@property (nonatomic,strong)UIButton *micBtn;
@property (nonatomic,strong)UIButton *voiceBtn;

@property (nonatomic,strong)UIView *speedModeBgView;
@property (nonatomic,strong)UIButton *speedModeLeftBtn;
@property (nonatomic,strong)UIButton *speedModeRightBtn;
@property (nonatomic,strong)UILabel *speedModeLabel;

//底层视图
@property (nonatomic,strong)UIImageView *videoBgImageView;
@property (nonatomic,strong)UIImageView *loadingImageView;

//最上方异常提示视图
@property (nonatomic,strong)UIView *singularTipBgView;
@property (nonatomic,strong)UIImageView *singularTipIcon;
@property (nonatomic,strong)UIButton *singularTipCancelBtn;
@property (nonatomic,strong)UILabel *singularTipLabel;

//最上方设备状态显示视图
@property (nonatomic,strong)UIView *statusShowBgView;
@property (nonatomic,strong)UIImageView *statusNetIcon;
@property (nonatomic,strong)UILabel *statusNetLabel;
@property (nonatomic,strong)UIImageView *statusBatteryIcon;
@property (nonatomic,strong)UILabel *statusBatteryLabel;

//流量显示
@property (nonatomic,strong)UILabel *rateLabel;
//长视频录像时间显示控件
@property (nonatomic,strong)JFGTimepieceView *timepiceView;
//短视频时间显示
@property (nonatomic,strong)UILabel *shortVideoTimeLabel;

@property (nonatomic,strong)UIView *againBgView;

@property (nonatomic,strong)JFGShortVideoRecordAnimation *recordAnimationView;

@property (nonatomic,strong)UIActivityIndicatorView *takePhotoLoadingView;

@end

@implementation VideoPlayFor720ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self btnDisenableStatue];//设备状态显示
    
    [JFGSDK addDelegate:self];
    [[JFGSDKSock sharedClient] addDelegate:self];
    
    downloadManager = [[JFGMsgForwardDataDownload alloc]init];
    downloadManager.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self workNetDecide];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startFping];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopVideoPlay];
    [self stopFping];
    [self removeVideoDelegate];
    if ([JFGSDKSock sharedClient].isConnected == NO) {
        [[JFGSDKSock sharedClient] disconnect];
    }
}

//网络状态判断
-(void)workNetDecide
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    
    if (isAP) {
        
        [self showStatusTipForWiFiMode:NO batteryCapacity:batteryRl];
        if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
            [self addVideoNotification];
            [self startLiveVideo];
        }
        
    }else{
        
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            
            if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline && [JFGSDK currentNetworkStatus] != JFGNetTypeWifi) {
                
                //客户端移动网络在线
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap1_Firmware_DataTips"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"], nil];
                [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                    
                    if (buttonIndex == 1) {
                        if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                            [self addVideoNotification];
                            [self startLiveVideo];
                        }
                    }else{
                        //
                    }
                    
                } otherDelegate:nil];
                
            }else{
                //客户端wifi连接
                [self showStatusTipForWiFiMode:YES batteryCapacity:self.devModel.Battery];
                if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                    [self addVideoNotification];
                    [self startLiveVideo];
                }
                
            }
            [self reqForBattaryAndSDCard];
            
        }else{
            //离线
            //[self showTipView:[JfgLanguage getLanTextStrByKey:@"Tips_Device_TimeoutRetry"]];
            if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                [self addVideoNotification];
                [self startLiveVideo];
            }
        }
    }
    
}


#pragma mark- fping
-(void)startFping
{
    if (fpingTimer == nil || !fpingTimer.isValid) {
        
        fpingTimer = [NSTimer bk_scheduledTimerWithTimeInterval:3 block:^(NSTimer *timer) {
            
            [JFGSDK fping:@"255.255.255.255"];
            
        } repeats:YES];
        
    }
}

-(void)stopFping
{
    if (fpingTimer && fpingTimer.isValid) {
        [fpingTimer invalidate];
    }
}


#pragma mark- downloadDelegate
-(void)downloadFinishedForCid:(NSString *)cid fileName:(NSString *)fileName filePath:(NSString *)filePath
{
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    [self.albumsBtn setImage:image forState:UIControlStateNormal];
}

-(void)downloadFailedForCid:(NSString *)cid fileName:(NSString *)fileName errorType:(JFGMsgFwDlFailedType)errorType
{
    
}

#pragma mark- JFGSDKDelegate
-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([ask.cid isEqualToString:self.devModel.uuid]) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"ip:%@ cid:%@",ask.address,ask.cid]];
        [[JFGSDKSock sharedClient] connectWithIp:ask.address port:10008 autoReconnect:NO];
    }
}


#pragma mark- JFGSDKSockDelegate
-(void)jfgSockConnect
{
    NSLog(@"sock Connect");
    [self stopFping];
    [self reqForBattaryAndSDCard];
}

-(void)jfgSockDisconnect
{
    NSLog(@"sock Disconnect");
    //[self startFping];
}

//获取电池与sd卡状态
-(void)reqForBattaryAndSDCard
{
    //sd卡状态
    DataPointSeg *seg1 = [DataPointSeg new];
    seg1.msgId = 204;
    seg1.value = [NSData data];
    seg1.version = 0;
    
    //电池状态
    DataPointSeg *seg2 = [DataPointSeg new];
    seg2.msgId = 206;
    seg2.value = [NSData data];
    seg2.version = 0;
    
    DataPointSeg *seg3 = [DataPointSeg new];
    seg3.msgId = dpMsgBase_Power;
    seg3.value = [NSData data];
    seg3.version = 0;
    
    if ([JFGSDKSock sharedClient].isConnected) {
        
        [[JFGSDKSock sharedClient] sendDPDataMsgForSockWithPeer:self.devModel.uuid dpMsgIDs:@[seg1,seg2,seg3]];
        
    }else{
        
        [JFGSDK sendDPDataMsgForSockWithPeer:self.devModel.uuid dpMsgIDs:@[seg1,seg2,seg3]];
    }
    
}


//视频录制情况
-(void)videoRecordstatus
{
     if ([JFGSDKSock sharedClient].isConnected) {
        [[JFGSDKSock sharedClient] sendMsgForSockWithDst:@[self.devModel.uuid] isAck:YES fileType:13 msg:[NSData data]];
     }else{
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:13 msg:[NSData data]];
     }
}


#pragma mark- 20006
-(void)jfgMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type msgData:(NSData *)msgData
{
    [self jfgMsgRobotForwardDataV2AckForSockWithMsgID:msgID mSeq:mSeq cid:cid type:type msgData:msgData];
}

-(void)jfgMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type msgData:(NSData *)msgData
{
    if (type == 8) {
        //拍照请求回调
        [self carameDataDeal:msgData];
    }else if (type == 10){
        //录制视频请求回调
        [self videoDataDeal:msgData];
    }else if (type == 14){
        //视频录制情况
        [self videoRecordDeal:msgData];
    }
}


#pragma mark- 20006 dp
-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type dpMsgArr:(NSArray *)dpMsgArr
{
    [self jfgDPMsgRobotForwardDataV2AckForSockWithMsgID:msgID mSeq:mSeq cid:cid type:type dpMsgArr:dpMsgArr];
}

-(void)jfgDPMsgRobotForwardDataV2AckForSockWithMsgID:(NSString *)msgID mSeq:(uint64_t)mSeq cid:(NSString *)cid type:(int)type dpMsgArr:(NSArray *)dpMsgArr
{
    for (DataPointSeg *seg in dpMsgArr) {
        
        NSLog(@"%@",seg.value);
        if (seg.msgId == 204) {
            id obj = [MPMessagePackReader readData:seg.value error:nil];
            NSLog(@"%@",obj);
        }else if (seg.msgId == 206 || seg.msgId == dpMsgBase_Power){
            [self baratyDeal:seg];
        }
    }
}


#pragma mark- 720数据处理
-(void)baratyDeal:(DataPointSeg *)seg
{
    if (seg.msgId == 206){
        
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if ([obj isKindOfClass:[NSNumber class]]) {
            if (isPrower) {
                 [self showStatusTipForWiFiMode:isWifi batteryCapacity:200];
            }else{
                 [self showStatusTipForWiFiMode:isWifi batteryCapacity:[obj intValue]];
            }
            [self showStatusTipForWiFiMode:isWifi batteryCapacity:[obj intValue]];
            NSLog(@"barrty:%d",[obj intValue]);
        }
        
    }else if (seg.msgId == dpMsgBase_Power){
        
        //充电中
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if (seg.msgId == dpMsgBase_Power){
            if ([obj isKindOfClass:[NSNumber class]]) {
                BOOL isPower = [obj boolValue];
                isPrower = isPower;
                if (isPower) {
                    [self showStatusTipForWiFiMode:isWifi batteryCapacity:200];
                }
            }
        }
    }
}

-(void)videoRecordDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = obj;
        if (sourceArr.count >= 3) {
            
            @try {
                /*
                 int，     ret       错误码
                 int，     secends   视频录制的时长,单位秒
                 int,      videoType 特征值定义： videoTypeShort = 1 8s短视频； videoTypeLong = 2 长视频；
                 */
                int ret = [sourceArr[0] intValue];
                int secouds = [sourceArr[1] intValue];
                int videoType = [sourceArr[2] intValue];
                if (videoType == -1) {
                    //没有录像
                    recordState = VideoRecordStatueNone;
                    
                }else if(videoType == 1){
                    //8s短视频
                    recordState = VideoRecordStatue8SRecording;
                    
                }else if (videoType == 2){
                    //长视频
                    recordState = VideoRecordStatueLongRecording;
                }
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            
            
        }
        
    }
}

-(void)carameDataDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *arr = obj;
        /*
         int，     ret       错误码
         string，  fileName  文件名， 命名格式[timestamp].jpg 或 [timestamp]_[secends].avi， timestamp是文件生成时间的unix时间戳，secends是视频录制的时长,单位秒。根据后缀区分是图片或视频。
         int，     fileSize  文件大小, bit。
         string，  md5  文件的md5值
         */
        int ret = 0;
        if (arr.count>=4 ) {
            
            id obj1 = arr[0];
            id obj2 = arr[1];
            id obj3 = arr[2];
            id obj4 = arr[3];
            if ([obj1 isKindOfClass:[NSNumber class]]) {
                ret = [obj1 intValue];
            }
            if (ret == 0) {
                
                NSString *fileName = obj2;
                NSString *md5 = obj4;
                
                int fileSize = 0;
                if ([obj3 isKindOfClass:[NSNumber class]]) {
                    fileSize = [obj3 intValue];
                }
            
                if (fileSize > 0) {
                     [downloadManager downloadMsgForwardDataForCid:self.devModel.uuid fileName:fileName md5:md5 fileSize:fileSize];
                }
                NSLog(@"拍照成功fileName:%@",fileName);
                [ProgressHUD showText:@"拍照成功"];
            }else{
                [ProgressHUD showText:@"拍照失败,请检查SD卡"];
                NSLog(@"拍照失败");
            }
            
        }
        
        
    }
}


-(void)videoDataDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSNumber class]]) {
        int ret = [obj intValue];
        if (ret == 0) {
            NSLog(@"录像成功");
            //[ProgressHUD showText:@"录像成功"];
            if (recordState == VideoRecordStatue8SRecording) {
                [self btnStatueForShortVideoWithRemainSe:8];
            }else if (recordState == VideoRecordStatueLongRecording){
                [self btnStatueForLongVideoForSecounds:0];
            }
            
        }else{
            recordState = VideoRecordStatueNone;
            NSLog(@"录像失败");
            [self stopVideoViewRefresh];
            self.takePhotoBtn.selected = NO;
            [ProgressHUD showText:@"录像失败,请检查SD卡"];
        }
    }
}

-(void)initView
{
    if (self.devModel.alias && ![self.devModel.alias isEqualToString:@""]) {
        self.titleLabel.text = self.devModel.alias;
    }else{
        self.titleLabel.text = self.devModel.uuid;
    }
    [self.topBarBgView addSubview:self.settingBtn];
    
    [self.view addSubview:self.bottomBgView];
    [self.bottomBgView addSubview:self.cameraModeBtn];
    [self.bottomBgView addSubview:self.videoModeBtn];
    [self.bottomBgView addSubview:self.albumsBtn];
    [self.bottomBgView addSubview:self.takePhotoBtn];
    [self.bottomBgView addSubview:self.moreBtn];
    [self.bottomBgView addSubview:self.timepiceView];
    [self.bottomBgView addSubview:self.shortVideoTimeLabel];
    [self.bottomBgView addSubview:self.recordAnimationView];
    
    [self.view addSubview:self.videoBgImageView];
    [self.videoBgImageView addSubview:self.loadingImageView];
    [self.videoBgImageView addSubview:self.rateLabel];
    [self.videoBgImageView addSubview:self.speedModeBgView];
    [self.videoBgImageView addSubview:self.voiceBtn];
    [self.videoBgImageView addSubview:self.micBtn];
    //self.videoBgImageView.backgroundColor = [UIColor greenColor];
    
}



-(void)initData
{
    batteryRl = self.devModel.Battery;
    timeoutRequestCount = 0;
    isCarameMode = YES;//初始化进入，默认拍照模式
    playState = videoPlayStatePause;
    recordState = VideoRecordStatueNone;
}


#pragma mark- 视频播放
-(void)startLiveVideo
{
    if (playState == videoPlayStatePlaying) {
        return;
    }
    playState = videoPlayStatePlayPreparing;
    
    [self startLodingAnimation];
    /*!
     *  开始视频直播 获取视频播放视图
     *  可以通过回调#jfgRTCPNotifyBitRate:videoRecved:frameRate:timesTamp: 查看视频加载情况
     长时间接收视频数据为0，则为网络状况差或者超时。
     */
    
    //isLiveVideo = YES;
    [CylanJFGSDK connectCamera:self.devModel.uuid];
    self.rateLabel.hidden = NO;
}


-(void)stopVideoPlay
{
    [CylanJFGSDK stopRenderView:NO withCid:self.devModel.uuid];
    if (self.devModel.uuid) {
        [CylanJFGSDK disconnectVideo:self.devModel.uuid];
    }else{
        [CylanJFGSDK disconnectVideo:@""];
    }
    UIView *remoteView = [self.videoBgImageView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
    if (remoteView) {
        
        if ([remoteView isKindOfClass:[Panoramic720IosView class]]) {
            
            Panoramic720IosView *rvc = (Panoramic720IosView *)remoteView;
            [rvc stopRender];
        }
        [remoteView removeFromSuperview];
        remoteView = nil;
        [JFGSDK appendStringToLogFile:@"remoteRemoveFromSuperView"];
    }
    playState = videoPlayStatePause;
    [self stopLoadingAnimation];
    //[self stopTimeoutRequest];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark- 添加代理
//视频播放相关代理
-(void)addVideoNotification
{
    //移除一次，防止重复添加
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    
    
    //视频直播相关代理
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onRecvDisconnectForRemote:) name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotifyResolution:) name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotificatyRTCP:) name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)removeVideoDelegate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
}

-(void)didEnterBackground
{
    [self viewDidDisappear:YES];
}

#pragma mark- 视频直播代理
-(void)onNotifyResolution:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSLog(@"NofityResolution");
    
    if (dict) {
        
        NSLog(@"NofityResolution2");
        int width = [[dict objectForKey:@"width"] intValue];
        int height = [[dict objectForKey:@"height"] intValue];
        NSLog(@"originSize:%@",NSStringFromCGSize(CGSizeMake(width, height)));
        CGSize size = CGSizeMake(width, height);
        
        //防止多次接受通知
        if (playState == videoPlayStatePlaying) {
            return;
        }
        
        UIView *remoteView = [self.videoBgImageView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        if (remoteView) {
            [remoteView removeFromSuperview];
            remoteView = nil;
        }
        
        //NSInteger pid = [self.devModel.pid integerValue];
        
        width = self.view.width;
        height= width;
        size = CGSizeMake(width, width);
        
        Panoramic720IosView * _remoteView = [[Panoramic720IosView alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, self.videoBgImageView.width, self.videoBgImageView.height)];
        [_remoteView configV720];
        _remoteView.tag = VIEW_REMOTERENDE_VIEW_TAG;
        _remoteView.backgroundColor = [UIColor blackColor];
        _remoteView.layer.edgeAntialiasingMask = YES;
        [self.videoBgImageView addSubview:_remoteView];
        [self.videoBgImageView sendSubviewToBack:_remoteView];
        
        [CylanJFGSDK startRenderRemoteView:_remoteView];
        //remoteCallViewSize = size;
        //[self remoteViewSizeFit];
        if (playState != videoPlayStatePlaying)
        {
            //[self voiceAndMicBtnNomalState];
            //[self fullVideoAndMicBtnNomal];
        }
        playState = videoPlayStatePlaying;
        [self stopLoadingAnimation];
       
        [self btnStatueForCarame];
        //[self isFristIntoView];
        
//        if (self.rateLabel.superview == nil) {
//            [self.videoBgView addSubview:self.rateLabel];
//        }
//        self.rateLabel.hidden = NO;
//        self.rateLabel.alpha = 1;
//        self.rateLabel.text = [NSString stringWithFormat:@"%.0fK/s",0.0];
//        [self.videoBgView bringSubviewToFront:self.rateLabel];
//        
//        
//        self.videoPlayTipLabel.x = self.view.width*0.5;
//        self.videoPlayTipLabel.bottom = self.videoBgView.height-8;
//        self.videoPlayTipLabel.hidden = NO;
//        [self.videoBgView addSubview:self.videoPlayTipLabel];
        
        //开启屏幕常亮
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    
    
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
        //int videorecved = [dict[@"videoRecved"] intValue];
        //historyLastestTimeStamp = timesTamp;
        
//        if (!dateFormatter) {
//            dateFormatter = [[NSDateFormatter alloc]init];
//            [dateFormatter setDateFormat:@"MM/dd HH:mm"];
//        }
//        
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
        
        
//        NSMutableString *dat;
//        
//        if (isLiveVideo) {
//            
//            dat =  [NSMutableString stringWithString:[dateFormatter stringFromDate:[NSDate date]]];
//            [dat insertString:@"直播| " atIndex:0];
//            
//            //保留播放控件
//            if (windowMode == videoPlayModeSmallWindow) {
//                self.playButton.selected = YES;
//            }else{
//                self.fullPlayBtn.selected = YES;
//            }
//            
//        }else{
//            
//            
//            dat =  [NSMutableString stringWithString:[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timesTamp]]];
//            [dat insertString:@"录像| " atIndex:0];
//            [self.historyView setHistoryTableViewOffsetByTimeStamp:timesTamp];
//            
//        }
//        self.videoPlayTipLabel.text = dat;
//        //CGFloat m = videoRecved/1024.0/1024.0;
        CGFloat kb = bitRate/8;
        //NSString *recoredStr =[NSString stringWithFormat:@"%.0fK/s  %.1fM",kb,m];
        //    if (m>1024) {
        //        recoredStr =[NSString stringWithFormat:@"%.0fK/s  %.1fG",kb,m/1024.0];
        //    } 5
        //self.rateLabel.hidden = NO;
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
    
    if ([remoteID isEqualToString:self.devModel.uuid] || [remoteID isEqualToString:@"server"]) {
        
        [self stopVideoPlay];
        JFGErrorType errorType = (JFGErrorType)[dict[@"error"] intValue];
        [self showTipView:[CommonMethod languaeKeyForLiveVideoErrorType:errorType]];
       
        playState = videoPlayStateDisconnectCamera;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
        
    }
    
}

#pragma mark- 直播超时事件
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

-(void)playRequestTimeoutDeal
{
    playState = videoPlayStateDisconnectCamera;
    [self stopVideoPlay];
    [self showTipView:[JfgLanguage getLanTextStrByKey:@"Tips_Device_TimeoutRetry"]];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rtcpLowAction) object:nil];
}

-(void)rtcpLowAction
{
    if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
        [self startLodingAnimation];
    }
    
}


#pragma mark- 按钮事件
-(void)albumsAction:(UIButton *)sender
{
    Pano720PhotoVC *panoPhotoVC = [[Pano720PhotoVC alloc] init];
    panoPhotoVC.cid = self.devModel.uuid;
    panoPhotoVC.pType = (productType)[self.devModel.pid intValue];
    [self.navigationController pushViewController:panoPhotoVC animated:YES];
}

#pragma mark- 按钮状态

//默认拍照状态
-(void)btnStatueForCarame
{
    isCarameMode = YES;
    self.cameraModeBtn.selected = YES;
    self.videoModeBtn.selected = NO;
    
    self.cameraModeBtn.enabled = YES;
    self.videoModeBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    self.albumsBtn.enabled = YES;
    self.takePhotoBtn.enabled = YES;
}

//不可点击状态
-(void)btnDisenableStatue
{
    self.cameraModeBtn.enabled = NO;
    self.videoModeBtn.enabled = NO;
    self.moreBtn.enabled = NO;
    self.albumsBtn.enabled = YES;
    self.takePhotoBtn.enabled = NO;
}


//拍照，或者录像请求发送中的状态
-(void)btnStatueForLoading
{
    self.cameraModeBtn.hidden = YES;
    self.videoModeBtn.hidden = YES;
    self.moreBtn.hidden = YES;
    self.albumsBtn.hidden = YES;
    self.takePhotoBtn.enabled = NO;
    if (self.takePhotoLoadingView.superview != self.takePhotoBtn) {
        [self.takePhotoLoadingView removeFromSuperview];
        [self.takePhotoBtn addSubview:self.takePhotoLoadingView];
        self.takePhotoLoadingView.hidden = NO;
        [self.takePhotoLoadingView startAnimating];
    }
}

//短视频录制状态
-(void)btnStatueForShortVideoWithRemainSe:(int)remainSecound
{
    [UIView animateWithDuration:0.3 animations:^{
        self.cameraModeBtn.hidden = YES;
        self.videoModeBtn.hidden = YES;
        self.albumsBtn.hidden = YES;
        self.moreBtn.hidden = YES;
    }];
    if (self.moreBtn.selected) {
        [self hideMoreBtn];
        self.moreBtn.selected = NO;
    }
    self.shortVideoTimeLabel.text = [NSString stringWithFormat:@"%dS",remainSecound];
    self.shortVideoTimeLabel.hidden = NO;
    shortVideoTimeCount = remainSecound;
    shortVideoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shortVideoTimeShowAction) userInfo:nil repeats:YES];
    [self.recordAnimationView startAnimation];
    [self.recordAnimationView setHidden:NO];
    [self.takePhotoLoadingView removeFromSuperview];
    self.takePhotoLoadingView.hidden = YES;
    self.takePhotoBtn.enabled = YES;
}


//长视频录制状态
-(void)btnStatueForLongVideoForSecounds:(int)secounds
{
    [UIView animateWithDuration:0.3 animations:^{
        self.cameraModeBtn.hidden = YES;
        self.videoModeBtn.hidden = YES;
        self.albumsBtn.hidden = YES;
        self.moreBtn.hidden = YES;
    }];
    if (self.moreBtn.selected) {
        [self hideMoreBtn];
        self.moreBtn.selected = NO;
    }
    [self.takePhotoLoadingView removeFromSuperview];
    self.takePhotoLoadingView.hidden = YES;
    self.takePhotoBtn.enabled = YES;
    self.timepiceView.hidden = NO;
    
    int hour = secounds/3600;
    int minute = (secounds%3600)/60;
    int second = secounds%60;
    
    [self.timepiceView startTimerForHour:hour min:minute sec:second];
}

-(void)btnEnableStatue
{
    self.cameraModeBtn.enabled = YES;
    self.videoModeBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    self.albumsBtn.enabled = YES;
    self.takePhotoBtn.enabled = YES;
}


-(void)settingAction
{
    DeviceSettingVC *deviceSetting = [DeviceSettingVC new];
    deviceSetting.cid = self.devModel.uuid;
    deviceSetting.isShare = (self.devModel.shareState == DevShareStatuOther);
    deviceSetting.devModel = self.devModel;
    deviceSetting.pType = productType_720;
    
    if ([self.devModel.alias isEqualToString:@""]) {
        deviceSetting.alis = self.devModel.uuid;
    }else{
        deviceSetting.alis = self.devModel.alias;
    }
    
    [self.navigationController pushViewController:deviceSetting animated:YES];
    
}

-(void)videoModelAction
{
    if (isCarameMode) {
        //选择
        self.takePhotoBtn.selected = NO;
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_video_normal"] forState:UIControlStateNormal];
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_video_recording_nomal"] forState:UIControlStateSelected];
        
        isCarameMode = NO;
        self.videoModeBtn.selected = YES;
        self.cameraModeBtn.selected = NO;
        
    }
    
    
}

-(void)cameraModeAction
{
    if (!isCarameMode) {
        isCarameMode = YES;
        self.videoModeBtn.selected = NO;
        self.cameraModeBtn.selected = YES;
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateNormal];
        [self.takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateSelected];
        self.takePhotoBtn.selected = NO;
    }
}

-(void)moreAction:(UIButton *)sender
{
    NSLog(@"touch");
    if (sender.selected) {
        [self hideMoreBtn];
    }else{
        [self showMoreBtn];
    }
    sender.selected = !sender.selected;
}

//速率选择按钮
-(void)speedModeAction:(UIButton *)sender
{
    
}


//点击按钮隐藏tip
-(void)singularTipCancelBtnAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.singularTipBgView.alpha = 0;
    } completion:^(BOOL finished) {
        self.singularTipBgView.hidden = YES;
    }];
}

//拍照按钮
-(void)takePhotoTouchUpDown:(JFGTakePhotoButton *)btn forTakePhotoEvents:(JFGTakePhotoTouchEvents)controlEvents
{
    if (btn.selected == NO) {
        
        if (!isCarameMode) {
            //录像模式下点击
//            [UIView animateWithDuration:0.3 animations:^{
//                self.cameraModeBtn.hidden = YES;
//                self.videoModeBtn.hidden = YES;
//                self.albumsBtn.hidden = YES;
//                self.moreBtn.hidden = YES;
//            }];
//            if (self.moreBtn.selected) {
//                [self hideMoreBtn];
//                self.moreBtn.selected = NO;
//            }
            if (controlEvents == JFGTakePhotoTouchLongTap) {
                NSLog(@"long tap");
                
//                self.shortVideoTimeLabel.text = @"8S";
//                self.shortVideoTimeLabel.hidden = NO;
//                shortVideoTimeCount = 8;
//                shortVideoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shortVideoTimeShowAction) userInfo:nil repeats:YES];
//                
//                [self.recordAnimationView startAnimation];
//                [self.recordAnimationView setHidden:NO];

#pragma mark- 长按开始短视频录制
                recordState = VideoRecordStatue8SRecording;
                [self shortVideoRecoding];
                
            }else{
//                NSLog(@"single tap");
//                self.timepiceView.hidden = NO;
//                [self.timepiceView startTimerForHour:0 min:0 sec:0];
#pragma mark- 单击开始长视频录制
                [self longVideoRecoding];
                recordState = VideoRecordStatueLongRecording;
            }
        }else{
            //拍照模式下
            recordState = VideoRecordStatueNone;
            [self camarePhotoReq];
            
        }
    }else{
        
        if (!isCarameMode) {
            
            if (self.shortVideoTimeLabel.hidden == NO) {
                //停止短视频录制
                [self stopShortVideoRecode];
            }
            
            if (self.timepiceView.hidden == NO) {
                //停止长视频录制
                [self stopLongVideoRecode];
            }
            
            [self stopVideoViewRefresh];
            
        }else{
            //拍照模式下
            [self camarePhotoReq];
        }
    }
    btn.selected = !btn.selected;
}


-(void)stopVideoViewRefresh
{
    if (!isCarameMode) {
        
        [self.takePhotoLoadingView removeFromSuperview];
        [self.takePhotoLoadingView setHidden:YES];
        self.shortVideoTimeLabel.hidden = YES;
        self.shortVideoTimeLabel.text = @"8S";
        shortVideoTimeCount = 8;
        if (shortVideoTimer && [shortVideoTimer isValid]) {
            [shortVideoTimer invalidate];
            shortVideoTimer = nil;
        }
        
        [self.recordAnimationView stopAnimation];
        [self.recordAnimationView setHidden:YES];
        self.timepiceView.hidden = YES;
        [self.timepiceView stopTimer];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.cameraModeBtn.hidden = NO;
            self.videoModeBtn.hidden = NO;
            self.albumsBtn.hidden = NO;
            self.moreBtn.hidden = NO;
        }];
        
    }
}

-(void)shortVideoTimeShowAction
{
    shortVideoTimeCount --;
    self.shortVideoTimeLabel.text = [NSString stringWithFormat:@"%dS",shortVideoTimeCount];
    if (shortVideoTimeCount <= 0) {
        
        self.shortVideoTimeLabel.hidden = YES;
        self.shortVideoTimeLabel.text = @"8S";
        self.takePhotoBtn.selected = NO;
        if (shortVideoTimer && [shortVideoTimer isValid]) {
            [shortVideoTimer invalidate];
            shortVideoTimer = nil;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.cameraModeBtn.hidden = NO;
            self.videoModeBtn.hidden = NO;
            self.albumsBtn.hidden = NO;
            self.moreBtn.hidden = NO;
        }];
        
    }
}

#pragma mark- 长视频录制相关
-(void)longVideoRecoding
{
    [self videoRecordingReqForLong:YES];
}

-(void)stopLongVideoRecode
{
    [self stopVideoRecordingReqForLong:YES];
}

#pragma mark- 短视频录制相关
-(void)shortVideoRecoding
{
    [self videoRecordingReqForLong:NO];
}


-(void)stopShortVideoRecode
{
    [self stopVideoRecordingReqForLong:NO];
}

#pragma mark- 拍照
-(void)camarePhotoReq
{
    if (playState == videoPlayStatePlaying) {
        
        
        NSData *data = [MPMessagePackWriter writeObject:@[@""] error:nil];
       
        if ([JFGSDKSock sharedClient].isConnected) {
            //局域网
            [[JFGSDKSock sharedClient] sendMsgForSockWithDst:@[self.devModel.uuid] isAck:YES fileType:7 msg:data];
            
        }else{
            //走服务器
            [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:7 msg:data];
        }
        
        UIView *remoteView = [self.videoBgImageView viewWithTag:VIEW_REMOTERENDE_VIEW_TAG];
        if (remoteView) {
            
            if ([remoteView isKindOfClass:[Panoramic720IosView class]]) {
                
                Panoramic720IosView *rvc = (Panoramic720IosView *)remoteView;
                UIImage *image = [rvc takeSnapshot];
                [self.albumsBtn setImage:image forState:UIControlStateNormal];
            }
        }
        
    }
}

-(void)videoRecordingReqForLong:(BOOL)isLong
{
    //9 videoType 特征值定义： videoTypeShort = 1 8s短视频； videoTypeLong = 2 长视频
    NSData *data = [MPMessagePackWriter writeObject:@[@(isLong?2:1)] error:nil];
    if ([JFGSDKSock sharedClient].isConnected) {
        [[JFGSDKSock sharedClient] sendMsgForSockWithDst:@[self.devModel.uuid] isAck:YES fileType:9 msg:data];
    }else{
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:9 msg:data];
    }
    
}

-(void)stopVideoRecordingReqForLong:(BOOL)isLong
{
    NSData *data = [MPMessagePackWriter writeObject:@[@(isLong?2:1)] error:nil];
    if ([JFGSDKSock sharedClient].isConnected) {
        [[JFGSDKSock sharedClient] sendMsgForSockWithDst:@[self.devModel.uuid] isAck:YES fileType:11 msg:data];
    }else{
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:11 msg:data];
    }
}

#pragma mark- 动画事件
-(void)startLodingAnimation
{
    [self.videoBgImageView bringSubviewToFront:self.loadingImageView];
    if (!self.loadingImageView.hidden) {
        return;
    }
    self.loadingImageView.hidden = NO;
    [self hiddenTipView];
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

#pragma mark- 异常显示
-(void)showTipView:(NSString *)tipString
{
    if (self.singularTipBgView.hidden) {
        
        self.rateLabel.hidden = YES;
        self.singularTipBgView.top = -self.singularTipBgView.height;
        self.singularTipBgView.hidden = NO;
        self.singularTipBgView.alpha = 1;
        if (self.singularTipBgView.superview == nil) {
            [self.videoBgImageView addSubview:self.singularTipBgView];
        }else{
            [self.videoBgImageView bringSubviewToFront:self.singularTipBgView];
        }
        
        self.singularTipLabel.text = tipString;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.singularTipBgView.top = 0;
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
        
        self.singularTipLabel.text = tipString;
    }
}

#pragma mark- 状态显示
-(void)showStatusTipForWiFiMode:(BOOL)wifiMode batteryCapacity:(int)battery
{
    isWifi = wifiMode;
    batteryRl = battery;
    if (self.statusShowBgView.superview == nil) {
        [self.videoBgImageView addSubview:self.statusShowBgView];
        [self.statusShowBgView addSubview:self.statusNetIcon];
        [self.statusShowBgView addSubview:self.statusNetLabel];
        [self.statusShowBgView addSubview:self.statusBatteryIcon];
        [self.statusShowBgView addSubview:self.statusBatteryLabel];
    }
    
    if (wifiMode) {
        self.statusNetIcon.image = [UIImage imageNamed:@"camera720_icon_wifi"];
        self.statusNetLabel.text = [NSString stringWithFormat:@"WiFi%@",[JfgLanguage getLanTextStrByKey:@"DOOR_CONNECT"]];
    }else{
        self.statusNetIcon.image = [UIImage imageNamed:@"camera720_icon_ap"];
        self.statusNetLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_OutdoorMode"];
    }
    
    if (battery > 100) {
        self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge"];
        self.statusBatteryLabel.text = @"充电中";
    }else{
        if (battery >= 80) {
            self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge_full"];
        }else if (battery > 20){
            self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge_half"];
        }else{
            self.statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_low_power"];
        }
        self.statusBatteryLabel.text =[NSString stringWithFormat:@"%d%%",battery];
    }
    
    
}


#pragma mark- getter

-(UIButton *)settingBtn
{
    if (!_settingBtn) {
        _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _settingBtn.frame = CGRectMake(self.view.width-44-5, 20, 44, 44);
        [_settingBtn setImage:[UIImage imageNamed:@"camera_ico_install"] forState:UIControlStateNormal];
        [_settingBtn addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingBtn;
}

-(UIView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 144)];
        _bottomBgView.bottom = self.view.height;
        UIColor *color = [UIColor colorWithHexString:@"#333333"];
        color = [color colorWithAlphaComponent:0.95];
        _bottomBgView.backgroundColor = color;
    }
    return _bottomBgView;
}

-(UIButton *)albumsBtn
{
    if (!_albumsBtn) {
        _albumsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _albumsBtn.size = CGSizeMake(45, 45);
        _albumsBtn.left = 39;
        _albumsBtn.bottom = self.bottomBgView.height - 33;
        _albumsBtn.layer.masksToBounds = YES;
        _albumsBtn.layer.cornerRadius = 45*0.5;
        [_albumsBtn setImage:[UIImage imageNamed:@"camera720_icon_album_normal"] forState:UIControlStateNormal];
        [_albumsBtn setImage:[UIImage imageNamed:@"camera720_icon_album_disabled"] forState:UIControlStateDisabled];
        [_albumsBtn addTarget:self action:@selector(albumsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumsBtn;
}

-(UIButton *)takePhotoBtn
{
    if (!_takePhotoBtn) {
        _takePhotoBtn = [JFGTakePhotoButton buttonWithType:UIButtonTypeCustom];
        _takePhotoBtn.size = CGSizeMake(73, 73);
        _takePhotoBtn.x = self.bottomBgView.width*0.5;
        _takePhotoBtn.bottom = self.bottomBgView.height-19;
        [_takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_normal"] forState:UIControlStateNormal];
        [_takePhotoBtn setImage:[UIImage imageNamed:@"camera720_icon_photograph_disabled"] forState:UIControlStateDisabled];
        _takePhotoBtn.delegate = self;

    }
    return _takePhotoBtn;
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.size = CGSizeMake(45, 45);
        _moreBtn.right = self.bottomBgView.width - 39;
        _moreBtn.bottom = self.albumsBtn.bottom;
        _moreBtn.selected = NO;
        _moreBtn.isRelatingTouchEvent = YES;
        [_moreBtn setImage:[UIImage imageNamed:@"camera720_icon_more_normal"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"camera720_icon_more_disabled"] forState:UIControlStateDisabled];
        [_moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

-(UIButton *)cameraModeBtn
{
    if (!_cameraModeBtn) {
        _cameraModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraModeBtn.size = CGSizeMake(25, 25);
        _cameraModeBtn.top = 9;
        _cameraModeBtn.right = self.view.x - 23;
        [_cameraModeBtn setImage:[UIImage imageNamed:@"camera720_icon_camera_normal"] forState:UIControlStateNormal];
        [_cameraModeBtn setImage:[UIImage imageNamed:@"camera720_icon_camera_selected"] forState:UIControlStateSelected];
        [_cameraModeBtn setImage:[UIImage imageNamed:@"camera720_icon_camera_disabled"] forState:UIControlStateDisabled];
        [_cameraModeBtn addTarget:self action:@selector(cameraModeAction) forControlEvents:UIControlEventTouchUpInside];
        _cameraModeBtn.selected = YES;
        //camera720_icon_camera_selected_disabled
    }
    return _cameraModeBtn;
}

-(UIButton *)videoModeBtn
{
    if (!_videoModeBtn) {
        _videoModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoModeBtn.size = CGSizeMake(25, 25);
        _videoModeBtn.top = 9;
        _videoModeBtn.left = self.view.x + 23;
        [_videoModeBtn setImage:[UIImage imageNamed:@"camera720_icon_video_small_normal"] forState:UIControlStateNormal];
        [_videoModeBtn setImage:[UIImage imageNamed:@"camera720_icon_video_selected"] forState:UIControlStateSelected];
        [_videoModeBtn setImage:[UIImage imageNamed:@"camera720_icon_video_small_disabled"] forState:UIControlStateDisabled];
        [_videoModeBtn addTarget:self action:@selector(videoModelAction) forControlEvents:UIControlEventTouchUpInside];
        //camera720_icon_video_selected_disabled
    }
    return _videoModeBtn;
}

-(UIImageView *)videoBgImageView
{
    if (!_videoBgImageView) {
        _videoBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64 -self.bottomBgView.height)];
        _videoBgImageView.userInteractionEnabled = YES;
        _videoBgImageView.backgroundColor = [UIColor blackColor];
        _videoBgImageView.clipsToBounds = YES;
    }
    return _videoBgImageView;
}

-(UIImageView *)loadingImageView
{
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"camera_loading"]];
        _loadingImageView.x = self.videoBgImageView.width*0.5;
        _loadingImageView.y = self.videoBgImageView.height*0.5;
        _loadingImageView.userInteractionEnabled = YES;
        _loadingImageView.hidden = YES;
    }
    return _loadingImageView;
}



-(void)hiddenTipView
{
    if (!self.singularTipBgView.hidden) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.singularTipBgView.top = -self.singularTipBgView.height;
        } completion:^(BOOL finished) {
            self.singularTipBgView.hidden = YES;
            self.rateLabel.hidden = NO;
        }];
    }
}

-(UIView *)singularTipBgView
{
    if (!_singularTipBgView) {
        _singularTipBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _singularTipBgView.backgroundColor = [UIColor colorWithHexString:@"#fffce1"];
        _singularTipBgView.top = -44;
        _singularTipBgView.hidden = YES;
        
        [_singularTipBgView addSubview:self.singularTipIcon];
        [_singularTipBgView addSubview:self.singularTipLabel];
        [_singularTipBgView addSubview:self.singularTipCancelBtn];
        
    }
    return _singularTipBgView;
}

-(UIImageView *)singularTipIcon
{
    if (!_singularTipIcon) {
        _singularTipIcon = [[UIImageView alloc]initWithFrame:CGRectMake(29, 12, 20, 20)];
        _singularTipIcon.image = [UIImage imageNamed:@"icon_caution"];
    }
    return _singularTipIcon;
}

-(UILabel *)singularTipLabel
{
    if (!_singularTipLabel) {
        _singularTipLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 12, self.view.width-70-56, 20)];
        _singularTipLabel.backgroundColor = [UIColor clearColor];
        _singularTipLabel.font = [UIFont boldSystemFontOfSize:16];
        _singularTipLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    }
    return _singularTipLabel;
}

-(UIButton *)singularTipCancelBtn
{
    if (!_singularTipCancelBtn) {
        _singularTipCancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _singularTipCancelBtn.frame = CGRectMake(0, 10, 24, 24);
        _singularTipCancelBtn.right = self.view.width - 15;
        [_singularTipCancelBtn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [_singularTipCancelBtn addTarget:self action:@selector(singularTipCancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _singularTipCancelBtn;
}





#pragma mark- getter
-(UIView *)statusShowBgView
{
    if (!_statusShowBgView) {
        _statusShowBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 32)];
        _statusShowBgView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.2];
        
    }
    return _statusShowBgView;
}

-(UIImageView *)statusNetIcon
{
    if (!_statusNetIcon) {
        _statusNetIcon = [[UIImageView alloc]initWithFrame:CGRectMake(17, 7, 18, 18)];
        _statusNetIcon.image = [UIImage imageNamed:@"camera720_icon_wifi"];
    }
    return _statusNetIcon;
}

-(UILabel *)statusNetLabel
{
    if (!_statusNetLabel) {
        _statusNetLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.statusNetIcon.right+10, self.statusNetIcon.top, 100, self.statusNetIcon.height)];
        _statusNetLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _statusNetLabel.font = [UIFont systemFontOfSize:12];
        _statusNetLabel.text = [NSString stringWithFormat:@"WiFi%@",[JfgLanguage getLanTextStrByKey:@"DOOR_CONNECT"]];;
    }
    return _statusNetLabel;
}

-(UIImageView *)statusBatteryIcon
{
    if (!_statusBatteryIcon) {
        _statusBatteryIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 6, 18, 18)];
        _statusBatteryIcon.right = self.view.width - 15 - 48;
        _statusBatteryIcon.image = [UIImage imageNamed:@"camera720_icon_electricity_charge_full"];
    }
    return _statusBatteryIcon;
}

-(UILabel *)statusBatteryLabel
{
    if (!_statusBatteryLabel) {
        _statusBatteryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 7, 40, 18)];
        _statusBatteryLabel.right = self.view.width - 15;
        _statusBatteryLabel.font = [UIFont systemFontOfSize:12];
        _statusBatteryLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _statusBatteryLabel.text = @"100%";
        
    }
    return _statusBatteryLabel;
}

-(UILabel *)rateLabel
{
    if (!_rateLabel) {
        _rateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 37, 50, 22)];
        _rateLabel.right = self.view.width - 10;
        _rateLabel.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.2];
        _rateLabel.textAlignment = NSTextAlignmentCenter;
        _rateLabel.font = [UIFont systemFontOfSize:12];
        _rateLabel.layer.masksToBounds = YES;
        _rateLabel.layer.cornerRadius = 3;
        _rateLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _rateLabel.text = @"0K/s";
        _rateLabel.hidden = YES;
    }
    return _rateLabel;
}

-(UIView *)speedModeBgView
{
    if (!_speedModeBgView) {
        
        CGFloat top = self.view.height - 64 - self.bottomBgView.height-15-44;
        _speedModeBgView = [[UIView alloc]initWithFrame:CGRectMake(self.view.width-144-15, top, 144, 44)];
        _speedModeBgView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.4];
        _speedModeBgView.layer.masksToBounds = YES;
        _speedModeBgView.layer.cornerRadius = 22;
        _speedModeBgView.top = self.view.height - 64 - self.bottomBgView.height;
        _speedModeBgView.alpha = 0;
        
        [_speedModeBgView addSubview:self.speedModeLeftBtn];
        [_speedModeBgView addSubview:self.speedModeLabel];
        [_speedModeBgView addSubview:self.speedModeRightBtn];
    }
    return _speedModeBgView;
}

-(UIButton *)speedModeLeftBtn
{
    if (!_speedModeLeftBtn) {
        _speedModeLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _speedModeLeftBtn.frame = CGRectMake(8, 10, 24, 24);
        [_speedModeLeftBtn setImage:[UIImage imageNamed:@"btn_leftkey_nomal"] forState:UIControlStateNormal];
        [_speedModeLeftBtn setImage:[UIImage imageNamed:@"btn_leftkey_disabled"] forState:UIControlStateDisabled];
        [_speedModeLeftBtn addTarget:self action:@selector(speedModeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedModeLeftBtn;
}

-(UIButton *)speedModeRightBtn
{
    if (!_speedModeRightBtn) {
        _speedModeRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _speedModeRightBtn.frame = CGRectMake(self.speedModeLabel.right+8, 10, 24, 24);
        
        [_speedModeRightBtn setImage:[UIImage imageNamed:@"btn_rightkey_nomal"] forState:UIControlStateNormal];
        [_speedModeRightBtn setImage:[UIImage imageNamed:@"btn_rightkey_disabled"] forState:UIControlStateDisabled];
        [_speedModeRightBtn addTarget:self action:@selector(speedModeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedModeRightBtn;
}

-(UILabel *)speedModeLabel
{
    if (!_speedModeLabel) {
        _speedModeLabel = [[UILabel alloc]initWithFrame:CGRectMake(16+24, 13, 144-16-24, 16)];
        _speedModeLabel.text = @"速率:自动";
        _speedModeLabel.font = [UIFont systemFontOfSize:15];
        _speedModeLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        [self.KVOController observe:_speedModeLabel keyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            
            //根据文字适配
            [self.speedModeLabel sizeToFit];
            CGSize size = self.speedModeLabel.size;
            CGFloat allWidth = size.width + (16+self.speedModeLeftBtn.width)*2;
            self.speedModeBgView.width = allWidth;
            self.speedModeLabel.x = allWidth*0.5;
            self.speedModeLeftBtn.left = 8;
            self.speedModeRightBtn.left = self.speedModeLabel.right+8;
            
            
            
        }];
    }
    return _speedModeLabel;
}

-(UIButton *)voiceBtn
{
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceBtn.frame = CGRectMake(0, 0, 44, 44);
        _voiceBtn.bottom = self.speedModeBgView.top-15;
        _voiceBtn.right = self.videoBgImageView.width-15;
        [_voiceBtn setImage:[UIImage imageNamed:@"camera720_icon_no_voice_nomal"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"camera720_icon_no_voice_pressed"] forState:UIControlStateHighlighted];
        _voiceBtn.top = self.view.height - 64 - self.bottomBgView.height;
        _voiceBtn.alpha = 0;
        //camera720_icon_voice_nomal
        //camera720_icon_voice_pressed
    }
    return _voiceBtn;
}

-(UIButton *)micBtn
{
    if (!_micBtn) {
        _micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _micBtn.frame = CGRectMake(0, 0, 44, 44);
        _micBtn.bottom = self.voiceBtn.top-15;
        _micBtn.right = self.videoBgImageView.width-15;
        _micBtn.top = self.view.height - 64 - self.bottomBgView.height;
        [_micBtn setImage:[UIImage imageNamed:@"camera720_icon_notalk_nomal"] forState:UIControlStateNormal];
        [_micBtn setImage:[UIImage imageNamed:@"camera720_icon_notalk_pressed"] forState:UIControlStateHighlighted];
        _micBtn.alpha = 0;
        //camera720_icon_talk_nomal
        //camera720_icon_talk_pressed
    }
    return _micBtn;
}


-(void)hideMoreBtn
{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        CGFloat top = self.view.height - 64 - self.bottomBgView.height;
        self.speedModeBgView.top = top;
        self.voiceBtn.top = top;
        self.micBtn.top = top;
        
        self.speedModeBgView.alpha = 0;
        self.voiceBtn.alpha = 0;
        self.micBtn.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.speedModeBgView.alpha = 0;
        self.voiceBtn.alpha = 0;
        self.micBtn.alpha = 0;
    }];
}

-(void)showMoreBtn
{
    [UIView animateWithDuration:0.2 animations:^{
        self.speedModeBgView.alpha = 1;
        self.voiceBtn.alpha = 1;
        self.micBtn.alpha = 1;
    }];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat top = self.view.height - 64 - self.bottomBgView.height-15-44;
        self.micBtn.bottom = top - self.voiceBtn.height - 15 - 15;
        self.voiceBtn.bottom = top - 15;
        self.speedModeBgView.top = top;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(JFGTimepieceView *)timepiceView
{
    if (!_timepiceView) {
        _timepiceView = [[JFGTimepieceView alloc]initWithFrame:CGRectMake(0, 18, 100, 18)];
        _timepiceView.x = self.view.width*0.5;
        _timepiceView.hidden = YES;
    }
    return _timepiceView;
}

-(UILabel *)shortVideoTimeLabel
{
    if (!_shortVideoTimeLabel) {
        _shortVideoTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 18, 100, 18)];
        _shortVideoTimeLabel.x = self.view.width * 0.5;
        _shortVideoTimeLabel.font = [UIFont systemFontOfSize:16];
        _shortVideoTimeLabel.textAlignment = NSTextAlignmentCenter;
        _shortVideoTimeLabel.textColor = [UIColor whiteColor];
        _shortVideoTimeLabel.text = @"0S";
        _shortVideoTimeLabel.hidden = YES;
    }
    return _shortVideoTimeLabel;
}

-(JFGShortVideoRecordAnimation *)recordAnimationView
{
    if (!_recordAnimationView) {
        _recordAnimationView = [[JFGShortVideoRecordAnimation alloc]initWithFrame:CGRectMake(0, 0, self.bottomBgView.width, 3)];
        _recordAnimationView.hidden = YES;
    }
    return _recordAnimationView;
}

-(UIActivityIndicatorView *)takePhotoLoadingView
{
    if (!_takePhotoLoadingView) {
        _takePhotoLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _takePhotoLoadingView.center = CGPointMake(self.takePhotoBtn.width*0.5, self.takePhotoBtn.height*0.5);
        
    }
    return _takePhotoLoadingView;
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
