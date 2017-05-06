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
#import "AddDeviceGuideViewController.h"
#import "Cf720WiFiAnimationVC.h"
#import "WifiModeFor720CFResultVC.h"
#import "JfgHttp.h"
#import "XTimer.h"


#define VIEW_REMOTERENDE_VIEW_TAG  10023

//录像状态
typedef NS_ENUM(NSInteger,VideoRecordStatue) {
    VideoRecordStatueNone,//没有录像
    VideoRecordStatue8SRecording,//短视频录制
    VideoRecordStatueLongRecording,//长视频录制
};

@interface VideoPlayFor720ViewController ()<JFGTakePhotoTouchActionDelegate,JFGSDKCallbackDelegate,JFGMsgForwardDataDownloadDelegate,AddDeviceGuideVCNextActionDelegate>
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
    
    int shortVideoTimeCount;//短视频时间记录
    NSTimer *shortVideoTimer;//短视频录制计时器
    NSTimer *fpingTimer;
    JFGMsgForwardDataDownload *downloadManager;
    BOOL isDevOffline;
    BOOL isAddNotification;
    BOOL isSetHomeMode;
    BOOL isHaveSDCard;
    BOOL isDidAppear;
    NSString *devIpAddr;
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

@property (nonatomic,strong)UIView *netModeSwitchBgView;

@end

@implementation VideoPlayFor720ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self btnDisenableStatue];//设备状态显示
    [JFGSDK addDelegate:self];
    [self initView];
    [self startFping];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isDidAppear = YES;
    //开启屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self addVideoNotification];
    [self videoRecordstatusRequest];
    [self workNetDecide];
    //[self btnStatueForCarame];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopVideoPlay];
    [self stopFping];
    [self removeVideoDelegate];
    //关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    isDidAppear = NO;
}

//网络状态判断
-(void)workNetDecide
{
    BOOL isAP = [CommonMethod isConnectedAPWithPid:productType_720 Cid:self.devModel.uuid];
    
    if (isAP) {
        
        [self showStatusTipForWiFiMode:NO batteryCapacity:batteryRl];
        if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
           
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
                            [self startLiveVideo];
                        }
                    }else{
                        if ([JFGSDK currentNetworkStatus] == JFGNetTypeWifi) {
                            if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                                [self startLiveVideo];
                            }
                        }else{
                            [self showAgainView];
                        }
                        
                    }
                    
                } otherDelegate:nil];
                
            }else{
                //客户端wifi连接
                [self showStatusTipForWiFiMode:YES batteryCapacity:self.devModel.Battery];
                if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                    [self startLiveVideo];
                }
                
            }
            [self reqForBattaryAndSDCard];
            
        }else{
            //离线
            //[self showTipView:[JfgLanguage getLanTextStrByKey:@"Tips_Device_TimeoutRetry"]];
            if (playState != videoPlayStatePlaying && playState != videoPlayStatePlayPreparing) {
                [self startLiveVideo];
            }
        }
    }
    
}


#pragma mark- fping
-(void)startFping
{
    if (fpingTimer == nil) {
        fpingTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fpingAction) userInfo:nil repeats:YES];
    }
}

-(void)fpingAction
{
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
    NSLog(@"VideoPlayFor720VC_fpingAction");
}

-(void)stopFping
{
    if (fpingTimer && [fpingTimer isValid]) {
        [fpingTimer invalidate];
        fpingTimer = nil;
    }
}

-(void)releaseTimer
{
    [self stopFping];
    if (shortVideoTimer && [shortVideoTimer isValid]) {
        [shortVideoTimer invalidate];
    }
    shortVideoTimer = nil;
    [self.timepiceView stopTimer];
    [self.recordAnimationView stopAnimation];
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
    if (!isDidAppear) {
        return;
    }
    if ([ask.cid isEqualToString:self.devModel.uuid] && isDidAppear) {
        
        [self stopFping];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"ip:%@ cid:%@",ask.address,ask.cid]];
        devIpAddr = ask.address;
        NSLog(@"devIpAddr:%@",devIpAddr);
        [ProgressHUD showText:@"局域网ip地址获取成功"];
        [self reqForBattaryAndSDCard];
        [self videoRecordstatusRequest];
        
    }
}


-(void)requestForUrl:(NSString *)url success:(void (^)(id _Nullable responseObject))success failure:(void (^)(NSError * _Nonnull))failure
{
   
    AFHTTPSessionManager *manager = [JfgHttp sharedHttp].httpManager;
    NSLog(@"requestUrl:%@",url);
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
         NSLog(@"total:%lld Unit:%lld",downloadProgress.totalUnitCount,downloadProgress.completedUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"这里打印请求成功要做的事");
        NSLog(@"%@",responseObject);
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"error%@",error);  //这里打印错误信息
        if (failure) {
            failure(error);
        }
    }];
}


- (void)downLoad{
    
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //2.确定请求的URL地址
    NSURL *url = [NSURL URLWithString:@"http://192.168.103.222/images/1492775924_584.mp4"];
    
    //3.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //打印下下载进度
        NSLog(@"下载进度:%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //下载地址
        NSLog(@"默认下载地址:%@",targetPath);
        
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        filePath = [filePath stringByAppendingPathComponent:@"1492769029_12.mp4"];
        return [NSURL fileURLWithPath:filePath];
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //下载完成调用的方法
       
        if (error) {
            NSLog(@"下载失败:%@",error);
        }else{
            NSLog(@"下载完成：");
            NSLog(@"%@--%@",response,filePath);
        }
        
    }];
    
    //开始启动任务
    [task resume];
    
}

-(void)jfgNetworkChanged:(JFGNetType)netType
{
    if (!isDidAppear) {
        return;
    }
    if (netType == JFGNetTypeOffline) {
        //断网
    }else if(netType == JFGNetTypeWifi){
        //WiFi网络
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Tap1_SwitchedWiFi"]];
    }else{
        //移动网络
        [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"Tap1_SwitchedNetwork"]];
    }
}

//获取电池与sd卡状态(走公网)
-(void)reqForBattaryAndSDCard
{
    if (devIpAddr) {
        
        __weak typeof(self) weakSelf  = self;
    
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetSDInfo ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            /*
             "sdIsExist": 0,
             "sdcard_recogntion": -22,
             "storage": 0,
             "storage_used": 0
             
             int sdcard;//sd卡是否存在
             int sdcard_errno;//错误号。0 正常； 非0错误，需要格式化
             long long storage;//卡容量 单位byte
             long long storage_used;//已用空间 单位byte
             */
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int sdcard = [dict[@"sdIsExist"] intValue];
//                int sdcard_errno = [dict[@"sdcard_recogntion"] intValue];
//                long long storage = [dict[@"storage"] longLongValue];
//                long long storage_used = [dict[@"storage_used"] longLongValue];
                if (sdcard == 1) {
                    isHaveSDCard = YES;
                }else{
                    isHaveSDCard = NO;
                }
            }
            
        } failure:^(NSError * _Nonnull) {
            
        }];
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeBattery ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int battery = [dict[@"battery"] intValue];
                if (isPrower) {
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:200];
                    batteryRl = battery;
                }else{
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:battery];
                }
                [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:battery];
                NSLog(@"barrty:%d",battery);
            }
            
        } failure:^(NSError * _Nonnull) {
            
        }];
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetPowerLine ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            //powerline
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int powerline = [dict[@"powerline"] intValue];
                if (powerline == 1) {
                    isPrower = YES;
                }else{
                    isPrower = NO;
                }
            
                if (isPrower) {
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:200];
                }else{
                    if (![self dayIsShowWindow] && batteryRl <= 20) {
                        
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"DOOR_LOW_BATTERY"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
                        [alert show];
                        NSString *lastDateKey = [NSString stringWithFormat:@"devBatteryKey_%@",self.devModel.uuid];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastDateKey];
                    }
                    
                    [weakSelf showStatusTipForWiFiMode:isWifi batteryCapacity:batteryRl];
                }
                
            }
        } failure:^(NSError * _Nonnull) {
            
        }];
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetRP ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            
            NSLog(@"%@",responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
               
                NSDictionary *dict = responseObject;
                id obj = [dict objectForKey:@"resolution"];
                if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
                    int resolution = [obj intValue];
                    [weakSelf videoRPModelViewDeal:resolution];
                   
                }
                
                
            }
            
        } failure:^(NSError * _Nonnull) {
            
        }];
        
    }else{
    
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
        
        [JFGSDK sendDPDataMsgForSockWithPeer:self.devModel.uuid dpMsgIDs:@[seg1,seg2,seg3]];
        
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:21 msg:[NSData data]];
    }
    
    
   
    
//        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
//        int time = (int)timestamp;
//        
//        NSData *da = [MPMessagePackWriter writeObject:@[@0,@(time),@100] error:nil];
//        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:5 msg:da];
        
//        NSData *da = [MPMessagePackWriter writeObject:@"" error:nil];
//        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:7 msg:da];
}


-(void)speedLabelShowDealForHight:(BOOL)hight
{
    if (hight) {
        
    }
}

//视频录制情况
-(void)videoRecordstatusRequest
{
    if (devIpAddr) {
        
        __weak typeof(self) weakSelf  = self;
        
        [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeGetRecStatue ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = responseObject;
                /*
                 {
                 "ret": -1,
                 "seconds": 0,
                 "videoType": 0
                 }
                 */
                int ret = [dict[@"ret"] intValue];
                int seconds = [dict[@"seconds"] intValue];
                int videoType = [dict[@"videoType"] intValue];
                if (ret != 0) {
                    return ;
                }
                if (videoType == -1) {
                    //没有录像
                    recordState = VideoRecordStatueNone;
                    weakSelf.settingBtn.enabled = YES;
                }else if(videoType == 1){
                    //8s短视频
                    if (isCarameMode) {
                        [self videoModelAction];
                        self.takePhotoBtn.selected = YES;
                    }
                    recordState = VideoRecordStatue8SRecording;
                    if (playState == videoPlayStatePlaying) {
                        [weakSelf btnStatueForShortVideoWithRemainSe:8-seconds];
                    }
                    weakSelf.settingBtn.enabled = NO;
                }else if (videoType == 2){
                    //长视频
                    if (isCarameMode) {
                        [self videoModelAction];
                        self.takePhotoBtn.selected = YES;
                    }
                    recordState = VideoRecordStatueLongRecording;
                    if (playState == videoPlayStatePlaying) {
                        [weakSelf btnStatueForLongVideoForSecounds:seconds];
                    }
                    weakSelf.settingBtn.enabled = NO;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:videoType],self.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
            }
            
        } failure:^(NSError * _Nonnull) {
            
            
        }];
        
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
    id obj = [MPMessagePackReader readData:msgData error:nil];
    NSLog(@"Type:%d tcp:%@",type,obj);
    if (type == 8) {
        //拍照请求回调
        [self carameDataDeal:msgData];
    }else if (type == 10){
        //录制视频请求回调
        [self videoDataDeal:msgData];
    }else if (type == 14){
        //视频录制情况
        [self videoRecordDeal:msgData];
    }else if (type == 22){
        //视频分辨率
        [self videoRPGetDataDeal:msgData];
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
        id obj2 = [MPMessagePackReader readData:seg.value error:nil];
        NSLog(@"%@",obj2);
        if (seg.msgId == 204) {
            id obj = [MPMessagePackReader readData:seg.value error:nil];
            NSLog(@"%@",obj);
            if ([obj isKindOfClass:[NSArray class]]) {
                /*
                 storage int64 卡容量 单位byte
                 storage_used int64 已用空间 单位byte
                 sdcard_errno int 错误号。0 正常； 非0错误，需要格式化
                 sdcard bool 是否有卡
                 */
                NSArray *sourArr = obj;
                if (sourArr.count>=4) {
                    
                    id obj2 = sourArr[3];
                    if ([obj2 isKindOfClass:[NSNumber class]]) {
                        isHaveSDCard = [obj2 boolValue];
                    }
                    
                }
            }
        }else if (seg.msgId == 206 || seg.msgId == dpMsgBase_Power){
            [self baratyDeal:seg];
        }
    }
}


#pragma mark- 720数据处理
-(void)baratyDeal:(DataPointSeg *)seg
{
    if (seg.msgId == 206){
        //电池电量
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if ([obj isKindOfClass:[NSNumber class]]) {
            if (isPrower) {
                [self showStatusTipForWiFiMode:isWifi batteryCapacity:200];
                batteryRl =  [obj intValue];
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
                }else{
                    [self showStatusTipForWiFiMode:isWifi batteryCapacity:batteryRl];
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
                
                if (ret != 0) {
                    return;
                }
                
                
                if (videoType == -1) {
                    //没有录像
                    recordState = VideoRecordStatueNone;
                    self.settingBtn.enabled = YES;
                }else if(videoType == 1){
                    //8s短视频
                    if (isCarameMode) {
                        [self videoModelAction];
                        self.takePhotoBtn.selected = YES;
                    }
                    recordState = VideoRecordStatue8SRecording;
                    if (playState == videoPlayStatePlaying) {
                        [self btnStatueForShortVideoWithRemainSe:8-secouds];
                    }
                    self.settingBtn.enabled = NO;
                    
                }else if (videoType == 2){
                    //长视频
                    if (isCarameMode) {
                        [self videoModelAction];
                        self.takePhotoBtn.selected = YES;
                    }
                    recordState = VideoRecordStatueLongRecording;
                    if (playState == videoPlayStatePlaying) {
                        [self btnStatueForLongVideoForSecounds:secouds];
                    }
                    self.settingBtn.enabled = NO;
                }
                
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            
            
        }
        
    }
}

-(void)videoRPModelViewDeal:(int)hight
{
    if (hight == 1) {
        self.speedModeLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"];
        self.speedModeLeftBtn.enabled = NO;
        self.speedModeRightBtn.enabled = YES;
    }else{
        self.speedModeLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_SD"];
        self.speedModeLeftBtn.enabled = YES;
        self.speedModeRightBtn.enabled = NO;
    }
}

-(void)videoRPGetDataDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    NSLog(@"%@",obj);
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *sourArr = obj;
        if (sourArr.count>1) {
            
            id obj1 = sourArr[0];
            id obj2 = sourArr[1];
            if ([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]]) {
                //int ret = [obj1 intValue];
                int type = [obj2 intValue];
                [self videoRPModelViewDeal:type];
            }
            
        }
    }
}

-(void)stopVideoDataDeal:(NSData *)msgData
{
    
    id obj = [MPMessagePackReader readData:msgData error:nil];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = obj;
        if (sourceArr.count >= 4) {
            
            @try {
                /*
                 int，     ret       错误码
                 string，  fileName  文件名， 命名格式[timestamp].jpg 或 [timestamp]_[secends].avi， timestamp是文件生成时间的unix时间戳，secends是视频录制的时长,单位秒。根据后缀区分是图片或视频。
                 int，     fileSize  文件大小, bit。
                 string，  md5  文件的md5值
                 */
                int ret = [sourceArr[0] intValue];
                NSString *fileName = sourceArr[1] ;
                
                
                
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
    [self stopVideoViewRefresh];
    [self btnStatueForCarame];
}


-(void)videoDataDeal:(NSData *)msgData
{
    id obj = [MPMessagePackReader readData:msgData error:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
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
            self.settingBtn.enabled = NO;
            
        }else{
            recordState = VideoRecordStatueNone;
            NSLog(@"录像失败");
            [self stopVideoViewRefresh];
            self.takePhotoBtn.selected = NO;
            [ProgressHUD showText:@"录像失败,请检查SD卡"];
            self.settingBtn.enabled = YES;
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
    [self.speedModeBgView addSubview:self.speedModeLeftBtn];
    [self.speedModeBgView addSubview:self.speedModeLabel];
    [self.speedModeBgView addSubview:self.speedModeRightBtn];
    [self.videoBgImageView addSubview:self.voiceBtn];
    [self.videoBgImageView addSubview:self.micBtn];
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
}



-(void)initData
{
    batteryRl = self.devModel.Battery;
    isHaveSDCard = YES;
    timeoutRequestCount = 0;
    devIpAddr = nil;
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
    [self stopVideoViewRefresh];
    [self btnDisenableStatue];
    [self stopLoadingAnimation];
    [self stopTimeoutRequest];

}

#pragma mark- 添加代理
//视频播放相关代理
-(void)addVideoNotification
{
    if (isAddNotification) {
        return;
    }
    //视频直播相关代理
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onRecvDisconnectForRemote:) name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotifyResolution:) name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNotificatyRTCP:) name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    isAddNotification = YES;
}

-(void)removeVideoDelegate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnRecvDisconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyResolutionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JFGSDKOnNotifyRTCPNotification" object:nil];
    isAddNotification = NO;
}

-(void)didEnterBackground
{
    [self viewDidDisappear:YES];
    [self releaseTimer];
}

#pragma mark- 视频直播代理
-(void)onNotifyResolution:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    
    if (dict) {
        
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
            if ([remoteView isKindOfClass:[Panoramic720IosView class]]) {
                Panoramic720IosView *rv= (Panoramic720IosView *)remoteView;
                [rv stopRender];
            }
            [remoteView removeFromSuperview];
            remoteView = nil;
        }
        
        width = self.view.width;
        height= width;
        size = CGSizeMake(width, width);
         
        Panoramic720IosView * _remoteView = [[Panoramic720IosView alloc]initPanoramicViewWithFrame:CGRectMake(0, 0, self.videoBgImageView.width, self.videoBgImageView.height)];
        [_remoteView configV720];
        [_remoteView setDisplayMode:DM_Panorama];
        _remoteView.tag = VIEW_REMOTERENDE_VIEW_TAG;
        _remoteView.backgroundColor = [UIColor blackColor];
        _remoteView.layer.edgeAntialiasingMask = YES;
        [self.videoBgImageView addSubview:_remoteView];
        [self.videoBgImageView sendSubviewToBack:_remoteView];
        
        [CylanJFGSDK startRenderRemoteView:_remoteView];
        if (playState != videoPlayStatePlaying)
        {
            //[self voiceAndMicBtnNomalState];
            //[self fullVideoAndMicBtnNomal];
        }
        playState = videoPlayStatePlaying;
        [self stopLoadingAnimation];
        [self btnStatueForCarame];
        
        if (recordState != VideoRecordStatueNone) {
            [self videoRecordstatusRequest];
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
        
        if (errorType == JFGErrorTypeVideoPeerNotExist) {
            isDevOffline = YES;
        }else{
            isDevOffline = NO;
        }
        
        if (errorType == JFGErrorTypeVideoPeerInConnect) {
            
            __block VideoPlayFor720ViewController *blockSelf = self;
            UIAlertView *aleart = [[UIAlertView alloc]initWithTitle:nil message:[CommonMethod languaeKeyForLiveVideoErrorType:errorType] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
            [aleart showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                [blockSelf backAction];
            } otherDelegate:nil];
            
        }
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
    isDevOffline = NO;
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

-(void)netModeSwitchTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.view];
    NSLog(@"%@",NSStringFromCGPoint(point));
    [self netModeViewCloseAction];
    if (point.y <self.view.height*0.5) {
        //上半部，家居模式
        isSetHomeMode = YES;
        NSLog(@"top");
    }else{
        //下半部，户外模式
        NSLog(@"bottom");
        isSetHomeMode = NO;
    }
    AddDeviceGuideViewController *deviGuide = [AddDeviceGuideViewController new];
    deviGuide.pType = productType_720;
    deviGuide.delegate = self;
    [self.navigationController pushViewController:deviGuide animated:YES];
}

-(void)addDeviceGuideVCNectActionForVC:(UIViewController *)vc
{
    Cf720WiFiAnimationVC *wifiAn = [Cf720WiFiAnimationVC new];
    wifiAn.cidStr = self.devModel.uuid;
    wifiAn.isAPModel = !isSetHomeMode;
    [vc.navigationController pushViewController:wifiAn animated:YES];
}

-(void)singularTipTapAction:(UITapGestureRecognizer *)tap
{
    if (isDevOffline) {
        [self showNetModeSwitchView];
    }
}

#pragma mark- 按钮状态

//默认拍照状态
-(void)btnStatueForCarame
{
    isCarameMode = YES;
    self.cameraModeBtn.selected = YES;
    self.cameraModeBtn.hidden = NO;
    self.videoModeBtn.selected = NO;
    self.videoModeBtn.hidden = NO;
    self.cameraModeBtn.enabled = YES;
    self.videoModeBtn.enabled = YES;
    self.moreBtn.enabled = YES;
    self.moreBtn.hidden = NO;
    self.albumsBtn.enabled = YES;
    self.albumsBtn.hidden = NO;
    self.takePhotoBtn.enabled = YES;
    self.takePhotoBtn.userInteractionEnabled = YES;
    self.takePhotoBtn.hidden = NO;
    self.settingBtn.enabled = YES;
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
    }
    [self.takePhotoLoadingView startAnimating];
    self.takePhotoLoadingView.hidden = NO;
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
    if (shortVideoTimer && [shortVideoTimer isValid]) {
        [shortVideoTimer invalidate];
    }
    shortVideoTimer = nil;
    
    shortVideoTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shortVideoTimeShowAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:shortVideoTimer forMode:NSRunLoopCommonModes];
    
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
        self.settingBtn.enabled = YES;
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
    if (sender == self.speedModeLeftBtn) {
        [self videoResolvingPowerForIsHight:YES];
    }else if (sender == self.speedModeRightBtn){
        [self videoResolvingPowerForIsHight:NO];
    }
}

//重新加载按钮事件
-(void)againAction
{
    [self hiddenAgainView];
    [self workNetDecide];
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
            if (controlEvents == JFGTakePhotoTouchLongTap) {
                NSLog(@"long tap");
#pragma mark- 长按开始短视频录制
                if (isHaveSDCard) {
                    recordState = VideoRecordStatue8SRecording;
                    [self btnStatueForLoading];
                    [self shortVideoRecoding];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
                    [self performSelector:@selector(videoReqOvertime) withObject:nil afterDelay:10];
                    btn.selected = !btn.selected;
                }else{
                    [self videoReqOvertime];
                }
                
                
            }else{
#pragma mark- 单击开始长视频录制
                if (isHaveSDCard) {
                    recordState = VideoRecordStatueLongRecording;
                    [self btnStatueForLoading];
                    [self longVideoRecoding];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
                    [self performSelector:@selector(videoReqOvertime) withObject:nil afterDelay:10];
                    btn.selected = !btn.selected;
                }else{
                    [self videoReqOvertime];
                }
                
                
            }
        }else{
            //拍照模式下
            if (isHaveSDCard) {
                recordState = VideoRecordStatueNone;
                [self btnStatueForLoading];
                [self camarePhotoReq];
                
            }else{
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
            }
            
            
        }
    }else{
        
        if (!isCarameMode) {
            
            if (self.shortVideoTimeLabel.hidden == NO) {
                //停止短视频录制
                [self stopShortVideoRecode];
                self.settingBtn.enabled = YES;
            }
            
            if (self.timepiceView.hidden == NO) {
                //停止长视频录制
                [self stopLongVideoRecode];
                self.settingBtn.enabled = YES;
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
            [self stopVideoViewRefresh];
            btn.selected = !btn.selected;
            
        }else{
            //拍照模式下
            if (isHaveSDCard) {
                recordState = VideoRecordStatueNone;
                [self btnStatueForLoading];
                [self camarePhotoReq];
                
            }else{
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
            }
        }
    }
    
}

-(void)videoReqOvertime
{
    recordState = VideoRecordStatueNone;
    NSLog(@"录像失败");
    [self stopVideoViewRefresh];
    self.takePhotoBtn.selected = NO;
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
}

-(void)stopVideoViewRefresh
{
    [self.takePhotoLoadingView removeFromSuperview];
    [self.takePhotoLoadingView setHidden:YES];
    self.takePhotoBtn.enabled = YES;
    self.shortVideoTimeLabel.hidden = YES;
    self.shortVideoTimeLabel.text = @"8S";
    shortVideoTimeCount = 8;
    if (shortVideoTimer) {
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
        [self.recordAnimationView stopAnimation];
        [self.recordAnimationView setHidden:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.cameraModeBtn.hidden = NO;
            self.videoModeBtn.hidden = NO;
            self.albumsBtn.hidden = NO;
            self.moreBtn.hidden = NO;
            
        } completion:^(BOOL finished) {
           
        }];
        
    }
    NSLog(@"VideoPlayFor720VC_shortVideoTimeShowAction");
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
        if (devIpAddr) {
            __weak typeof(self) weakSelf = self;
            [self requestForUrl:[CommonMethod urlForLANFor720DevWithReqType:JFG720DevLANReqUrlTypeSnapShot ipAdd:devIpAddr] success:^(id  _Nullable responseObject) {
                [ProgressHUD showText:@"拍照成功"];
                [weakSelf stopVideoViewRefresh];
                [weakSelf btnStatueForCarame];
            } failure:^(NSError * _Nonnull) {
                [ProgressHUD showText:@"拍照失败"];
                [weakSelf stopVideoViewRefresh];
                [weakSelf btnStatueForCarame];
            }];
        }else{
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

-(void)videoResolvingPowerForIsHight:(BOOL)hight
{
    if (devIpAddr) {
        [self requestForUrl:[self videoRPIsHight:hight] success:^(id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    
                }else{
                    
                }
            }
        } failure:^(NSError * _Nonnull) {
            
        }];
    }else{
        NSData *data = [MPMessagePackWriter writeObject:@[@(hight?1:0)] error:nil];
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:17 msg:data];
    }
}

-(void)videoRecordingReqForLong:(BOOL)isLong
{
    //9 videoType 特征值定义： videoTypeShort = 1 8s短视频； videoTypeLong = 2 长视频
    if (devIpAddr) {
        __weak typeof(self) weakSelf = self;
        [self requestForUrl:[self startRecIsLongVideo:isLong] success:^(id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    
                    if (recordState == VideoRecordStatue8SRecording) {
                        [weakSelf btnStatueForShortVideoWithRemainSe:8];
                    }else if (recordState == VideoRecordStatueLongRecording){
                        [weakSelf btnStatueForLongVideoForSecounds:0];
                    }
                    weakSelf.settingBtn.enabled = NO;
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoReqOvertime) object:nil];
                    
                }else{
                    recordState = VideoRecordStatueNone;
                    NSLog(@"录像失败");
                    [weakSelf stopVideoViewRefresh];
                    weakSelf.takePhotoBtn.selected = NO;
                    [ProgressHUD showText:@"录像失败,请检查SD卡"];
                    weakSelf.settingBtn.enabled = YES;
                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(videoReqOvertime) object:nil];
                }
                
            }
        } failure:^(NSError * _Nonnull) {
            
        }];
        
    }else{
        NSData *data = [MPMessagePackWriter writeObject:@[@(isLong?2:1)] error:nil];
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:9 msg:data];
    }
    
}

-(void)stopVideoRecordingReqForLong:(BOOL)isLong
{
    
    if (devIpAddr) {
        [self requestForUrl:[self stopRecIsLongVideo:isLong] success:^(id  _Nullable responseObject) {
            
            /*
             {
             "ret": -1,
             "files": ""
             }
             */
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    
                }else{
                    
                }
                
            }
            
        } failure:^(NSError * _Nonnull) {
            
            
            
        }];
    }else{
        NSData *data = [MPMessagePackWriter writeObject:@[@(isLong?2:1)] error:nil];
        [JFGSDK sendMsgForTcpWithDst:@[self.devModel.uuid] isAck:YES fileType:11 msg:data];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DevFor720VideoStatues" object:[NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:-1],self.devModel.uuid] forKeys:@[@"videoType",@"uuid"]]];
}

#pragma mark- 动画事件
-(void)startLodingAnimation
{
    if (self.loadingImageView.superview == nil) {
        [self.videoBgImageView addSubview:self.loadingImageView];
    }else{
        [self.videoBgImageView bringSubviewToFront:self.loadingImageView];
    }
    if (!self.loadingImageView.hidden) {
        return;
    }
    self.loadingImageView.hidden = NO;
    [self hiddenTipView];
    [self hiddenAgainView];
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

-(void)hiddenTipView
{
    if (!self.singularTipBgView.hidden) {
        self.singularTipBgView.alpha = 0;
        self.singularTipBgView.top = -self.singularTipBgView.height;
        self.singularTipBgView.hidden = YES;
        self.rateLabel.hidden = NO;
    }
}

#pragma mark- 重新加载视图
-(void)showAgainView
{
    if (self.againBgView.superview == nil) {
        [self.videoBgImageView addSubview:self.againBgView];
    }else{
        [self.videoBgImageView bringSubviewToFront:self.againBgView];
    }
    self.againBgView.hidden = NO;
}

-(void)hiddenAgainView
{
    self.againBgView.hidden = YES;
    [self.againBgView removeFromSuperview];
}

-(void)showNetModeSwitchView
{
    if (self.netModeSwitchBgView.superview == nil) {
        self.netModeSwitchBgView.alpha = 0;
        [self.view addSubview:self.netModeSwitchBgView];
        [UIView animateWithDuration:0.5 animations:^{
            self.netModeSwitchBgView.alpha = 1;
        }];
    }
}

-(void)netModeViewCloseAction
{
    [UIView animateWithDuration:0.5 animations:^{
        self.netModeSwitchBgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.netModeSwitchBgView removeFromSuperview];
    }];
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
            
            //电量低于20%
           
            
        }
        self.statusBatteryLabel.text =[NSString stringWithFormat:@"%d%%",battery];
    }
    
    
}


//上次弹窗时间是否是今天
-(BOOL)dayIsShowWindow
{
    NSString *lastDateKey = [NSString stringWithFormat:@"devBatteryKey_%@",self.devModel.uuid];
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:lastDateKey];
    if (!lastDate) {
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSDate *currentDate = [NSDate date];
    
    NSString *currentTime = [dateFormatter stringFromDate:currentDate];
    NSString *lastTime = [dateFormatter stringFromDate:lastDate];
    if ([currentTime isEqualToString:lastTime]) {
        return YES;
    }
    
    return NO;
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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singularTipTapAction:)];
        [_singularTipBgView addGestureRecognizer:tap];
        
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
        _speedModeBgView.right = self.videoBgImageView.width-15;
        _speedModeBgView.top = self.view.height - 64 - self.bottomBgView.height;
        _speedModeBgView.alpha = 0;
       
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
        _speedModeLeftBtn.enabled = NO;
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
        _speedModeRightBtn.enabled = YES;
        [_speedModeRightBtn addTarget:self action:@selector(speedModeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedModeRightBtn;
}

-(UILabel *)speedModeLabel
{
    if (!_speedModeLabel) {
        _speedModeLabel = [[UILabel alloc]initWithFrame:CGRectMake(16+24, 13, 144-16-24, 16)];
        _speedModeLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Video_HD"];
        _speedModeLabel.font = [UIFont systemFontOfSize:15];
        _speedModeLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        [self.KVOController observe:_speedModeLabel keyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            
            //根据文字适配
            [_speedModeLabel sizeToFit];
            CGSize size = _speedModeLabel.size;
            CGFloat allWidth = size.width + (16+_speedModeLeftBtn.width)*2;
            _speedModeBgView.width = allWidth;
            _speedModeLabel.x = allWidth*0.5;
            _speedModeLeftBtn.left = 8;
            _speedModeRightBtn.left = _speedModeLabel.right+8;
            _speedModeBgView.right = self.videoBgImageView.width-15;
            
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
        self.speedModeBgView.hidden = NO;
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

-(UIView *)againBgView
{
    if (!_againBgView) {
        _againBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250*0.5, 250*0.5)];
        _againBgView.center = CGPointMake(self.videoBgImageView.width*0.5, self.videoBgImageView.height*0.5);
        _againBgView.backgroundColor = [UIColor clearColor];
        _againBgView.hidden = YES;
        
        UIButton *againBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [againBtn setImage:[UIImage imageNamed:@"camera_icon_no-network"] forState:UIControlStateNormal];
        againBtn.size = CGSizeMake(50, 50);
        againBtn.x = self.againBgView.width*0.5;
        [againBtn addTarget:self action:@selector(againAction) forControlEvents:UIControlEventTouchUpInside];
        [_againBgView addSubview:againBtn];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, againBtn.bottom+19, self.againBgView.width, 17)];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"重新加载";
        [_againBgView addSubview:label];
        
        againBtn.top = (_againBgView.height - 19 - againBtn.height - label.height)*0.5;
    }
    return _againBgView;
}

-(UIView *)netModeSwitchBgView
{
    if (!_netModeSwitchBgView) {
        _netModeSwitchBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        _netModeSwitchBgView.backgroundColor = [UIColor colorWithColor:[UIColor blackColor] alpha:0.6];
        //540 × 702
        UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pop_model"]];
        bgImageView.center = self.view.center;
        bgImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(netModeSwitchTap:)];
        [bgImageView addGestureRecognizer:tap];
        [_netModeSwitchBgView addSubview:bgImageView];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(0, 0, 44, 44);
        closeBtn.x = self.view.x;
        closeBtn.top = bgImageView.bottom + 20;
        [closeBtn setImage:[UIImage imageNamed:@"pop_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(netModeViewCloseAction) forControlEvents:UIControlEventTouchUpInside];
        [_netModeSwitchBgView addSubview:closeBtn];
        
        for (int i=0; i<2; i++) {
            
            CGFloat startTop = 0;
            if (i==0) {
                startTop = 20;
            }else{
                startTop = bgImageView.height*0.5+20;
            }
            UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, startTop, bgImageView.width, 17)];
            titleLable.textColor = [UIColor colorWithHexString:@"#333333"];
            titleLable.font = [UIFont systemFontOfSize:16];
            titleLable.textAlignment = NSTextAlignmentCenter;
            
            UILabel *detailLable = [[UILabel alloc]initWithFrame:CGRectMake(0, titleLable.bottom+100, bgImageView.width, 15)];
            detailLable.font = [UIFont systemFontOfSize:14];
            detailLable.textColor = [UIColor colorWithHexString:@"#666666"];
            detailLable.textAlignment = NSTextAlignmentCenter;
            
            
            if (i == 0) {
                titleLable.text = [JfgLanguage getLanTextStrByKey:@"Tap1_HomeMode"];
                detailLable.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_TCPconnected"];
            }else{
                titleLable.text = [JfgLanguage getLanTextStrByKey:@"Tap1_OutdoorMode"];
                detailLable.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_UDPconnected"];
            }
            
            [bgImageView addSubview:titleLable];
            [bgImageView addSubview:detailLable];
        }
        
    }
    return _netModeSwitchBgView;
}


-(NSString *)startRecIsLongVideo:(BOOL)isLong
{
    if (devIpAddr) {
        return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=startRec&videoType=%d",devIpAddr,isLong?2:1];
    }
    return @"";
    
}

-(NSString *)videoRPIsHight:(BOOL)isHight
{
    if (devIpAddr) {
        return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=setResolution&videoStandard=%d",devIpAddr,isHight?1:0];
    }
    return @"";
}

-(NSString *)stopRecIsLongVideo:(BOOL)isLong
{
    if (devIpAddr) {
        return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=stopRec&videoType=%d",devIpAddr,isLong?2:1];
    }
    return @"";
}

-(NSString *)downloadForFileName:(NSString *)fileName
{
    if (devIpAddr) {
        return [NSString stringWithFormat:@"http://%@/images/%@",devIpAddr,fileName];
    }
    return @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [JFGSDK removeDelegate:self];
    NSLog(@"video720VC dealloc");
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
